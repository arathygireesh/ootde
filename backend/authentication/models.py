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
