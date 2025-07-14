import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';

class EventUploadService {
  static final _eventCollection = FirebaseFirestore.instance.collection('events');
  static final supabase = Supabase.instance.client;

  /// 🔼 Upload multiple files to Supabase and return list of public URLs
  static Future<List<String>> uploadFilesToSupabase(List<File> files) async {
    List<String> urls = [];

    for (File file in files) {
      final extension = extensionFromPath(file.path);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}";
      final pathInBucket = "events/$fileName"; // Organized path

      final bytes = await file.readAsBytes();

      await supabase.storage.from('eventmedia').uploadBinary(
        pathInBucket,
        bytes,
        fileOptions: FileOptions(
          contentType: extension == 'pdf' ? 'application/pdf' : 'image/jpeg',
        ),
      );

      final url = supabase.storage.from('eventmedia').getPublicUrl(pathInBucket);
      urls.add(url);
    }

    return urls;
  }

  /// 🆕 Upload Event data with file URLs and metadata
  static Future<void> uploadEvent({
    required String title,
    required String description,
    required String date,
    required List<File> files,
    required String uploaderName,
    required String uploaderUID,

  }) async {
    final urls = await uploadFilesToSupabase(files);
    final fileTypes = files.map((f) => f.path.endsWith('.pdf') ? 'pdf' : 'image').toList();

    await _eventCollection.add({
      'title': title,
      'description': description,
      'date': date,
      'fileUrls': urls,
      'fileTypes': fileTypes,
      'uploaderUID': uploaderUID,
      'uploaderName': uploaderName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ❌ Delete event + files from Supabase + Firestore
  static Future<void> deleteEvent(String eventId, List<String> fileUrls) async {
    try {
      for (var url in fileUrls) {
        final uri = Uri.parse(url);
        final startIndex = uri.path.indexOf('/object/public/eventmedia/');
        if (startIndex != -1) {
          final relativePath = uri.path.substring(startIndex + '/object/public/event_media/'.length);
          await supabase.storage.from('event_media').remove([relativePath]);
        }
      }

      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      Get.snackbar("Deleted", "Event deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete event: $e");
    }
  }

  /// 🧠 Utility to get extension (e.g., pdf, jpg)
  static String extensionFromPath(String path) {
    final ext = extension(path).toLowerCase().replaceFirst('.', '');
    return ext;
  }
  static Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String date,
    required List<File> newFiles,
    required List<String> oldFileUrls,
    required List<String> oldFileTypes,
    required bool filesChanged,
    required List<String> filesToDelete // ✅ Add this line
  }) async {
    try {
      // 1. Delete selected files from Supabase
      for (String url in filesToDelete) {
        final uri = Uri.parse(url);
        final startIndex = uri.path.indexOf('/object/public/eventmedia/');
        if (startIndex != -1) {
          final relativePath = uri.path.substring(
            startIndex + '/object/public/eventmedia/'.length,
          );
          await supabase.storage.from('eventmedia').remove([relativePath]);
        }
      }

      // 2. Remove deleted file URLs and types from old lists
      List<String> fileUrls = List.from(oldFileUrls)
        ..removeWhere((url) => filesToDelete.contains(url));
      List<String> fileTypes = List.from(oldFileTypes);
      for (var url in filesToDelete) {
        int index = oldFileUrls.indexOf(url);
        if (index != -1 && index < fileTypes.length) {
          fileTypes.removeAt(index);
        }
      }

      // 3. Upload new files if any
      if (filesChanged) {
        final newUrls = await uploadFilesToSupabase(newFiles);
        final newTypes = newFiles.map((f) => f.path.endsWith('.pdf') ? 'pdf' : 'image').toList();

        fileUrls.addAll(newUrls);
        fileTypes.addAll(newTypes);
      }

      // 4. Update Firestore
      await _eventCollection.doc(eventId).update({
        'title': title,
        'description': description,
        'date': date,
        'fileUrls': fileUrls,
        'fileTypes': fileTypes,
      });

      Get.snackbar("Success", "Event updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update event: $e");
    }
  }

  static Future<void> deleteExam(String examId, List<String> fileUrls) async {
    try {
      // Delete files from Supabase
      for (String url in fileUrls) {
        final uri = Uri.parse(url);
        final startIndex = uri.path.indexOf('/object/public/eventmedia/');
        if (startIndex != -1) {
          final relativePath = uri.path.substring(startIndex + '/object/public/eventmedia/'.length);
          await supabase.storage.from('eventmedia').remove([relativePath]);
        }
      }

      // Delete Firestore document
      await FirebaseFirestore.instance.collection('exams').doc(examId).delete();

      Get.snackbar("Success", "Exam deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete exam: $e");
    }
  }



}
