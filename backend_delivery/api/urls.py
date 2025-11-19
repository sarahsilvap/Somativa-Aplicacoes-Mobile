from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import CategoryListView, RestaurantListView, ProductListView, RegisterView, CreateOrderView

urlpatterns = [
    path('categories/', CategoryListView.as_view()),
    path('restaurants/', RestaurantListView.as_view()),
    path('products/', ProductListView.as_view()),
    path('auth/register/', RegisterView.as_view()),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('orders/', CreateOrderView.as_view()),
]
