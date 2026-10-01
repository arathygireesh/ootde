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
    ai_generated_image_url = serializers.SerializerMethodField()

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

    def get_ai_generated_image_url(self, obj):
        url = obj.ai_generated_image_url
        if not url:
            return url
        request = self.context.get('request')
        if not url.startswith('http') and request:
            return request.build_absolute_uri(url)
        return url

