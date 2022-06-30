from rest_framework import serializers
from .models import Pet, Owner


class PetSerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.PrimaryKeyRelatedField(queryset=Owner.objects.all())

    class Meta:
        model = Pet
        fields = ["id", "name", "age", "breed", "type", "owner"]
