from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (
    CategoryViewSet, RestaurantViewSet, ProductViewSet,
    RegisterViewSet, OrderViewSet, CreateOrderView
)
from .views import ImageProxyView  # Importa a view ImageProxyView

# Criação do roteador DefaultRouter para ViewSets
router = DefaultRouter()
router.register(r'categories', CategoryViewSet)  # Agora o router gerencia as rotas
router.register(r'restaurants', RestaurantViewSet)
router.register(r'products', ProductViewSet)
router.register(r'users', RegisterViewSet)
router.register(r'orders', OrderViewSet)

# Definindo as URLs
urlpatterns = [
    # URLs específicas para autenticação
    path('auth/register/', RegisterViewSet.as_view({'post': 'create'}), name='register'),  # Ação de criação
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # URLs para as views tradicionais (caso queira manter)
    path('orders/create/', CreateOrderView.as_view(), name='create_order'),
    
    # Incluindo as URLs automáticas geradas pelo DefaultRouter
    path('', include(router.urls)),

    path('image-proxy/', ImageProxyView.as_view(), name='image-proxy'),
]
