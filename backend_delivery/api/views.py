from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from django.contrib.auth.models import User

from .models import Category, Restaurant, Product, Order, OrderItem
from .serializers import (
    CategorySerializer, RestaurantSerializer,
    ProductSerializer, OrderSerializer, UserSerializer
)

import requests
from django.http import HttpResponse
from django.views import View


class ImageProxyView(View):
    def get(self, request, *args, **kwargs):
        # URL da imagem externa
        image_url = 'https://s2-casaejardim.glbimg.com/XX096G6-JjB-CJuBRqmxpcZBSg4=/0x0:1200x724/984x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_a0b7e59562ef42049f4e191fe476fe7d/internal_photos/bs/2023/A/Y/Qv2aleQFAYE6ZumGjI0g/2022-02-18-nonna-rosa-5.jpeg'
        
        # Faz a requisição para o servidor que hospeda a imagem
        response = requests.get(image_url)
        
        # Retorna o conteúdo da imagem com o tipo correto
        return HttpResponse(response.content, content_type='image/jpeg')
    
    
# -----------------------
# CATEGORY (GET + POST + PUT + DELETE)
# -----------------------
class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]


# -----------------------
# RESTAURANT (GET + POST + PUT + DELETE)
# -----------------------
class RestaurantViewSet(viewsets.ModelViewSet):
    queryset = Restaurant.objects.all()
    serializer_class = RestaurantSerializer
    permission_classes = [permissions.AllowAny]


# -----------------------
# PRODUCT (GET + POST + PUT + DELETE)
# -----------------------
class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]


# -----------------------
# USER REGISTER (somente POST)
# -----------------------
class RegisterViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]


# -----------------------
# ORDER (somente leitura, criação é separada)
# -----------------------
class OrderViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]


# -----------------------
# CREATE ORDER (POST)
# -----------------------
class CreateOrderView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        data = request.data

        items = data.get('items', [])
        address = data.get('address', '')
        total = data.get('total', 0)

        order = Order.objects.create(
            user=user,
            address=address,
            total=total
        )

        for it in items:
            pid = it.get('product_id')
            qty = int(it.get('quantity', 1))

            try:
                product = Product.objects.get(id=pid)
            except Product.DoesNotExist:
                continue

            OrderItem.objects.create(
                order=order,
                product=product,
                quantity=qty,
                price=product.price
            )

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
