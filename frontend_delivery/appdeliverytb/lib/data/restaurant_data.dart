import 'dart:convert'; // biblioteca para trabalhar com json
import 'package:appdeliverytb/model/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // biblioteca para criar os widgets do flutter


class RestaurantData extends ChangeNotifier{
  // Cria uma lista para carregar os restaurantes
  List<Restaurant> _listRestaurant=[];
  List<Restaurant> get listRestaurant=> _listRestaurant;

  Future<List<Restaurant>> getRestaurant()async{

    if(_listRestaurant.isNotEmpty){
      return _listRestaurant; // Evita recarregar se já tiver carregado uma vez
    }

    try{
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String,dynamic> data= json.decode(jsonString);
      final List<dynamic> RestaurantData = data['restaurants'];

      _listRestaurant.addAll(
       RestaurantData.map((e)=>Restaurant.fromMap(e)).toList()

      );
      notifyListeners(); // notifica caso esteja utilizando provider
    } catch(e){
      debugPrint('Erro ao carregar restaurantes: $e');
    }

    return _listRestaurant;
  }


}

