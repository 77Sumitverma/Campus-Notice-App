import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:get_storage/get_storage.dart';
import 'package:campus_notice_app/Services/supabase_storage_service.dart';
import 'package:campus_notice_app/Services/Supabase_client.dart';


class NoticeUploadService {
  static Future<void> uploadNotice({
    required String title,
    required String description,
    required String uploadedBy,
    required String department,
    required String semester,
    required List<String> fileUrls,     // 🔹 Now takes list
    required List<String> fileTypes,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

// ✅ Construct notice data with department and semester

      final noticeData = {
        'title': title,
        'description': description,
        'createdAt': Timestamp.now(),
        'uploaderName': uploadedBy,
        'uploaderUID': currentUser.uid,
        'department': department,
        'semester': semester,
        'fileUrls': fileUrls,
        'fileTypes': fileTypes,
      };

      final docRef = await FirebaseFirestore.instance.collection('notices').add(noticeData);
      await docRef.update({'noticeId': docRef.id});
      Get.snackbar("Success", "Notice uploaded successfully with ${fileUrls.length} file");
    } catch (e) {
      print("❌ Upload error: $e");
      Get.snackbar("Error", "Upload failed: ${e.toString()}");
    }



  // ✅ Construct notice data with department and semester

    }
  }


