import os
import json
import random
import requests
import io
from typing import List, Dict, Any
from pydantic import BaseModel, Field

from django.conf import settings
from .models import WardrobeItem, Outfit

# Import official Google GenAI SDK
from google import genai
from google.genai import types

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
    title: str = Field(
        description="Catchy short title for the outfit combination."
    )
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
    api_key = getattr(settings, 'GEMINI_API_KEY', os.getenv('GEMINI_API_KEY', None))
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
                "occasion": item.occasion
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
            model="gemini-2.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=OutfitResponseSchema,
                temperature=0.7,
            )
        )

        # Parse structured JSON from response text
        parsed_response = OutfitResponseSchema.model_validate_json(response.text)

        suggestions = []
        for idx, option in enumerate(parsed_response.outfits):
            # Defensive check: Filter returned item_ids against actual real database item IDs for this user
            validated_item_ids = [item_id for item_id in option.item_ids if item_id in valid_item_map]
            
            # Skip any option if Gemini returned no valid items after filtering
            if not validated_item_ids:
                continue

            # Build human-readable item summary list for Flutter UI display
            item_summary = [
                f"{valid_item_map[item_id].color} {valid_item_map[item_id].name} ({valid_item_map[item_id].category})"
                for item_id in validated_item_ids
            ]

            suggestions.append({
                "id": f"opt_{idx + 1}",
                "title": option.title or f"Option {idx + 1}",
                "description": option.reasoning or f"Tailored for {occasion}",
                "item_ids": validated_item_ids,
                "item_summary": item_summary
            })

        if suggestions:
            return suggestions

    except Exception as e:
        # Educational Note: Safety net fallback. If Gemini API key is missing, network fails, or
        # any unexpected error occurs, log the error and proceed to the fallback logic below.
        print(f"[Gemini AI Engine] get_outfit_text_suggestions error: {e}. Using fallback logic.")

    # Safety Net Fallback: Executed if Gemini API fails or returns no valid suggestions
    return _fallback_random_text_suggestions(user_items, occasion)


def _fallback_random_text_suggestions(user_items: List[WardrobeItem], occasion: str) -> List[Dict[str, Any]]:
    """
    Fallback outfit matching algorithm using local category priority logic.
    Ensures the API endpoint never breaks even if external services fail.
    """
    traditional_categories = ['Saree', 'Lehanga', 'Kurta', 'Dresses', 'Jumpsuit']
    casual_categories = ['Tops', 'Bottoms', 'Jacket', 'Shorts', 'Jeggings']

    occ_lower = occasion.lower()
    is_traditional = any(word in occ_lower for word in ['marriage', 'wedding', 'ethnic', 'function', 'puja', 'festival', 'party'])

    suggestions = []
    
    # Option 1
    target_cats = traditional_categories if is_traditional else casual_categories
    matching_primary = [i for i in user_items if i.category in target_cats] or user_items
    item1 = random.choice(matching_primary)
    combo1_items = [item1]
    
    if item1.category in ['Tops', 'Kurta', 'Jacket']:
        bottoms = [i for i in user_items if i.category in ['Bottoms', 'Jeggings', 'Shorts'] and i.id != item1.id]
        if bottoms:
            combo1_items.append(random.choice(bottoms))
    
    accs = [i for i in user_items if i.category in ['Accessories', 'Shoes'] and i.id not in [x.id for x in combo1_items]]
    if accs:
        combo1_items.append(random.choice(accs))

    item1_desc = " + ".join([f"{x.color} {x.name}" for x in combo1_items])
    suggestions.append({
        "id": "opt_1",
        "title": f"Option 1: {item1_desc}",
        "description": f"Handpicked from your wardrobe for {occasion}",
        "item_ids": [x.id for x in combo1_items],
        "item_summary": [f"{x.color} {x.name} ({x.category})" for x in combo1_items]
    })

    # Option 2
    remaining = [i for i in user_items if i.id not in [x.id for x in combo1_items]] or user_items
    item2 = random.choice(remaining)
    combo2_items = [item2]
    if item2.category in ['Tops', 'Jacket', 'Kurta']:
        bottoms2 = [i for i in user_items if i.category in ['Bottoms', 'Jeggings', 'Shorts'] and i.id != item2.id]
        if bottoms2:
            combo2_items.append(random.choice(bottoms2))

    item2_desc = " + ".join([f"{x.color} {x.name}" for x in combo2_items])
    suggestions.append({
        "id": "opt_2",
        "title": f"Option 2: {item2_desc}",
        "description": f"Balanced color palette tailored for {occasion}",
        "item_ids": [x.id for x in combo2_items],
        "item_summary": [f"{x.color} {x.name} ({x.category})" for x in combo2_items]
    })

    # Option 3
    pool3 = [i for i in user_items if i.id not in [x.id for x in combo1_items + combo2_items]] or user_items
    item3 = random.choice(pool3)
    combo3_items = [item3]

    item3_desc = " + ".join([f"{x.color} {x.name}" for x in combo3_items])
    suggestions.append({
        "id": "opt_3",
        "title": f"Option 3: {item3_desc}",
        "description": f"Chic alternative ensemble from your wardrobe",
        "item_ids": [x.id for x in combo3_items],
        "item_summary": [f"{x.color} {x.name} ({x.category})" for x in combo3_items]
    })

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

    item_names = [f"{item.color} {item.name} ({item.category})" for item in selected_items]
    items_desc = ", ".join(item_names) if item_names else "stylish outfit"

    title = f"{occasion.capitalize()} Avatar Look"
    styling_advice = f"Female model avatar styled in your selected wardrobe pieces: {items_desc} for {occasion}."

    # Attempt to generate image via Gemini multimodal input
    image_url = _generate_multimodal_gemini_avatar(occasion, selected_items)

    # Save created Outfit in database
    outfit = Outfit.objects.create(
        user=user,
        title=title,
        occasion=occasion,
        ai_generated_image_url=image_url,
        styling_advice=styling_advice
    )
    if selected_items:
        outfit.items.set(selected_items)

    return outfit


