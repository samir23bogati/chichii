import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Register admin device for notifications
  Future<void> saveAdminToken(String adminId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _firestore.collection("adminTokens").doc(adminId).set({
        "token": token,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
