import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:catdogpredict/views/home_screen.dart';
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
      backgroundColor: Colors.black,
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/cat.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: const HomeScreen(),
    );
  }
}
