import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/Exam_model.dart';

class ExamUploadService {
  static final _examCollection = FirebaseFirestore.instance.collection('exams');
  static final supabase = Supabase.instance.client;

  /// Uploads list of files to Supabase and returns their public URLs
  static Future<List<String>> uploadFilesToSupabase(List<File> files) async {
    List<String> urls = [];

    for (File file in files) {
      final ext = extension(file.path).toLowerCase().replaceAll('.', '');
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}";
      final pathInBucket = "exams/$fileName";

      final bytes = await file.readAsBytes();

      await supabase.storage.from('eventmedia').uploadBinary(
        pathInBucket,
        bytes,
        fileOptions: FileOptions(
          contentType: ext == 'pdf' ? 'application/pdf' : 'image/jpeg',
        ),
      );

      final url = supabase.storage.from('eventmedia').getPublicUrl(pathInBucket);
      urls.add(url);
    }

    return urls;
  }

  /// Uploads a new exam to Firestore and files to Supabase
  static Future<void> uploadExam({
    required ExamModel exam,
    required List<File> files,
  }) async {
    try {
      final urls = await uploadFilesToSupabase(files);
      final types = files.map((f) => f.path.endsWith('.pdf') ? 'pdf' : 'image').toList();

      await _examCollection.add({
        ...exam.toMap(),
        'fileUrls': urls,
        'fileTypes': types,
      });

      Get.snackbar("Success", "Exam uploaded successfully");
    } catch (e) {
      Get.snackbar("Error", "Upload failed: $e");
    }
  }

  /// Updates an existing exam with optional file changes
  static Future<void> updateExam({
    required String examId,
    required String title,
    required String description,
    required String date,
    required List<File> newFiles,
    required List<String> oldFileUrls,
    required List<String> oldFileTypes,
    required bool filesChanged,
    required List<String> filesToDelete,
  }) async {
    try {
      // Delete files from Supabase if needed
      for (String url in filesToDelete) {
        final uri = Uri.parse(url);
        final startIndex = uri.path.indexOf('/object/public/eventmedia/');
        if (startIndex != -1) {
          final relativePath = uri.path.substring(startIndex + '/object/public/eventmedia/'.length);
          await supabase.storage.from('eventmedia').remove([relativePath]);
        }
      }

      // Filter out deleted files from fileUrls and fileTypes safely
      List<String> fileUrls = List.from(oldFileUrls);
      List<String> fileTypes = List.from(oldFileTypes);

      for (String url in filesToDelete) {
        int index = fileUrls.indexOf(url);
        if (index != -1) {
          fileUrls.removeAt(index);
          if (index < fileTypes.length) {
            fileTypes.removeAt(index);
          }
        }
      }

      // Upload new files if files have changed
      if (filesChanged) {
        final newUrls = await uploadFilesToSupabase(newFiles);
        final newTypes = newFiles.map((f) => f.path.endsWith('.pdf') ? 'pdf' : 'image').toList();
        fileUrls.addAll(newUrls);
        fileTypes.addAll(newTypes);
      }

      // Update Firestore
      await _examCollection.doc(examId).update({
        'title': title,
        'description': description,
        'date': date,
        'fileUrls': fileUrls,
        'fileTypes': fileTypes,
      });

      Get.snackbar("Success", "Exam updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    }
  }

  /// Deletes exam data and Supabase files
  static Future<void> deleteExam({
    required String examId,
    required List<String> fileUrls,
  }) async {
    try {
      for (String url in fileUrls) {
        final uri = Uri.parse(url);
        final startIndex = uri.path.indexOf('/object/public/eventmedia/');
        if (startIndex != -1) {
          final relativePath = uri.path.substring(startIndex + '/object/public/eventmedia/'.length);
          await supabase.storage.from('eventmedia').remove([relativePath]);
        }
      }

      await _examCollection.doc(examId).delete();
      Get.snackbar("Deleted", "Exam deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Deletion failed: $e");
    }
  }
}
