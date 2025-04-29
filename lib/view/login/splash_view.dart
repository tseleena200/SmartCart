import 'package:flutter/material.dart';
import 'package:onlinegroceries/view/login/welcome_view.dart';
import '../../common/color_extension.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void fireOpenApp() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  void startApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Center(
        child: Image.asset(
          "assets/img/splash_logo.png"
          ,
          width: media.width * 0.7,
        ),
      ),
    );
  }
}
