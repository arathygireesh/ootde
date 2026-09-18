# OOTDee Complete Source Codebase

This document contains all source code files across the Backend and Mobile apps.

## Table of Contents

- [backend\manage.py](#backendmanagepy)
- [backend\ootdee_core\settings.py](#backendootdeecoresettingspy)
- [backend\ootdee_core\urls.py](#backendootdeecoreurlspy)
- [backend\ootdee_core\asgi.py](#backendootdeecoreasgipy)
- [backend\ootdee_core\wsgi.py](#backendootdeecorewsgipy)
- [backend\authentication\models.py](#backendauthenticationmodelspy)
- [backend\authentication\serializers.py](#backendauthenticationserializerspy)
- [backend\authentication\urls.py](#backendauthenticationurlspy)
- [backend\authentication\views.py](#backendauthenticationviewspy)
- [backend\wardrobe\models.py](#backendwardrobemodelspy)
- [backend\wardrobe\serializers.py](#backendwardrobeserializerspy)
- [backend\wardrobe\urls.py](#backendwardrobeurlspy)
- [backend\wardrobe\views.py](#backendwardrobeviewspy)
- [backend\wardrobe\outfit_engine.py](#backendwardrobeoutfitenginepy)
- [backend\wardrobe\tests.py](#backendwardrobetestspy)
- [mobile\pubspec.yaml](#mobilepubspecyaml)
- [mobile\lib\main.dart](#mobilelibmaindart)
- [mobile\lib\core\api\api_service.dart](#mobilelibcoreapiapiservicedart)
- [mobile\lib\core\services\wardrobe_service.dart](#mobilelibcoreserviceswardrobeservicedart)
- [mobile\lib\core\theme\app_theme.dart](#mobilelibcorethemeappthemedart)
- [mobile\lib\features\auth\login_screen.dart](#mobilelibfeaturesauthloginscreendart)
- [mobile\lib\features\auth\register_screen.dart](#mobilelibfeaturesauthregisterscreendart)
- [mobile\lib\features\auth\splash_screen.dart](#mobilelibfeaturesauthsplashscreendart)
- [mobile\lib\features\auth\welcome_screen.dart](#mobilelibfeaturesauthwelcomescreendart)
- [mobile\lib\features\home\home_screen.dart](#mobilelibfeatureshomehomescreendart)
- [mobile\lib\features\wardrobe\add_wardrobe_screen.dart](#mobilelibfeatureswardrobeaddwardrobescreendart)
- [mobile\lib\features\wardrobe\history_screen.dart](#mobilelibfeatureswardrobehistoryscreendart)
- [mobile\lib\features\wardrobe\outfit_suggestion_screen.dart](#mobilelibfeatureswardrobeoutfitsuggestionscreendart)
- [mobile\lib\features\wardrobe\wardrobe_screen.dart](#mobilelibfeatureswardrobewardrobescreendart)

---

## backend\manage.py

`python
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    if BASE_DIR in sys.path:
        sys.path.remove(BASE_DIR)
    sys.path.insert(0, BASE_DIR)
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ootdee_core.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()

`

---

## backend\ootdee_core\settings.py

`python
"""
Django settings for ootdee_core project.
"""

from pathlib import Path
from datetime import timedelta
import os

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-6)1#o$7rqy4+_d!pl7e=z1d()8c#0m*7t+0_rglxtf+d_ka5#-'

DEBUG = True

ALLOWED_HOSTS = ['*']

AUTH_USER_MODEL = 'authentication.CustomUser'

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',

    # Local apps
    'authentication',
    'wardrobe',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=7),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'AUTH_HEADER_TYPES': ('Bearer',),
}

ROOT_URLCONF = 'ootdee_core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'ootdee_core.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

`

---

## backend\ootdee_core\urls.py

`python
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),
    path('api/wardrobe/', include('wardrobe.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

`

---

## backend\ootdee_core\asgi.py

`python
"""
ASGI config for ootdee_core project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/6.1/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ootdee_core.settings')

application = get_asgi_application()

`

---

## backend\ootdee_core\wsgi.py

`python
"""
WSGI config for ootdee_core project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/6.1/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ootdee_core.settings')

application = get_wsgi_application()

`

---

## backend\authentication\models.py

`python
from django.db import models
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):
    gender = models.CharField(
        max_length=20, 
        choices=[('male', 'Male'), ('female', 'Female'), ('other', 'Other')], 
        default='other'
    )
    preferred_style = models.CharField(max_length=50, blank=True, null=True)

    def __str__(self) -> str:
        return str(self.username or self.email or "User")

`

---

## backend\authentication\serializers.py

`python
from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=4)
    email = serializers.EmailField(required=False, allow_blank=True, default='')
    gender = serializers.CharField(required=False, allow_blank=True, default='other')
    preferred_style = serializers.CharField(required=False, allow_blank=True, default='')

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password', 'gender', 'preferred_style')

    def validate_username(self, value):
        import re
        # Convert spaces to underscores and remove disallowed chars
        sanitized = re.sub(r'\s+', '_', value.strip())
        sanitized = re.sub(r'[^a-zA-Z0-9@/./+/-/_]', '', sanitized)
        if not sanitized:
            raise serializers.ValidationError("Please enter a valid name.")
        return sanitized

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            gender=validated_data.get('gender', 'other'),
            preferred_style=validated_data.get('preferred_style', '')
        )
        return user

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'gender', 'preferred_style')

`

---

## backend\authentication\urls.py

`python
from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, UserProfileView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', UserProfileView.as_view(), name='user_profile'),
]

`

---

## backend\authentication\views.py

`python
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .serializers import RegisterSerializer, UserSerializer

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        refresh = RefreshToken.for_user(user)
        return Response({
            "user": UserSerializer(user).data,
            "access": str(refresh.access_token),
            "refresh": str(refresh),
        })

class UserProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = (permissions.IsAuthenticated,)
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

`

---

## backend\wardrobe\models.py

`python
from django.db import models
from django.conf import settings

class WardrobeItem(models.Model):
    CATEGORY_CHOICES = (
        ('Tops', 'Tops'),
        ('Bottoms', 'Bottoms'),
        ('Dresses', 'Dresses'),
        ('Jumpsuit', 'Jumpsuit'),
        ('Jeggings', 'Jeggings'),
        ('Kurta', 'Kurta'),
        ('Jacket', 'Jacket'),
        ('Shorts', 'Shorts'),
        ('Outerwear', 'Outerwear'),
        ('Lehanga', 'Lehanga'),
        ('Saree', 'Saree'),
        ('Shoes', 'Shoes'),
        ('Accessories', 'Accessories'),
    )

    SEASON_CHOICES = (
        ('All', 'All'),
        ('Summer', 'Summer'),
        ('Winter', 'Winter'),
        ('Fall', 'Fall'),
        ('Spring', 'Spring'),
    )

    OCCASION_CHOICES = (
        ('Casual', 'Casual'),
        ('Formal', 'Formal'),
        ('Party', 'Party'),
        ('Workout', 'Workout'),
        ('Work', 'Work'),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wardrobe_items'
    )
    name = models.CharField(max_length=100)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='Tops')
    color = models.CharField(max_length=50, default='Black')
    season = models.CharField(max_length=20, choices=SEASON_CHOICES, default='All')
    occasion = models.CharField(max_length=20, choices=OCCASION_CHOICES, default='Casual')
    image = models.ImageField(upload_to='wardrobe_items/', null=True, blank=True)
    image_url = models.URLField(max_length=500, null=True, blank=True)
    times_worn = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.category}) - {self.user.username}"


class Outfit(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='outfits'
    )
    title = models.CharField(max_length=150)
    occasion = models.CharField(max_length=50)
    items = models.ManyToManyField(WardrobeItem, related_name='outfits')
    ai_generated_image_url = models.TextField(null=True, blank=True)
    styling_advice = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.occasion}) - {self.user.username}"


`

---

## backend\wardrobe\serializers.py

`python
from rest_framework import serializers
from .models import WardrobeItem, Outfit

class WardrobeItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = WardrobeItem
        fields = (
            'id',
            'user',
            'name',
            'category',
            'color',
            'season',
            'occasion',
            'image',
            'image_url',
            'times_worn',
            'created_at',
        )
        read_only_fields = ('id', 'user', 'created_at')


class OutfitSerializer(serializers.ModelSerializer):
    items = WardrobeItemSerializer(many=True, read_only=True)

    class Meta:
        model = Outfit
        fields = (
            'id',
            'user',
            'title',
            'occasion',
            'items',
            'ai_generated_image_url',
            'styling_advice',
            'created_at',
        )
        read_only_fields = ('id', 'user', 'created_at')


`

---

## backend\wardrobe\urls.py

`python
from django.urls import path
from .views import (
    WardrobeItemListCreateView,
    WardrobeItemDetailView,
    SuggestOutfitOptionsView,
    GenerateAvatarOutfitView,
    OutfitHistoryListView,
)

urlpatterns = [
    path('items/', WardrobeItemListCreateView.as_view(), name='wardrobe-list-create'),
    path('items/<int:pk>/', WardrobeItemDetailView.as_view(), name='wardrobe-detail'),
    path('suggest-options/', SuggestOutfitOptionsView.as_view(), name='suggest-options'),
    path('generate-avatar/', GenerateAvatarOutfitView.as_view(), name='generate-avatar'),
    path('history/', OutfitHistoryListView.as_view(), name='outfit-history'),
]

`

---

## backend\wardrobe\views.py

`python
from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import WardrobeItem, Outfit
from .serializers import WardrobeItemSerializer, OutfitSerializer
from .outfit_engine import get_outfit_text_suggestions, generate_avatar_image_for_items

class WardrobeItemListCreateView(generics.ListCreateAPIView):
    serializer_class = WardrobeItemSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        queryset = WardrobeItem.objects.filter(user=self.request.user)
        category = self.request.query_params.get('category', None)
        if category and category != 'All':
            queryset = queryset.filter(category__iexact=category)
        return queryset.order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class WardrobeItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = WardrobeItemSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return WardrobeItem.objects.filter(user=self.request.user)

class SuggestOutfitOptionsView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        occasion = request.data.get('occasion', 'Casual')
        options = get_outfit_text_suggestions(request.user, occasion)
        return Response({"occasion": occasion, "options": options}, status=status.HTTP_200_OK)

class GenerateAvatarOutfitView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        occasion = request.data.get('occasion', 'Casual')
        item_ids = request.data.get('item_ids', [])
        outfit = generate_avatar_image_for_items(request.user, occasion, item_ids)
        serializer = OutfitSerializer(outfit)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class OutfitHistoryListView(generics.ListAPIView):
    serializer_class = OutfitSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Outfit.objects.filter(user=self.request.user).order_by('-created_at')

`

---

## backend\wardrobe\outfit_engine.py

`python
import os
import random
import requests
from django.conf import settings
from .models import WardrobeItem, Outfit

def get_outfit_text_suggestions(user, occasion):
    """
    Generates 3 distinct text outfit combinations built strictly from the user's uploaded wardrobe items.
    Tailors selections to traditional/ethnic for Marriage/Functions, professional for Work/College, etc.
    """
    user_items = list(WardrobeItem.objects.filter(user=user))
    if not user_items:
        # Fallback preset suggestions if user has zero items added yet
        return [
            {
                "id": "opt_1",
                "title": f"Chic {occasion.capitalize()} Combo",
                "description": f"Custom selection tailored for {occasion}",
                "item_ids": [],
                "item_summary": ["Silk Blouse / Top", "Tailored Trousers", "Accessories"]
            },
            {
                "id": "opt_2",
                "title": f"Elegant {occasion.capitalize()} Traditional",
                "description": f"Graceful traditional wear for {occasion}",
                "item_ids": [],
                "item_summary": ["Red Saree & Yellow Blouse", "Gold Jewelry"]
            },
            {
                "id": "opt_3",
                "title": f"Modern {occasion.capitalize()} Look",
                "description": f"Trendy versatile style for {occasion}",
                "item_ids": [],
                "item_summary": ["Kurta & Jeggings", "Statement Clutch"]
            }
        ]

    traditional_categories = ['Saree', 'Lehanga', 'Kurta', 'Dresses', 'Jumpsuit']
    casual_categories = ['Tops', 'Bottoms', 'Jacket', 'Shorts', 'Jeggings']

    occ_lower = occasion.lower()
    is_traditional = any(word in occ_lower for word in ['marriage', 'wedding', 'ethnic', 'function', 'puja', 'festival', 'party'])

    suggestions = []
    
    # Combination 1: Category Priority (Traditional or Casual)
    target_cats = traditional_categories if is_traditional else casual_categories
    matching_primary = [i for i in user_items if i.category in target_cats]
    if not matching_primary:
        matching_primary = user_items

    item1 = random.choice(matching_primary)
    combo1_items = [item1]
    
    # Try adding complementary bottom/shoes/accessories
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

    # Combination 2: Alternate styling
    remaining = [i for i in user_items if i.id not in [x.id for x in combo1_items]]
    pool2 = remaining if len(remaining) >= 2 else user_items
    item2 = random.choice(pool2)
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

    # Combination 3: Statement look
    pool3 = [i for i in user_items if i.id not in [x.id for x in combo1_items + combo2_items]]
    if not pool3:
        pool3 = user_items
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

def generate_avatar_image_for_items(user, occasion, item_ids):
    """
    Takes the user's selected wardrobe item IDs and calls Gemini API (Imagen 3) to generate
    a female avatar studio portrait wearing the exact wardrobe combination. Saves outfit to history.
    """
    selected_items = list(WardrobeItem.objects.filter(id__in=item_ids))
    if not selected_items:
        # Fallback if no item IDs provided
        selected_items = list(WardrobeItem.objects.filter(user=user)[:3])

    item_names = [f"{item.color} {item.name} ({item.category})" for item in selected_items]
    items_desc = ", ".join(item_names) if item_names else "stylish outfit"

    title = f"{occasion.capitalize()} Avatar Look"
    styling_advice = f"Female model avatar styled in your selected wardrobe pieces: {items_desc} for {occasion}."

    image_url = _generate_gemini_avatar_prompt(occasion, selected_items)

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

def _generate_gemini_avatar_prompt(occasion, selected_items):
    """
    Calls Google Gemini Imagen API to generate a high quality female avatar wearing user outfit.
    """
    item_descs = [f"{item.color} {item.category.lower()} ({item.name})" for item in selected_items]
    outfit_text = " paired with ".join(item_descs) if item_descs else "chic outfit"

    prompt = (
        f"High fashion studio portrait of an attractive female model avatar wearing an outfit composed of: {outfit_text}. "
        f"The setting is tailored for a {occasion} occasion. Full body shot, elegant poses, warm studio lighting, 8k resolution."
    )

    gemini_api_key = getattr(settings, 'GEMINI_API_KEY', os.getenv('GEMINI_API_KEY', None))

    if gemini_api_key:
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key={gemini_api_key}"
            payload = {
                "instances": [{"prompt": prompt}],
                "parameters": {"sampleCount": 1, "aspectRatio": "1:1"}
            }
            res = requests.post(url, json=payload, timeout=10)
            if res.status_code == 200:
                data = res.json()
                predictions = data.get("predictions", [])
                if predictions and "bytesBase64Encoded" in predictions[0]:
                    b64 = predictions[0]["bytesBase64Encoded"]
                    return f"data:image/png;base64,{b64}"
        except Exception:
            pass

    # High resolution fashion model portrait visual fallback
    return "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80"

`

---

## backend\wardrobe\tests.py

`python
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from .models import WardrobeItem, Outfit

User = get_user_model()

class OutfitSuggestionTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='fashionista',
            password='testpassword123',
            email='fashion@ootdee.com'
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

        # Create test items in user's wardrobe
        WardrobeItem.objects.create(
            user=self.user,
            name='Purple Silk Top',
            category='Tops',
            color='Lavender',
            occasion='Casual'
        )
        WardrobeItem.objects.create(
            user=self.user,
            name='White Denim Trousers',
            category='Bottoms',
            color='White',
            occasion='Casual'
        )
        WardrobeItem.objects.create(
            user=self.user,
            name='Beige Leather Heels',
            category='Shoes',
            color='Beige',
            occasion='Casual'
        )

    def test_suggest_outfit_endpoint(self):
        response = self.client.post('/api/wardrobe/suggest-outfit/', {'occasion': 'Casual'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('title', response.data)
        self.assertIn('items', response.data)
        self.assertGreaterEqual(len(response.data['items']), 1)
        # Verify items are from the logged-in user's wardrobe
        for item in response.data['items']:
            self.assertEqual(item['user'], self.user.id)

`

---

## mobile\pubspec.yaml

`yaml
name: ootdee_app
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  dio: ^5.11.0
  flutter_secure_storage: ^11.0.0
  image_picker: ^1.2.3
  google_fonts: ^8.2.1
  flutter_animate: ^4.5.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
    - assets/images/logo.png

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

`

---

## mobile\lib\main.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: OOTDeeApp()));
}

class OOTDeeApp extends StatelessWidget {
  const OOTDeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOTDee - Smart Digital Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

`

---

## mobile\lib\core\api\api_service.dart

`dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return 'http://10.204.47.10:8000/api';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await Dio().post(
                  '$baseUrl/auth/token/refresh/',
                  data: {'refresh': refreshToken},
                );
                final newAccess = response.data['access'];
                await _storage.write(key: 'access_token', value: newAccess);

                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (_) {
                await _storage.deleteAll();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _dio.post('/auth/login/', data: {
      'username': username,
      'password': password,
    });
    await _storage.write(key: 'access_token', value: res.data['access']);
    await _storage.write(key: 'refresh_token', value: res.data['refresh']);
    return res.data;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String email = '',
    String gender = 'female',
    String preferredStyle = '',
  }) async {
    final res = await _dio.post('/auth/register/', data: {
      'username': username,
      'password': password,
      'email': email,
      'gender': gender,
      'preferred_style': preferredStyle,
    });
    await _storage.write(key: 'access_token', value: res.data['access']);
    await _storage.write(key: 'refresh_token', value: res.data['refresh']);
    return res.data;
  }

  Future<List<dynamic>> getWardrobe({String? category}) async {
    final params = (category != null && category != 'All') ? {'category': category} : null;
    final res = await _dio.get('/wardrobe/items/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> suggestOutfitOptions({required String occasion}) async {
    final res = await _dio.post('/wardrobe/suggest-options/', data: {
      'occasion': occasion,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> generateAvatarOutfit({
    required String occasion,
    required List<dynamic> itemIds,
  }) async {
    final res = await _dio.post('/wardrobe/generate-avatar/', data: {
      'occasion': occasion,
      'item_ids': itemIds,
    });
    return res.data;
  }

  Future<List<dynamic>> getOutfitHistory() async {
    final res = await _dio.get('/wardrobe/history/');
    return res.data as List<dynamic>;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}

`

---

## mobile\lib\core\services\wardrobe_service.dart

`dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';

final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  return WardrobeService(ref.read(apiServiceProvider));
});

class WardrobeItemModel {
  final int id;
  final String name;
  final String category;
  final String color;
  final String season;
  final String occasion;
  final String? image;
  final String? imageUrl;
  final int timesWorn;
  final DateTime createdAt;

  WardrobeItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.occasion,
    this.image,
    this.imageUrl,
    required this.timesWorn,
    required this.createdAt,
  });

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    return WardrobeItemModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? 'Tops',
      color: json['color'] ?? 'Black',
      season: json['season'] ?? 'All',
      occasion: json['occasion'] ?? 'Casual',
      image: json['image'],
      imageUrl: json['image_url'],
      timesWorn: json['times_worn'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WardrobeService {
  final ApiService _apiService;

  WardrobeService(this._apiService);

  ApiService get apiService => _apiService;

  Future<List<WardrobeItemModel>> getWardrobeItems({String? category}) async {
    try {
      final items = await _apiService.getWardrobe(category: category);
      return items.map((e) => WardrobeItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}

`

---

## mobile\lib\core\theme\app_theme.dart

`dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette: Purple & White
  static const Color primaryPurple = Color(0xFF6B21A8); // Deep vibrant purple
  static const Color accentPurple = Color(0xFF9333EA);  // Bright purple accent
  static const Color lightPurpleBackground = Color(0xFFFAF5FF); // Subtle soft purple white
  static const Color darkPurple = Color(0xFF3B0764);
  static const Color surfaceWhite = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: surfaceWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentPurple,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E1B4B),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryPurple,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkPurple,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF374151),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF4B5563),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightPurpleBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9D5FF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        prefixIconColor: primaryPurple,
      ),
    );
  }
}

`

---

## mobile\lib\features\auth\login_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/api/api_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

final authServiceProvider = Provider((ref) => ApiService());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(authServiceProvider);
      await api.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['detail'] ?? 'Invalid username or password';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6B21A8)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo & Brand
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withValues(alpha: 0.12),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ).animate().scale(duration: 500.ms),

                      const SizedBox(height: 12),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'OOTD',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Color(0xFF6B21A8),
                              ),
                            ),
                            TextSpan(
                              text: 'ee',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Color(0xFF9333EA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B0764),
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 6),

                const Text(
                  'Log in to access your digital wardrobe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B21A8),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 28),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF87171)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your username' : null,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF6B21A8),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter your password' : null,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Login Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Login'),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 24),

                // Go to Register option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF6B21A8)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF9333EA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

`

---

## mobile\lib\features\auth\register_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../wardrobe/add_wardrobe_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedGender = 'female';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'female', 'label': 'Female', 'icon': Icons.female_rounded},
    {'value': 'male', 'label': 'Male', 'icon': Icons.male_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.person_outline_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 6) score += 0.33;
    if (password.length >= 8 && RegExp(r'[A-Z]').hasMatch(password)) score += 0.33;
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>.]').hasMatch(password)) score += 0.34;
    return score.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.34) return const Color(0xFFEF4444);
    if (strength <= 0.67) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStrengthText(double strength) {
    if (strength == 0) return '';
    if (strength <= 0.34) return 'Weak password';
    if (strength <= 0.67) return 'Medium strength';
    return 'Strong password';
  }

  void _handleSaveAndRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawName = _nameController.text.trim();
      final sanitizedUsername = rawName.replaceAll(RegExp(r'\s+'), '_');

      final api = ref.read(authServiceProvider);
      await api.register(
        username: sanitizedUsername,
        password: _passwordController.text,
        gender: _selectedGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Details Saved! Now let\'s add your wardrobe items.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6B21A8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
        );
      }
    } on DioException catch (e) {
      setState(() {
        final data = e.response?.data;
        if (data is Map) {
          final usernameErr = data['username'] is List ? data['username'][0] : data['username'];
          final passwordErr = data['password'] is List ? data['password'][0] : data['password'];
          final detailErr = data['detail'];
          final nonFieldErr = data['non_field_errors'] is List ? data['non_field_errors'][0] : null;
          
          _errorMessage = usernameErr?.toString() ??
              passwordErr?.toString() ??
              detailErr?.toString() ??
              nonFieldErr?.toString() ??
              'Registration failed. Please check your details.';
        } else {
          _errorMessage = 'Registration failed: ${e.message ?? "Connection error"}';
        }
      });
    } catch (e) {
      // If offline/demo mode, proceed to AddWardrobeScreen directly for user testing
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Purple Header Banner
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B0764),
                        Color(0xFF6B21A8),
                        Color(0xFF9333EA),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),

                              // Step 1 Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.person_pin_rounded, color: Color(0xFFFDE047), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Step 1: Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Create Account ✨',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in your details and tap Save to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),

                // Decorative Ambient Glow Orb
                Positioned(
                  right: -30,
                  top: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Registration Form Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error Alert Banner
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().shake(),
                          const SizedBox(height: 18),
                        ],

                        // 1. Name Field
                        _buildLabel('Name'),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _buildInputDecoration(
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your name';
                            if (val.trim().length < 2) return 'Name must be at least 2 characters';
                            return null;
                          },
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 20),

                        // 2. Password Field
                        _buildLabel('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.done,
                          decoration: _buildInputDecoration(
                            hint: 'Create a password',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF6B21A8),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter a password';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ).animate().fadeIn(delay: 150.ms),

                        // Password Strength Meter
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: passwordStrength,
                                    minHeight: 5,
                                    backgroundColor: const Color(0xFFE9D5FF),
                                    valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(passwordStrength)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _getStrengthText(passwordStrength),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStrengthColor(passwordStrength),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(),
                        ],

                        const SizedBox(height: 22),

                        // 3. Gender Selection
                        _buildLabel('Gender'),
                        Row(
                          children: _genderOptions.map((option) {
                            final isSelected = _selectedGender == option['value'];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedGender = option['value']),
                                  borderRadius: BorderRadius.circular(16),
                                  child: AnimatedContainer(
                                    duration: 200.ms,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF6B21A8) : const Color(0xFFFAF5FF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF6B21A8).withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          option['icon'] as IconData,
                                          size: 18,
                                          color: isSelected ? Colors.white : const Color(0xFF6B21A8),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          option['label'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF3B0764),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 32),

                        // SAVE Button (Purple Gradient) -> Navigates to AddWardrobeScreen
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveAndRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ).animate().fadeIn(delay: 250.ms).scale(begin: const Offset(0.95, 0.95)),

                        const SizedBox(height: 24),

                        // Back to Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFF9333EA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF9333EA),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B0764),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF6B21A8).withValues(alpha: 0.4),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6B21A8), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFAF5FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9D5FF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
    );
  }
}

`

---

## mobile\lib\features\auth\splash_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../wardrobe/add_wardrobe_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      final Widget targetScreen = (token != null && token.isNotEmpty)
          ? const AddWardrobeScreen()
          : const WelcomeScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext meContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Elegant decorative subtle background circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3E8FF).withValues(alpha: 0.6),
              ),
            ),
          ).animate().scale(duration: 1200.ms, curve: Curves.easeOut),

          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFAF5FF),
              ),
            ),
          ).animate().scale(duration: 1500.ms, curve: Curves.easeOut),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Image with Scale + Pulse
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 8,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeIn)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 1000.ms,
                      curve: Curves.elasticOut,
                    )
                    .shimmer(delay: 1200.ms, duration: 1500.ms, color: const Color(0xFFD8B4FE)),

                const SizedBox(height: 28),

                // Animated App Title "OOTDee"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'OOTD',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: const Color(0xFF6B21A8),
                        ),
                      ),
                      TextSpan(
                        text: 'ee',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.4, end: 0, duration: 800.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                // Tagline with Fade In
                Text(
                  'Your AI Smart Wardrobe & Outfit Stylist',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

`

---

## mobile\lib\features\auth\welcome_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(),

              // Logo & App Name Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3E8FF), width: 2),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 20),

              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'OOTD',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF6B21A8),
                      ),
                    ),
                    TextSpan(
                      text: 'ee',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF9333EA),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 8),

              Text(
                'Style Smarter, Wear Better',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B21A8).withValues(alpha: 0.75),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const Spacer(),

              // Action Buttons Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

`

---

## mobile\lib\features\home\home_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/welcome_screen.dart';
import '../auth/login_screen.dart';
import '../wardrobe/wardrobe_screen.dart';
import '../wardrobe/outfit_suggestion_screen.dart';
import '../wardrobe/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WardrobeScreen(),
    const OutfitSuggestionScreen(),
    const HistoryScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF6B21A8),
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_rounded),
              label: 'My Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'Today\'s Outfit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile 👤',
          style: TextStyle(color: Color(0xFF3B0764), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9333EA).withValues(alpha: 0.25),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Stylist User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B0764),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personal Wardrobe & Gemini AI Stylist',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF6B21A8).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3E8FF)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 28),
                        SizedBox(height: 8),
                        Text(
                          '12 Items',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B0764)),
                        ),
                        SizedBox(height: 2),
                        Text('In My Closet', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3E8FF)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.history_rounded, color: Color(0xFF9333EA), size: 28),
                        SizedBox(height: 8),
                        Text(
                          '8 Outfits',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B0764)),
                        ),
                        SizedBox(height: 2),
                        Text('Saved History', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // Personal Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3E8FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Details 📋',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B0764)),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileRow(Icons.person_outline, 'Gender Preference', 'Female Fashion'),
                  const Divider(height: 20),
                  _buildProfileRow(Icons.style_outlined, 'Style Vibe', 'Traditional & Modern Mix'),
                  const Divider(height: 20),
                  _buildProfileRow(Icons.color_lens_outlined, 'Favorite Colors', 'Purple, Red, Pink, Blue'),
                  const Divider(height: 20),
                  _buildProfileRow(Icons.security_outlined, 'Account Security', 'Protected'),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await ref.read(authServiceProvider).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                label: const Text(
                  'Logout of OOTDee',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B21A8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B0764)),
        ),
      ],
    );
  }
}

`

---

## mobile\lib\features\wardrobe\add_wardrobe_screen.dart

`dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home/home_screen.dart';

class WardrobeItemManual {
  final String id;
  final String imagePath;
  String name;
  String category;
  String color;
  String season;
  String occasion;

  WardrobeItemManual({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.occasion,
  });
}

class AddWardrobeScreen extends StatefulWidget {
  const AddWardrobeScreen({super.key});

  @override
  State<AddWardrobeScreen> createState() => _AddWardrobeScreenState();
}

class _AddWardrobeScreenState extends State<AddWardrobeScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<WardrobeItemManual> _wardrobeItems = [];
  String _selectedCategoryFilter = 'All';

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Jumpsuit',
    'Jeggings',
    'Kurta',
    'Jacket',
    'Shorts',
    'Outerwear',
    'lehanga',
    'saree',
    'Shoes',
    'Accessories',
  ];

  final List<String> _seasons = ['All', 'Summer', 'Winter', 'Fall', 'Spring'];
  final List<String> _occasions = ['Casual', 'Formal', 'Party', 'Workout', 'Work'];

  final List<Map<String, dynamic>> _popularColors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': const Color(0xFFEF4444)},
    {'name': 'Blue', 'color': const Color(0xFF3B82F6)},
    {'name': 'Pink', 'color': const Color(0xFFEC4899)},
    {'name': 'Green', 'color': const Color(0xFF10B981)},
    {'name': 'Yellow', 'color': const Color(0xFFF59E0B)},
    {'name': 'Purple', 'color': const Color(0xFF9333EA)},
    {'name': 'Beige', 'color': const Color(0xFFD97706)},
    {'name': 'Navy', 'color': const Color(0xFF1E3A8A)},
    {'name': 'Orange', 'color': const Color(0xFFEA580C)},
  ];

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        _showAddItemDialog(response.file!.path);
      }
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          for (var img in images) {
            await _showAddItemDialog(img.path);
          }
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          _showAddItemDialog(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/gallery: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _showAddItemDialog(String imagePath, {WardrobeItemManual? existingItem}) async {
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final colorController = TextEditingController(text: existingItem?.color ?? 'Purple');
    String category = existingItem?.category ?? 'Tops';
    String season = existingItem?.season ?? 'All';
    String occasion = existingItem?.occasion ?? 'Casual';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingItem == null ? 'Add Dress / Cloth Details 👗' : 'Edit Dress Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B0764),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF6B21A8)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Image Thumbnail Preview
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(imagePath),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 110,
                              height: 110,
                              color: const Color(0xFFFAF5FF),
                              child: const Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Dress / Item Name Input
                      _buildLabel('Dress / Item Name'),
                      TextFormField(
                        controller: nameController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g., Purple Silk Blouse, Blue Jeans',
                          icon: Icons.label_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter an item name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // 2. Cloth Type / Category
                      _buildLabel('Cloth Type / Category'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.where((c) => c != 'All').map((cat) {
                          final isSel = category == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            selectedColor: const Color(0xFF6B21A8),
                            backgroundColor: const Color(0xFFFAF5FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFF6B21A8),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => category = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 3. Color Selection / Input
                      _buildLabel('Color'),
                      TextFormField(
                        controller: colorController,
                        decoration: _buildInputDecoration(
                          hint: 'Enter or select color (e.g. Lavender, Black)',
                          icon: Icons.palette_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter or select a color';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Quick Palette Color Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _popularColors.map((col) {
                          final isSel = colorController.text.toLowerCase() == (col['name'] as String).toLowerCase();
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                colorController.text = col['name'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFFAF5FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: col['color'] as Color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    col['name'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSel ? Colors.white : const Color(0xFF3B0764),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 4. Season & Occasion
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Season'),
                                DropdownButtonFormField<String>(
                                  initialValue: season,
                                  decoration: _buildInputDecoration(hint: 'Season', icon: Icons.wb_sunny_outlined),
                                  items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => season = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Occasion'),
                                DropdownButtonFormField<String>(
                                  initialValue: occasion,
                                  decoration: _buildInputDecoration(hint: 'Occasion', icon: Icons.event_outlined),
                                  items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => occasion = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            setState(() {
                              if (existingItem != null) {
                                existingItem.name = nameController.text.trim();
                                existingItem.category = category;
                                existingItem.color = colorController.text.trim();
                                existingItem.season = season;
                                existingItem.occasion = occasion;
                              } else {
                                _wardrobeItems.add(
                                  WardrobeItemManual(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    imagePath: imagePath,
                                    name: nameController.text.trim(),
                                    category: category,
                                    color: colorController.text.trim(),
                                    season: season,
                                    occasion: occasion,
                                  ),
                                );
                              }
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${nameController.text.trim()}" to your wardrobe!'),
                                backgroundColor: const Color(0xFF6B21A8),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Save Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _removeItem(String id) {
    setState(() {
      _wardrobeItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _selectedCategoryFilter == 'All'
        ? _wardrobeItems
        : _wardrobeItems.where((i) => i.category == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Purple Banner Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B0764),
                        Color(0xFF6B21A8),
                        Color(0xFF9333EA),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Add Wardrobe Items',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Skip for now',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Add Your Wardrobe 👗',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            'Upload dress photos from your gallery & manually tag color and cloth type',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Options (From Gallery / Take Photo)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Select Dress Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick from your phone gallery, then enter color & cloth type manually',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B21A8).withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          // Gallery Button
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickImage(ImageSource.gallery),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE9D5FF),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_rounded,
                                      color: Color(0xFF6B21A8),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add from Gallery',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Camera Button
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickImage(ImageSource.camera),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE9D5FF),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color(0xFF9333EA),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Take Photo',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),
          ),

          // Category Filter Horizontal Scroll
          if (_wardrobeItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Added Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B0764),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B21A8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_wardrobeItems.length} Items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSel = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              selectedColor: const Color(0xFF6B21A8),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                              ),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF6B21A8),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategoryFilter = cat;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Grid View of Added Items
          if (filteredItems.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF3E8FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail + Category Tag + Delete Button
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFFF3E8FF),
                                      child: const Center(
                                        child: Icon(
                                          Icons.checkroom_rounded,
                                          color: Color(0xFF6B21A8),
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Category Tag Badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B21A8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Delete Button
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removeItem(item.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF3B0764),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '🎨 ${item.color}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B21A8).withValues(alpha: 0.85),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showAddItemDialog(item.imagePath, existingItem: item),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9333EA),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),

          // Save & Proceed Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wardrobe items saved successfully! Welcome to OOTDee.'),
                        backgroundColor: Color(0xFF6B21A8),
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save & Continue to Wardrobe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B0764),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF6B21A8).withValues(alpha: 0.4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6B21A8), size: 18),
      filled: true,
      fillColor: const Color(0xFFFAF5FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9D5FF), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
      ),
    );
  }
}

`

---

## mobile\lib\features\wardrobe\history_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/api/api_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final list = await api.getOutfitHistory();
      if (mounted) {
        setState(() {
          _historyList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Demo fallback history data if offline
          _historyList = [
            {
              'id': 1,
              'title': 'Marriage Function Elegance',
              'occasion': 'Marriage',
              'created_at': '2026-08-17T18:30:00Z',
              'ai_generated_image_url': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80',
              'styling_advice': 'Selected Red Saree & Yellow Blouse with traditional gold bangles.',
              'items': [
                {'name': 'Red Saree', 'category': 'Saree', 'color': 'Red'},
                {'name': 'Yellow Silk Blouse', 'category': 'Tops', 'color': 'Yellow'},
              ]
            },
            {
              'id': 2,
              'title': 'College Casual Vibe',
              'occasion': 'College',
              'created_at': '2026-08-16T09:15:00Z',
              'ai_generated_image_url': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&auto=format&fit=crop&q=80',
              'styling_advice': 'Comfortable Kurta paired with Jeggings.',
              'items': [
                {'name': 'Lavender Kurta', 'category': 'Kurta', 'color': 'Lavender'},
                {'name': 'White Jeggings', 'category': 'Jeggings', 'color': 'White'},
              ]
            }
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Outfit History 📜',
          style: TextStyle(
            color: Color(0xFF3B0764),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B21A8)),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B21A8)),
            )
          : _historyList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_toggle_off_rounded, size: 64, color: Color(0xFFC084FC)),
                      const SizedBox(height: 16),
                      const Text(
                        'No Saved Outfit History Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate & save your daily outfits to track your fashion history!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF6B21A8).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final item = _historyList[index];
                    final title = item['title'] ?? 'Daily Outfit';
                    final occasion = item['occasion'] ?? 'Casual';
                    final imageUrl = item['ai_generated_image_url'] as String?;
                    final advice = item['styling_advice'] ?? '';
                    final items = (item['items'] as List<dynamic>?) ?? [];
                    final dateStr = item['created_at'] != null
                        ? item['created_at'].toString().split('T').first
                        : 'Today';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF3E8FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Occasion & Date
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6B21A8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        occasion,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF6B21A8).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Generated Female Avatar Outfit Image
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              child: AspectRatio(
                                aspectRatio: 1.2,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFFAF5FF),
                                    child: const Center(
                                      child: Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 48),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Item tags & advice
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (items.isNotEmpty) ...[
                                  const Text(
                                    'Selected Wardrobe Pieces:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B0764),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: items.map((it) {
                                      final name = it['name'] ?? '';
                                      final col = it['color'] ?? '';
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAF5FF),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFE9D5FF)),
                                        ),
                                        child: Text(
                                          '$col $name',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6B21A8),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  advice,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms);
                  },
                ),
    );
  }
}

`

---

## mobile\lib\features\wardrobe\outfit_suggestion_screen.dart

`dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/api/api_service.dart';

class OutfitSuggestionScreen extends ConsumerStatefulWidget {
  final String initialOccasion;
  const OutfitSuggestionScreen({super.key, this.initialOccasion = 'Marriage'});

  @override
  ConsumerState<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
}

class _OutfitSuggestionScreenState extends ConsumerState<OutfitSuggestionScreen> {
  final TextEditingController _occasionController = TextEditingController();
  late String _selectedOccasion;
  
  bool _isFetchingOptions = false;
  bool _isGeneratingAvatar = false;

  List<dynamic> _textOptions = [];
  Map<String, dynamic>? _selectedOption;
  Map<String, dynamic>? _generatedAvatarData;

  final List<String> _popularOccasions = [
    'Marriage',
    'College',
    'Party',
    'Work',
    'Casual',
    'Date Night',
    'Festival',
  ];

  @override
  void initState() {
    super.initState();
    _selectedOccasion = widget.initialOccasion;
    _occasionController.text = _selectedOccasion;
    _fetchTextOptions();
  }

  @override
  void dispose() {
    _occasionController.dispose();
    super.dispose();
  }

  // Step 1 & 2: Fetch 3 text suggestions built strictly from user wardrobe
  Future<void> _fetchTextOptions() async {
    setState(() {
      _isFetchingOptions = true;
      _textOptions = [];
      _selectedOption = null;
      _generatedAvatarData = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final res = await api.suggestOutfitOptions(occasion: _selectedOccasion);
      if (mounted) {
        setState(() {
          _textOptions = (res['options'] as List<dynamic>?) ?? [];
          _isFetchingOptions = false;
        });
      }
    } catch (e) {
      // Offline demo fallback options built from user wardrobe categories
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _textOptions = [
            {
              'id': 'opt_1',
              'title': '1. Pink Churidhar & Silver Dupatta',
              'description': 'Traditional elegant ensemble from your wardrobe',
              'item_ids': [101, 102],
              'item_summary': ['Pink Churidhar', 'Silver Dupatta', 'Jhumkas']
            },
            {
              'id': 'opt_2',
              'title': '2. Red Saree & Yellow Blouse',
              'description': 'Vibrant traditional marriage contrast from your wardrobe',
              'item_ids': [103, 104],
              'item_summary': ['Red Silk Saree', 'Yellow Embroidered Blouse', 'Gold Accessories']
            },
            {
              'id': 'opt_3',
              'title': '3. Green Saree & Red Blouse',
              'description': 'Classic graceful festive pairing from your wardrobe',
              'item_ids': [105, 106],
              'item_summary': ['Green Kanjivaram Saree', 'Red Silk Blouse']
            },
          ];
          _isFetchingOptions = false;
        });
      }
    }
  }

  // Step 3 & 4: Generate Female Avatar Image for selected option
  Future<void> _generateAvatarImage() async {
    if (_selectedOption == null) return;

    setState(() {
      _isGeneratingAvatar = true;
      _generatedAvatarData = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final itemIds = (_selectedOption!['item_ids'] as List<dynamic>?) ?? [];
      final result = await api.generateAvatarOutfit(
        occasion: _selectedOccasion,
        itemIds: itemIds,
      );

      if (mounted) {
        setState(() {
          _generatedAvatarData = result;
          _isGeneratingAvatar = false;
        });
      }
    } catch (e) {
      // Demo avatar rendering fallback
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        setState(() {
          _generatedAvatarData = {
            'id': 999,
            'title': _selectedOption!['title'],
            'occasion': _selectedOccasion,
            'ai_generated_image_url': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&auto=format&fit=crop&q=80',
            'styling_advice': 'Female avatar rendered wearing your selected "${_selectedOption!['title']}" with matching accessories for $_selectedOccasion.',
          };
          _isGeneratingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B0764),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFE9D5FF), size: 20),
            SizedBox(width: 8),
            Text(
              'Today\'s Outfit Stylist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Step 1 Header: Occasion Input
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF3B0764),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1: Select or Type Occasion 🎯',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _occasionController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'e.g. Marriage, College, Party, Work...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search_rounded, color: Colors.white),
                        onPressed: () {
                          if (_occasionController.text.trim().isNotEmpty) {
                            setState(() {
                              _selectedOccasion = _occasionController.text.trim();
                            });
                            _fetchTextOptions();
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick Occasion Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _popularOccasions.map((occ) {
                        final isSel = _selectedOccasion.toLowerCase() == occ.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(occ),
                            selected: isSel,
                            selectedColor: const Color(0xFF9333EA),
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            side: BorderSide(
                              color: isSel ? const Color(0xFFC084FC) : Colors.white.withValues(alpha: 0.2),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedOccasion = occ;
                                  _occasionController.text = occ;
                                });
                                _fetchTextOptions();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Step 2 & 3 Body: Text Options built strictly from user's wardrobe
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Step 2: Choose Gemini Outfit Suggestion 👗',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                      if (_isFetchingOptions)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B21A8)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gemini analyzed your wardrobe and generated options strictly from your items:',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_isFetchingOptions)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Gemini is reading your wardrobe items...',
                          style: TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _textOptions.map((opt) {
                        final isSelected = _selectedOption?['id'] == opt['id'];
                        final title = opt['title'] ?? 'Outfit Combination';
                        final desc = opt['description'] ?? '';
                        final items = (opt['item_summary'] as List<dynamic>?) ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF9333EA) : const Color(0xFFE9D5FF),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B21A8).withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOption = opt;
                              });
                              _generateAvatarImage();
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                    color: isSelected ? const Color(0xFF9333EA) : Colors.grey.shade400,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? const Color(0xFF6B21A8) : const Color(0xFF3B0764),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          desc,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        if (items.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: items.map((it) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFE9D5FF)),
                                                ),
                                                child: Text(
                                                  it.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6B21A8),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms);
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Step 3 & 4 Header: Gemini Female Avatar Image Generation
                  if (_selectedOption != null) ...[
                    const Text(
                      'Step 3: Gemini Avatar Outfit Rendering 🖼️',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B0764),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gemini takes your selected wardrobe items and renders a female model avatar:',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (_isGeneratingAvatar)
                      Container(
                        height: 260,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF9333EA)),
                            SizedBox(height: 16),
                            Text(
                              'Gemini is generating female avatar rendering...',
                              style: TextStyle(
                                color: Color(0xFF6B21A8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_generatedAvatarData != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B21A8).withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    _generatedAvatarData!['ai_generated_image_url'],
                                    height: 280,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 280,
                                      color: const Color(0xFFF3E8FF),
                                      child: const Center(
                                        child: Icon(Icons.checkroom_rounded, size: 64, color: Color(0xFF9333EA)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 14,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.auto_awesome, color: Color(0xFFFDE047), size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Gemini Avatar Outfit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _generatedAvatarData!['styling_advice'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4C1D95),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Like / Good Outfit Button to Save to History
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.thumb_up_rounded, color: Colors.white),
                                                SizedBox(width: 10),
                                                Text('Awesome! Outfit saved to your History log ✨'),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFF16A34A),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      icon: const Icon(Icons.thumb_up_rounded),
                                      label: const Text(
                                        'Good Outfit! Save to History',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

`

---

## mobile\lib\features\wardrobe\wardrobe_screen.dart

`dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_service.dart';
import 'add_wardrobe_screen.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<dynamic> _wardrobeItems = [];

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Jumpsuit',
    'Jeggings',
    'Kurta',
    'Jacket',
    'Shorts',
    'Outerwear',
    'Lehanga',
    'Saree',
    'Shoes',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _fetchWardrobe();
  }

  Future<void> _fetchWardrobe() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final items = await api.getWardrobe();
      if (mounted) {
        setState(() {
          _wardrobeItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Demo fallback items if offline
          _wardrobeItems = [
            {'id': 1, 'name': 'Purple Silk Blouse', 'category': 'Tops', 'color': 'Purple', 'image_url': null},
            {'id': 2, 'name': 'High-Waist Trousers', 'category': 'Bottoms', 'color': 'White', 'image_url': null},
            {'id': 3, 'name': 'Red Silk Saree', 'category': 'Saree', 'color': 'Red', 'image_url': null},
            {'id': 4, 'name': 'Yellow Blouse', 'category': 'Tops', 'color': 'Yellow', 'image_url': null},
            {'id': 5, 'name': 'Lavender Kurta', 'category': 'Kurta', 'color': 'Lavender', 'image_url': null},
            {'id': 6, 'name': 'White Jeggings', 'category': 'Jeggings', 'color': 'White', 'image_url': null},
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on selected category tab
    final filteredItems = _selectedCategory == 'All'
        ? _wardrobeItems
        : _wardrobeItems.where((item) => item['category'].toString().toLowerCase() == _selectedCategory.toLowerCase()).toList();

    // Group items by Category for structured category sections layout
    final Map<String, List<dynamic>> groupedItems = {};
    for (var cat in _categories.where((c) => c != 'All')) {
      final itemsForCat = _wardrobeItems.where((i) => i['category'].toString().toLowerCase() == cat.toLowerCase()).toList();
      if (itemsForCat.isNotEmpty) {
        groupedItems[cat] = itemsForCat;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Closet 👗',
          style: TextStyle(
            color: Color(0xFF3B0764),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF6B21A8)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips Horizontal Scroll Bar
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6B21A8),
                  backgroundColor: const Color(0xFFFAF5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B21A8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          // Total Items & Add Button Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredItems.length} Garments in My Closet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B0764),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B21A8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                  label: const Text('Add from Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Content Area: Categorized Sections or Filtered Grid View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B21A8)))
                : _selectedCategory == 'All'
                    ? ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: groupedItems.entries.map((entry) {
                          final categoryName = entry.key;
                          final catItems = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Section Title
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9333EA),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categoryName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${catItems.length}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Horizontal List of Garments in Category
                              SizedBox(
                                height: 170,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: catItems.length,
                                  itemBuilder: (context, idx) {
                                    final item = catItems[idx];
                                    return _buildGarmentCard(item);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildGridGarmentCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Garment';
    final color = item['color'] ?? '';
    final imageUrl = item['image_url'] as String?;

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? (imageUrl.startsWith('/') || imageUrl.contains('\\')
                      ? Image.file(File(imageUrl), width: double.infinity, fit: BoxFit.cover)
                      : Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover))
                  : Container(
                      color: const Color(0xFFFAF5FF),
                      child: const Center(
                        child: Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 36),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF3B0764),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🎨 $color',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridGarmentCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Garment';
    final color = item['color'] ?? '';
    final category = item['category'] ?? '';
    final imageUrl = item['image_url'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? (imageUrl.startsWith('/') || imageUrl.contains('\\')
                      ? Image.file(File(imageUrl), width: double.infinity, fit: BoxFit.cover)
                      : Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover))
                  : Container(
                      color: const Color(0xFFFAF5FF),
                      child: const Center(
                        child: Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 40),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF3B0764),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎨 $color',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B21A8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

`

---

