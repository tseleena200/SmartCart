import 'package:flutter/material.dart';
import 'package:onlinegroceries/view/login/login_view.dart';
import 'package:onlinegroceries/view/login/sign_in_view.dart';
import 'package:onlinegroceries/view/login/sign_up_view.dart';
import 'package:onlinegroceries/view/login/splash_view.dart';
import 'common/color_extension.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Groceries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Gilroy",
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      home: const SplashView(),
    );


  }
}
