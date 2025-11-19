import 'package:appdeliverytb/ui/_core/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  // cria variavel para armazenar o tema do app
  static ThemeData appTheme = ThemeData.dark().copyWith(
   elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Colors.black),
      backgroundColor: WidgetStateColor.resolveWith((states){
        if(states.contains(WidgetState.disabled)){
          return Colors.grey;
        }else if(
          states.contains(WidgetState.pressed)){
            return Color.fromARGB(171, 255, 164, 89);
          }

          return AppColors.mainColor;
}
),
),
),
);

        }
      
    
   
  
