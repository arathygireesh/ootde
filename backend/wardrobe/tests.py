from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from .models import WardrobeItem, Outfit
from .outfit_engine import get_outfit_text_suggestions, generate_avatar_image_for_items

User = get_user_model()

class OutfitEngineTestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='fashionista',
            password='testpassword123',
            email='fashion@ootdee.com'
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

        # Create test items in user's wardrobe
        self.item1 = WardrobeItem.objects.create(
            user=self.user,
            name='Purple Silk Top',
            category='Tops',
            color='Lavender',
            occasion='Casual'
        )
        self.item2 = WardrobeItem.objects.create(
            user=self.user,
            name='White Denim Trousers',
            category='Bottoms',
            color='White',
            occasion='Casual'
        )
        self.item3 = WardrobeItem.objects.create(
            user=self.user,
            name='Beige Leather Heels',
            category='Shoes',
            color='Beige',
            occasion='Casual'
        )

    def test_suggest_options_endpoint(self):
        response = self.client.post('/api/wardrobe/suggest-options/', {'occasion': 'Casual'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('occasion', response.data)
        self.assertIn('options', response.data)
        self.assertGreaterEqual(len(response.data['options']), 1)
        
        # Verify options schema
        opt = response.data['options'][0]
        self.assertIn('id', opt)
        self.assertIn('title', opt)
        self.assertIn('description', opt)
        self.assertIn('item_ids', opt)
        self.assertIn('item_summary', opt)

    def test_generate_avatar_endpoint(self):
        payload = {
            'occasion': 'Casual',
            'item_ids': [self.item1.id, self.item2.id]
        }
        response = self.client.post('/api/wardrobe/generate-avatar/', payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('id', response.data)
        self.assertIn('title', response.data)
        self.assertIn('ai_generated_image_url', response.data)

    def test_direct_outfit_engine_functions(self):
        # Direct call test for get_outfit_text_suggestions
        options = get_outfit_text_suggestions(self.user, 'Casual')
        self.assertIsInstance(options, list)
        self.assertGreaterEqual(len(options), 1)

        # Direct call test for generate_avatar_image_for_items
        outfit = generate_avatar_image_for_items(self.user, 'Casual', [self.item1.id, self.item2.id])
        self.assertIsInstance(outfit, Outfit)
        self.assertIsNotNone(outfit.ai_generated_image_url)

