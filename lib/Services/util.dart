import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool canEditOrDelete({
  required String uploaderUID,
  required String uploaderName,
}) {
  final currentUser = FirebaseAuth.instance.currentUser;
  final isUploader = currentUser?.uid == uploaderUID;
  final isAdmin = uploaderName.trim().toLowerCase() == 'admin';

  return isUploader || isAdmin;
}
String formatTimestamp(Timestamp timestamp) {
  final dt = timestamp.toDate();
  return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
}
Future<String?> getUserRole() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['role'];
}