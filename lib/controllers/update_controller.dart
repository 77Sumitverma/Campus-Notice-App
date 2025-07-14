import 'package:get/get.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_notice_app/Services/supabase_storage_service.dart';
import 'package:campus_notice_app/Services/Notice_upload_service.dart';
import 'package:campus_notice_app/controllers/EventModel.dart';
import 'package:campus_notice_app/Services/Event_upload_service.dart';

class NoticeModel {
  final String title;
  final String description;
  final Timestamp createdAt;
  final String uploaderName;
  final String uploaderUID;
  final String department;
  final String semester;
  final List<String> fileUrls;
  final List<String> fileTypes;
  final String noticeID;

  NoticeModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.uploaderName,
    required this.uploaderUID,
    required this.department,
    required this.semester,
    required this.fileUrls,
    required this.fileTypes,
    required this.noticeID,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String docId) {
    return NoticeModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'],
      uploaderName: map['uploaderName'] ?? '',
      uploaderUID: map['uploaderUID'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
      fileTypes: List<String>.from(map['fileTypes'] ?? []),
      noticeID: docId, // ✅ Now this works
    );
  }

}

class UpdateController extends GetxController {
  var updatesList = <NoticeModel>[].obs;
  var eventsList = <EventModel>[].obs;
  var achievementsList = <Map<String, String>>[].obs;
  var examList = <Map<String, dynamic>>[].obs;

  /// 🔥 Fetch notices on init
  @override
  void onInit() {
    super.onInit();
    fetchNotices();
    fetchEvents();
    fetchExams();
  }

  /// 🔁 Realtime Firestore listener
  void fetchNotices() {
    FirebaseFirestore.instance
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      updatesList.value = snapshot.docs.map((doc) {
        return NoticeModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  ///Event listener
  void fetchEvents() {
    FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      eventsList.value = snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  ///Delete event

  Future<void> deleteEvent(String eventId, List<String> fileUrls) async {
    await EventUploadService.deleteEvent(eventId, fileUrls);
    eventsList.removeWhere((e) => e.eventID == eventId);
    update();
  }


  Future<void> deleteFromFirestore(String noticeId) async {
    try {
      await FirebaseFirestore.instance.collection('notices')
          .doc(noticeId)
          .delete();
      updatesList.removeWhere((notice) => notice.noticeID == noticeId);
      update(); // Refresh the UI
      Get.snackbar("Deleted", "Notice deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete notice: $e");
    }
  }

  /// 📅 Add Event
  void addEvent(String title, String date, String description) {
    final event = EventModel(
      title: title,
      description: description,
      date: date,
      fileUrls: [],
      fileTypes: [],
      uploaderUID: 'admin123',
      // Ya jo bhi UID ho
      uploaderName: 'Admin',
      createdAt: Timestamp.now(),
      eventID: '', // Firestore me generate hota hai
    );

    eventsList.add(event);
  }

  /// 🎓 Add Achievement
  void addAchievement(String name, String year, String department,
      String achievement) {
    achievementsList.add({
      'name': name,
      'year': year,
      'department': department,
      'achievement': achievement,
    });
  }

  /// 📝 Add Exam
  void addExam(String title, String date, String desc, File pdfFile) {
    examList.add({
      'title': title,
      'date': date,
      'desc': desc,
      'pdfPath': pdfFile.path,
    });
  }


//delete
  Future<void> deletefromFirestore(String noticeId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('notices').doc(
          noticeId);
      final doc = await docRef.get();

      if (doc.exists) {
        final fileUrl = doc['fileUrl'];
        if (fileUrl != null) {
          await SupabaseStorageService.deleteFileFromSupabase(fileUrl);
        }
      }

      await docRef.delete();
      Get.snackbar("Deleted", "Notice deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete: $e");
    }
  }

  void fetchExams() {
    FirebaseFirestore.instance
        .collection('exams')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      examList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id, // ✅ Yeh line zaroori hai — ID ko null se bachata hai
        };
      }).toList();
    });
  }

}