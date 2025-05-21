import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerAdmin({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String nic,
  }) async {
    try {
      // Register with Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Save admin data to Firestore
      await _firestore.collection('adminUsers').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'nic': nic,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'admin',
      });

      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Unknown Firebase Auth error';
    } catch (e) {
      return 'Error: $e';
    }
  }
  Future<String?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Check if admin user exists in Firestore
      final doc = await _firestore.collection('adminUsers').doc(uid).get();
      if (!doc.exists) {
        return 'This account is not registered as an admin.';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed due to unknown Firebase error';
    } catch (e) {
      return 'Error: $e';
    }
  }

}
