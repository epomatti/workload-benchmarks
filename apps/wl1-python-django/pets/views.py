from rest_framework import viewsets

from rest_framework import permissions
from .serializers import OwnerSerializer, PetSerializer
from .models import Owner, Pet


class OwnerViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows Owners to be viewed or edited.
    """

    queryset = Owner.objects.all()
    serializer_class = OwnerSerializer
    http_method_names = ["post", "get"]
    permission_classes = [permissions.AllowAny]


class PetViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows Pets to be viewed or edited.
    """

    queryset = Pet.objects.all()
    serializer_class = PetSerializer
    http_method_names = ["post", "get"]
    permission_classes = [permissions.AllowAny]
