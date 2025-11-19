import 'package:appdeliverytb/model/restaurant.dart';
import 'package:appdeliverytb/ui/widgets/restaurant/restaurantscreen.dart';
import 'package:flutter/material.dart';

class RestaurantWidget extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantWidget({super.key,required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context){
              // criar a classe restaurante screen
              return Restaurantscreen(restaurant: restaurant);

            }));
        },
        child: Row(
          spacing: 12,
          children: [
            Image.asset('assets/${restaurant.imagePath}',width: 72,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(restaurant.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                Row(
                  children: List.generate(restaurant.stars.toInt(), (index){
                    return Image.asset('assets/others/star.png',width: 16,);
                  }),
                ),
                Text('${restaurant.distance} Km')

              ],
            )
          ],
        ),
      ),
    );
  }
}