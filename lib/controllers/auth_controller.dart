import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/login/login_view.dart';
import '../common/color_extension.dart'; // <-- TColor

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register user with email & password
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dob,
    required String branch,
    required bool receivePromos,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('Users').doc(credential.user!.uid).set({
        'userID': credential.user!.uid,
        'name': '$firstName $lastName',
        'email': email,
        'phoneNumber': phone,
        'userRole': 'customer',
        'dob': dob,
        'preferredBranch': branch,
        'receivePromos': receivePromos,
        'favorites': [],
        'purchaseHistory': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Registration Successful!",
        "Welcome, $firstName 🎉",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColor.success,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );

      Get.off(() => const LogInView());
    } on FirebaseAuthException catch (e) {
      String msg = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already in use';
      } else if (e.code == 'weak-password') {
        msg = 'The password is too weak';
      }

      Get.snackbar(
        "Registration Failed",
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unexpected: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColor.error,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
      );
    }
  }


}
