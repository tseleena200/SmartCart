import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:onlinegroceries/view/login/PasswordResetSuccessView.dart';
import 'package:onlinegroceries/view/login/login_view.dart';
import 'package:onlinegroceries/view/login/sign_in_view.dart';

import 'package:onlinegroceries/view/login/splash_view.dart';
import 'package:onlinegroceries/view/main_tabview/main_tab.dart';
import 'common/color_extension.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register AuthController using GetX
  Get.put(AuthController());
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .update({
      'accountStatus': 'Active',
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // <- Use GetMaterialApp for GetX support
      title: 'Online Groceries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Gilroy",
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      home: const MainTabView(),
    );
  }
}
