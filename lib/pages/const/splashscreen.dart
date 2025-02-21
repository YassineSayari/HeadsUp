
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:headsup/pages/const/theme.dart';
import 'package:headsup/pages/home.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  get splash=>null;

  @override
  Widget build(BuildContext context) {
    return  AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: LottieBuilder.asset('assets/images/animation.json'),
          ),
        ]
        ),
      nextScreen: HomePage(),
      backgroundColor: AppColors.backGroundColor,
      splashIconSize: 400,
      splashTransition : SplashTransition.fadeTransition,
    );
  }
}