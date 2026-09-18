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
