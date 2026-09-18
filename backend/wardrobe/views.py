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
