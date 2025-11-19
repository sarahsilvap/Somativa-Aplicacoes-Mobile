from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from .models import Category, Restaurant, Product, Order, OrderItem
from .serializers import CategorySerializer, RestaurantSerializer, ProductSerializer, OrderSerializer, UserSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import status

class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class RestaurantListView(generics.ListAPIView):
    queryset = Restaurant.objects.all()
    serializer_class = RestaurantSerializer

class ProductListView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class CreateOrderView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        data = request.data
        items = data.get('items', [])
        address = data.get('address', '')
        total = data.get('total', 0)

        order = Order.objects.create(user=user, total=total, address=address)
        for it in items:
            pid = it.get('product_id')
            qty = int(it.get('quantity', 1))
            try:
                product = Product.objects.get(id=pid)
            except Product.DoesNotExist:
                continue
            OrderItem.objects.create(order=order, product=product, quantity=qty, price=product.price)
        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