def _generate_multimodal_gemini_avatar(occasion: str, selected_items: List[WardrobeItem]) -> str:
    """
    Loads real garment photo bytes from user's WardrobeItems and sends them as multimodal
    inline parts to Gemini gemini-2.5-flash-image. Uploads the generated image bytes to Cloudinary.
    """
    fallback_image_url = "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80"

    try:
        client = _get_gemini_client()

        # Prepare multimodal content: prompt text + real garment image parts
        image_parts = []
        for item in selected_items:
            img_bytes = None
            mime_type = "image/jpeg"

            # Check if garment image is stored as Cloudinary URL or HTTP URL
            if item.image_url:
                try:
                    res = requests.get(item.image_url, timeout=10)
                    if res.status_code == 200:
                        img_bytes = res.content
                        header_mime = res.headers.get("Content-Type")
                        if header_mime and "/" in header_mime:
                            mime_type = header_mime
                except Exception as net_err:
                    print(f"[Gemini AI Engine] Error fetching item image_url {item.image_url}: {net_err}")

            # Fallback to local image field if image_url wasn't available
            if not img_bytes and item.image:
                try:
                    item.image.open('rb')
                    img_bytes = item.image.read()
                    if hasattr(item.image, 'name') and item.image.name.lower().endswith('.png'):
                        mime_type = "image/png"
                except Exception as file_err:
                    print(f"[Gemini AI Engine] Error reading local item image: {file_err}")

            # Convert raw bytes to google-genai types.Part
            if img_bytes:
                image_parts.append(
                    types.Part.from_bytes(data=img_bytes, mime_type=mime_type)
                )

        # Construct multimodal prompt for Gemini 2.5 Flash Image
        prompt_text = (
            f"Generate a full-body studio photo of a female model wearing exactly these clothing items "
            f"combined into one outfit, styled for a {occasion} occasion, and NOT adding any garment "
            f"that isn't shown in the provided images. Studio lighting, high fashion photography, 8k resolution."
        )

        # Educational Note: Call Gemini gemini-2.5-flash-image with multimodal input parts
        # and request IMAGE response modality in GenerateContentConfig.
        contents = [prompt_text] + image_parts
        response = client.models.generate_content(
            model="gemini-2.5-flash-image",
            contents=contents,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"]
            )
        )

        # Extract returned image bytes from Gemini response parts
        generated_bytes = None
        if response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            for part in response.candidates[0].content.parts:
                if hasattr(part, 'inline_data') and part.inline_data and part.inline_data.data:
                    generated_bytes = part.inline_data.data
                    break

        if generated_bytes:
            # Educational Note: Upload raw image bytes returned by Gemini directly to Cloudinary
            # and retrieve a secure hosted HTTPS URL to return to the mobile app.
            upload_result = cloudinary.uploader.upload(
                io.BytesIO(generated_bytes),
                folder="ootdee_avatars"
            )
            secure_url = upload_result.get("secure_url")
            if secure_url:
                return secure_url

    except Exception as e:
        print(f"[Gemini AI Engine] generate_avatar_image_for_items error: {e}. Using fallback image URL.")

    # Return fallback image URL if Gemini generation or Cloudinary upload fails
    return fallback_image_url

