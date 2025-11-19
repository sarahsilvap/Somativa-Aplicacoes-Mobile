from django.contrib import admin
from .models import Category, Restaurant, Product, Order, OrderItem

admin.site.register(Category)
admin.site.register(Restaurant)
admin.site.register(Product)
admin.site.register(Order)
admin.site.register(OrderItem)
