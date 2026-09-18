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
