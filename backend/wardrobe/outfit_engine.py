import os
import json
import random
import requests
import io
import uuid
from typing import List, Dict, Any
from pydantic import BaseModel, Field

from django.conf import settings
from .models import WardrobeItem, Outfit

# Import official Google GenAI SDK
from google import genai
from google.genai import types

# Import Hugging Face Inference SDK for fast free AI image generation
from huggingface_hub import InferenceClient

# Import Cloudinary SDK for uploading generated avatar image bytes
import cloudinary
import cloudinary.uploader


# ---------------------------------------------------------------------------
# Pydantic Schemas for Gemini Structured Output (Stage 1)
# ---------------------------------------------------------------------------
# Using Pydantic models with google-genai allows us to enforce a strict JSON
# schema response from Gemini gemini-2.5-flash.
# ---------------------------------------------------------------------------


class OutfitOptionSchema(BaseModel):
    item_ids: List[int] = Field(
        description="List of integer IDs of the WardrobeItems used in this outfit combination."
    )
    title: str = Field(description="Catchy short title for the outfit combination.")
    reasoning: str = Field(
        description="Explanation of why these items were paired together for the occasion."
    )


class OutfitResponseSchema(BaseModel):
    outfits: List[OutfitOptionSchema] = Field(
        description="List of 2 to 3 outfit combinations built from the provided wardrobe."
    )


# ---------------------------------------------------------------------------
# Helper: Get Gemini API Client
# ---------------------------------------------------------------------------
def _get_gemini_client() -> genai.Client:
    """
    Initializes and returns the official google-genai Client.
    Reads API key from Django settings or environment variables.
    """
    api_key = getattr(settings, "GEMINI_API_KEY", os.getenv("GEMINI_API_KEY", None))
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not configured in settings or environment.")
    return genai.Client(api_key=api_key)


# ===========================================================================
# STAGE 1: Real Gemini AI Text Suggestions with Structured Output
# ===========================================================================
def get_outfit_text_suggestions(user, occasion: str) -> List[Dict[str, Any]]:
    """
    Generates 2-3 distinct text outfit combinations built strictly from the user's uploaded wardrobe items.
    Uses Gemini gemini-2.5-flash with structured output enforcement and defensive ID validation.

    API Contract Return Shape (matches Flutter client expectations):
    [
        {
            "id": "opt_1",
            "title": "...",
            "description": "...",
            "item_ids": [1, 2],
            "item_summary": ["Blue Denim (Tops)", "Black Jeans (Bottoms)"]
        }, ...
    ]
    """
    user_items = list(WardrobeItem.objects.filter(user=user))

    # If user has zero wardrobe items added yet, return empty list
    if not user_items:
        return []

    # Map of valid user item IDs for defensive checking against hallucinated IDs
    valid_item_map = {item.id: item for item in user_items}

    # Primary Attempt: Call Gemini AI for reasoning and outfit creation
    try:
        client = _get_gemini_client()

        # Serialize user items into lightweight JSON for Gemini prompt context
        wardrobe_json = [
            {
                "id": item.id,
                "name": item.name,
                "category": item.category,
                "color": item.color,
                "season": item.season,
                "occasion": item.occasion,
            }
            for item in user_items
        ]

        # Construct prompt instructing Gemini to ONLY use provided item IDs
        prompt = (
            f"You are a personal fashion stylist assistant.\n"
            f"Target Occasion: '{occasion}'\n"
            f"User Wardrobe Catalog (JSON):\n{json.dumps(wardrobe_json, indent=2)}\n\n"
            f"STRICT INSTRUCTIONS:\n"
            f"1. Create 2 to 3 stylish, distinct outfit combinations appropriate for '{occasion}'.\n"
            f"2. You may ONLY use items from the Wardrobe Catalog provided above by their exact 'id'.\n"
            f"3. NEVER invent, guess, or hallucinate an item 'id' that is not in the list.\n"
            f"4. Pair complementary garments (e.g. Tops + Bottoms, or Dress + Accessories)."
        )

        # Educational Note: Call Gemini 2.5 Flash using structured response_schema
        # Setting response_mime_type="application/json" and providing a Pydantic model
        # guarantees Gemini returns structured JSON conforming to OutfitResponseSchema.
        response = client.models.generate_content(
            model="gemini-3.5-flash-lite",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=OutfitResponseSchema,
                temperature=0.7,
            ),
        )

        # Parse structured JSON from response text
        parsed_response = OutfitResponseSchema.model_validate_json(response.text)

        suggestions = []
        for idx, option in enumerate(parsed_response.outfits):
            # Defensive check: Filter returned item_ids against actual real database item IDs for this user
            validated_item_ids = [
                item_id for item_id in option.item_ids if item_id in valid_item_map
            ]

            # Skip any option if Gemini returned no valid items after filtering
            if not validated_item_ids:
                continue

            # Build human-readable item summary list for Flutter UI display
            item_summary = [
                f"{valid_item_map[item_id].color} {valid_item_map[item_id].name} ({valid_item_map[item_id].category})"
                for item_id in validated_item_ids
            ]

            suggestions.append(
                {
                    "id": f"opt_{idx + 1}",
                    "title": option.title or f"Option {idx + 1}",
                    "description": option.reasoning or f"Tailored for {occasion}",
                    "item_ids": validated_item_ids,
                    "item_summary": item_summary,
                }
            )

        if suggestions:
            return suggestions

    except Exception as e:
        # Educational Note: Safety net fallback. If Gemini API key is missing, network fails, or
        # any unexpected error occurs, log the error and proceed to the fallback logic below.
        print(
            f"[Gemini AI Engine] get_outfit_text_suggestions error: {e}. Using fallback logic."
        )

    # Safety Net Fallback: Executed if Gemini API fails or returns no valid suggestions
    return _fallback_random_text_suggestions(user_items, occasion)


