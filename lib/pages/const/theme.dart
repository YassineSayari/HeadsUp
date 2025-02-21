import 'package:flutter/material.dart';

class AppTheme{
  static const String fontName = 'Rubik';
  static double removeIconSize=40;
  static double homePlayFontSize=15;
  static FontWeight addPlayerFontWeight=FontWeight.w600;

static BoxDecoration playButtonDecoration = BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: AppColors.playButtonColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
  );
}
class AppColors {
  static const Color backGroundColor = Color.fromARGB(255, 65, 127, 177);
  static const Color playButtonColor = Color.fromARGB(255, 141, 232, 23);
  static const Color playerCardColor = Color.fromARGB(255, 236, 247, 243);
}
