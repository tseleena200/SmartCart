import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/login/login_view.dart';
import '../view/login/verification_view.dart';
import '../common/color_extension.dart';

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
        "Welcome, $firstName ",
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

  /// Send OTP for phone number registration
  void sendOTP({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String dob,
    required String branch,
    required bool receivePromos,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.replaceAll(' ', ''),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _registerPhoneUser(
            firstName: firstName,
            lastName: lastName,
            phone: phoneNumber,
            dob: dob,
            branch: branch,
            receivePromos: receivePromos,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            "OTP Failed",
            e.message ?? "Something went wrong",
            backgroundColor: TColor.error,
            colorText: Colors.white,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.to(() => VerificationView(
            verificationId: verificationId,
            phone: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            dob: dob,
            branch: branch,
            receivePromos: receivePromos,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: TColor.error,
        colorText: Colors.white,
      );
    }
  }

  /// Register user after OTP verification
  Future<void> verifyAndRegisterOTP({
    required String verificationId,
    required String smsCode,
    required String phone,
    required String firstName,
    required String lastName,
    required String dob,
    required String branch,
    required bool receivePromos,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );

      await _auth.signInWithCredential(credential);

      await _registerPhoneUser(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dob: dob,
        branch: branch,
        receivePromos: receivePromos,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Verification Failed",
        e.message ?? "Invalid OTP",
        backgroundColor: TColor.error,
        colorText: Colors.white,
      );
    }
  }

  /// Save phone user to Firestore
  Future<void> _registerPhoneUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String dob,
    required String branch,
    required bool receivePromos,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('Users').doc(uid).set({
      'userID': uid,
      'name': '$firstName $lastName',
      'email': '',
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
      "Phone Verified!",
      "You have successfully registered.",
      backgroundColor: TColor.success,
      colorText: Colors.white,
    );

    Get.offAll(() => const LogInView());
  }
}
