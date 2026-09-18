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