def _fallback_random_text_suggestions(
    user_items: List[WardrobeItem], occasion: str
) -> List[Dict[str, Any]]:
    """
    Fallback outfit matching algorithm using local category priority logic.
    Ensures the API endpoint never breaks even if external services fail.
    """
    traditional_categories = ["Saree", "Lehanga", "Kurta", "Dresses", "Jumpsuit"]
    casual_categories = ["Tops", "Bottoms", "Jacket", "Shorts", "Jeggings"]

    occ_lower = occasion.lower()
    is_traditional = any(
        word in occ_lower
        for word in [
            "marriage",
            "wedding",
            "ethnic",
            "function",
            "puja",
            "festival",
            "party",
        ]
    )

    suggestions = []

    # Option 1
    target_cats = traditional_categories if is_traditional else casual_categories
    matching_primary = [
        i for i in user_items if i.category in target_cats
    ] or user_items
    item1 = random.choice(matching_primary)
    combo1_items = [item1]

    if item1.category in ["Tops", "Kurta", "Jacket"]:
        bottoms = [
            i
            for i in user_items
            if i.category in ["Bottoms", "Jeggings", "Shorts"] and i.id != item1.id
        ]
        if bottoms:
            combo1_items.append(random.choice(bottoms))

    accs = [
        i
        for i in user_items
        if i.category in ["Accessories", "Shoes"]
        and i.id not in [x.id for x in combo1_items]
    ]
    if accs:
        combo1_items.append(random.choice(accs))

    item1_desc = " + ".join([f"{x.color} {x.name}" for x in combo1_items])
    suggestions.append(
        {
            "id": "opt_1",
            "title": f"Option 1: {item1_desc}",
            "description": f"Handpicked from your wardrobe for {occasion}",
            "item_ids": [x.id for x in combo1_items],
            "item_summary": [
                f"{x.color} {x.name} ({x.category})" for x in combo1_items
            ],
        }
    )

    # Option 2
    remaining = [
        i for i in user_items if i.id not in [x.id for x in combo1_items]
    ] or user_items
    item2 = random.choice(remaining)
    combo2_items = [item2]
    if item2.category in ["Tops", "Jacket", "Kurta"]:
        bottoms2 = [
            i
            for i in user_items
            if i.category in ["Bottoms", "Jeggings", "Shorts"] and i.id != item2.id
        ]
        if bottoms2:
            combo2_items.append(random.choice(bottoms2))

    item2_desc = " + ".join([f"{x.color} {x.name}" for x in combo2_items])
    suggestions.append(
        {
            "id": "opt_2",
            "title": f"Option 2: {item2_desc}",
            "description": f"Balanced color palette tailored for {occasion}",
            "item_ids": [x.id for x in combo2_items],
            "item_summary": [
                f"{x.color} {x.name} ({x.category})" for x in combo2_items
            ],
        }
    )

    # Option 3
    pool3 = [
        i for i in user_items if i.id not in [x.id for x in combo1_items + combo2_items]
    ] or user_items
    item3 = random.choice(pool3)
    combo3_items = [item3]

    item3_desc = " + ".join([f"{x.color} {x.name}" for x in combo3_items])
    suggestions.append(
        {
            "id": "opt_3",
            "title": f"Option 3: {item3_desc}",
            "description": f"Chic alternative ensemble from your wardrobe",
            "item_ids": [x.id for x in combo3_items],
            "item_summary": [
                f"{x.color} {x.name} ({x.category})" for x in combo3_items
            ],
        }
    )

    return suggestions


