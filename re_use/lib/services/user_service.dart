import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserProfile({
    required String uid,
    required String address,
    String? phone,
  }) async {
    await _users.doc(uid).set({
      'address': address,
      if (phone != null) 'phone': phone,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
