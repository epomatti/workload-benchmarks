from rest_framework import serializers
from .models import Owner


class OwnerSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Owner
        fields = ["id", "name", "birthday"]
