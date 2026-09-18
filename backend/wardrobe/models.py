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

