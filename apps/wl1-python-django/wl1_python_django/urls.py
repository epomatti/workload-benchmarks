from django.urls import include, path
from rest_framework import routers
from pets.views import PetViewSet
from owners.views import OwnerViewSet

router = routers.DefaultRouter()
router.register(r"api/owners", OwnerViewSet)
router.register(r"api/pets", PetViewSet)

urlpatterns = [
    path("", include(router.urls)),
]
