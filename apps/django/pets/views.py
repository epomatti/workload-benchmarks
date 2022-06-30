from rest_framework import viewsets

from rest_framework import permissions
from .serializers import PetSerializer
from .models import Pet


class PetViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows Pets to be viewed or edited.
    """

    queryset = Pet.objects.all()
    serializer_class = PetSerializer
    http_method_names = ["post", "get"]
    permission_classes = [permissions.AllowAny]
