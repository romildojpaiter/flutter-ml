import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flowerdetector/views/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.004, 1],
        colors: [
          Color(0xFFa8e063),
          Color(0xFF56ab2f),
        ],
      ),
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/flower.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: const HomeScreen(),
    );
  }
}
