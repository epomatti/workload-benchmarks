from django.urls import include, path
from rest_framework import routers
from pets import views

router = routers.DefaultRouter()
router.register(r"api/owners", views.OwnerViewSet)
router.register(r"api/pets", views.PetViewSet)
router.register(r"api/pets/<int:pk>", views.PetViewSet)

urlpatterns = [
    path("", include(router.urls)),
    # path('api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
