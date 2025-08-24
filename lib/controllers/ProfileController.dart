import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userData = {}.obs;

  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('Users').doc(uid).get();
    if (doc.exists) {
      userData.value = doc.data()!;
    }
  }

  Future<void> updateUserDetails(Map<String, dynamic> updatedData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('Users').doc(uid).update(updatedData);
    await loadUserData(); // Refresh after update
  }
}