# ===========================================================================
# STAGE 2: Multimodal Gemini Avatar Image Generation & Cloudinary Upload
# ===========================================================================
def generate_avatar_image_for_items(user, occasion: str, item_ids: List[int]) -> Outfit:
    """
    Takes the user's selected wardrobe item IDs, loads their actual garment images,
    and calls Gemini gemini-2.5-flash-image with multimodal prompt & images to generate
    a full-body model portrait wearing the exact items. Uploads to Cloudinary and saves Outfit.
    """
    selected_items = list(WardrobeItem.objects.filter(id__in=item_ids, user=user))
    if not selected_items:
        # Fallback if no item IDs provided or invalid
        selected_items = list(WardrobeItem.objects.filter(user=user)[:3])

    item_names = [
        f"{item.color} {item.name} ({item.category})" for item in selected_items
    ]
    items_desc = ", ".join(item_names) if item_names else "stylish outfit"

    title = f"{occasion.capitalize()} Avatar Look"
    styling_advice = f"Female model avatar styled in your selected wardrobe pieces: {items_desc} for {occasion}."

    # Attempt to generate image via Hugging Face FLUX (or Gemini fallback)
    image_url = _generate_avatar_image(occasion, selected_items)

    # Save created Outfit in database
    outfit = Outfit.objects.create(
        user=user,
        title=title,
        occasion=occasion,
        ai_generated_image_url=image_url,
        styling_advice=styling_advice,
    )
    if selected_items:
        outfit.items.set(selected_items)

    return outfit


def _save_or_upload_image_bytes(image_bytes: bytes) -> str:
    """
    Helper to persist generated image bytes:
    1. Uploads to Cloudinary if credentials are configured in .env / settings.
    2. Otherwise saves directly to Django's local media directory (/media/ootdee_avatars/)
       and returns the accessible URL.
    """
    cloud_name = getattr(
        settings, "CLOUDINARY_CLOUD_NAME", os.getenv("CLOUDINARY_CLOUD_NAME", "")
    )
    if cloud_name:
        try:
            upload_result = cloudinary.uploader.upload(
                io.BytesIO(image_bytes), folder="ootdee_avatars"
            )
            secure_url = upload_result.get("secure_url")
            if secure_url:
                return secure_url
        except Exception as cloud_err:
            print(
                f"[Image Engine] Cloudinary upload error: {cloud_err}. Storing in local media folder."
            )

    # Fallback to saving in local media storage
    media_folder = os.path.join(settings.MEDIA_ROOT, "ootdee_avatars")
    os.makedirs(media_folder, exist_ok=True)
    filename = f"avatar_{uuid.uuid4().hex[:12]}.jpg"
    file_path = os.path.join(media_folder, filename)
    with open(file_path, "wb") as f:
        f.write(image_bytes)

    return f"/media/ootdee_avatars/{filename}"


