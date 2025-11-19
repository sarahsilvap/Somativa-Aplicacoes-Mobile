import 'package:appdeliverytb/model/dish.dart';
import 'package:appdeliverytb/model/restaurant.dart';
import 'package:appdeliverytb/ui/_core/app_colors.dart';
import 'package:appdeliverytb/ui/_core/appbar.dart';
import 'package:appdeliverytb/provider/bag_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appdeliverytb/model/product_model.dart';


class Restaurantscreen extends StatelessWidget {
  final Restaurant restaurant;
  const Restaurantscreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context: context,title: restaurant.name),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/${restaurant.imagePath}',width: 128,),
            SizedBox(height: 12,),
            Text('Mais pedidos',
            style: TextStyle(
              color: AppColors.mainColor,
              fontSize: 18,fontWeight: FontWeight.bold
            ),),

            Column(
              children: List.generate(restaurant.dishes.length, (index){
                Dish dish = restaurant.dishes[index];
                return ListTile(
                  leading: Image.asset('assets/dishes/default.png',
                  width: 48,height: 48,),
                  title: Text(dish.name),
                  subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    
                    onPressed: (){
                      final product = ProductModel.fromDish(dish);
                      context.read<BagProvider>().addItem(product);
                    }, icon: Icon(Icons.add)),
                );
              })
            )
          ],
        ),
      ),
    );
  }
}