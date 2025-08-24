import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlinegroceries/view/login/splash_view.dart';
import 'package:onlinegroceries/view/main_tabview/main_tab.dart';

import 'controllers/transaction_controller.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'view/login/login_view.dart';
import 'common/color_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  HOTFIX: Disable Impeller's PlatformDispatcher crash
  ui.PlatformDispatcher.instance.onPlatformConfigurationChanged = null;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  Get.put(AuthController());
  Get.put(TransactionController());


  // ✅ Check if user is already logged in and update Firestore
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final docSnapshot = await userDocRef.get();

    if (docSnapshot.exists) {
      await userDocRef.update({
        'accountStatus': 'Active',
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDocRef.set({
        'email': currentUser.email,
        'accountStatus': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