def _generate_avatar_image(occasion: str, selected_items: List[WardrobeItem]) -> str:
    """
    Generates an AI fashion avatar image:
    1. Primary: Uses Hugging Face FLUX.1-schnell (free serverless inference).
    2. Secondary: Uses Google Gemini image generation if available.
    3. Fallback: High-resolution Unsplash fashion model.
    """
    fallback_image_url = "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80"

    item_names = [
        f"{item.color} {item.name} ({item.category})" for item in selected_items
    ]
    items_desc = ", ".join(item_names) if item_names else "stylish outfit"

    # ---------------------------------------------------------------------------
    # Method 1: Hugging Face Stable Diffusion XL (Fast, High Quality 1024x1024)
    # ---------------------------------------------------------------------------
    hf_token = getattr(
        settings, "HUGGINGFACE_API_TOKEN", os.getenv("HUGGINGFACE_API_TOKEN", None)
    )
    if hf_token:
        try:
            hf_client = InferenceClient(token=hf_token)
            hf_prompt = (
                f"Full-body high fashion photograph of a stylish model wearing {items_desc}, "
                f"styled for a {occasion} occasion. Professional runway magazine lighting, 8k resolution, photorealistic, clean studio backdrop."
            )
            print(
                f"[Hugging Face AI Engine] Generating avatar with Stable Diffusion XL for occasion: {occasion}..."
            )
            pil_image = hf_client.text_to_image(
                prompt=hf_prompt,
                model="stabilityai/stable-diffusion-xl-base-1.0",
            )
            if pil_image:
                buffer = io.BytesIO()
                pil_image.save(buffer, format="JPEG", quality=92)
                hosted_url = _save_or_upload_image_bytes(buffer.getvalue())
                if hosted_url:
                    print(
                        f"[Hugging Face AI Engine] Successfully created avatar image with Stable Diffusion: {hosted_url}"
                    )
                    return hosted_url
        except Exception as hf_err:
            print(
                f"[Hugging Face AI Engine] Stable Diffusion generation error: {hf_err}. Attempting Gemini fallback..."
            )

    # ---------------------------------------------------------------------------
    # Method 2: Gemini Multimodal Image Generation
    # ---------------------------------------------------------------------------
    try:
        client = _get_gemini_client()
        image_parts = []
        for item in selected_items:
            img_bytes = None
            mime_type = "image/jpeg"
            if item.image_url:
                try:
                    res = requests.get(item.image_url, timeout=10)
                    if res.status_code == 200:
                        img_bytes = res.content
                        header_mime = res.headers.get("Content-Type")
                        if header_mime and "/" in header_mime:
                            mime_type = header_mime
                except Exception:
                    pass

            if not img_bytes and item.image:
                try:
                    item.image.open("rb")
                    img_bytes = item.image.read()
                    if hasattr(item.image, "name") and item.image.name.lower().endswith(
                        ".png"
                    ):
                        mime_type = "image/png"
                except Exception:
                    pass

            if img_bytes:
                image_parts.append(
                    types.Part.from_bytes(data=img_bytes, mime_type=mime_type)
                )

        prompt_text = (
            f"Generate a full-body studio photo of a model wearing exactly {items_desc} "
            f"combined into one outfit, styled for a {occasion} occasion. Studio lighting, 8k."
        )
        contents = [prompt_text] + image_parts
        response = client.models.generate_content(
            model="gemini-3.1-flash-image",
            contents=contents,
            config=types.GenerateContentConfig(response_modalities=["IMAGE", "TEXT"]),
        )

        if (
            response.candidates
            and response.candidates[0].content
            and response.candidates[0].content.parts
        ):
            for part in response.candidates[0].content.parts:
                if (
                    hasattr(part, "inline_data")
                    and part.inline_data
                    and part.inline_data.data
                ):
                    hosted_url = _save_or_upload_image_bytes(part.inline_data.data)
                    if hosted_url:
                        return hosted_url

    except Exception as gemini_err:
        print(
            f"[Gemini AI Engine] generate_avatar_image error: {gemini_err}. Using fallback image URL."
        )

    # Fallback if both engines are unavailable
    return fallback_image_url
