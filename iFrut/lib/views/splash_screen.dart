import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flowerdetector/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Color(0xFF00B4BD),
          Color(0xFF0083B0),
        ],
      ),
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "iFrut",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: SvgPicture.asset(
              'assets/fruit.svg',
              semanticsLabel: 'iFrut Logo',
              height: 200,
            ),
          ),
        ],
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: const HomeScreen(),
    );
  }
}
