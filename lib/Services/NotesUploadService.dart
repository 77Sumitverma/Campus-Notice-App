import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesUploadService {
  final bucket = 'notesmedia';

  Future<List<String>> uploadFilesToSupabase(List<PlatformFile> files) async {
    List<String> fileUrls = [];

    for (var file in files) {
      final filePath = 'notes/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final fileBytes = File(file.path!);

      await Supabase.instance.client.storage.from(bucket).upload(
        filePath,
        fileBytes,
        fileOptions: FileOptions(upsert: true),
      );

      final publicUrl = Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);
      fileUrls.add(publicUrl);
    }

    return fileUrls;
  }

  Future<void> uploadNoteToFirestore({
    required String title,
    String? description,
    required String course,
    required String semester,
    required List<PlatformFile> files,
    required bool isPaid,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final user = FirebaseAuth.instance.currentUser;
    final urls = await uploadFilesToSupabase(files);

    final noteData = {
      'uid': uid,
      'title': title,
      'description': description ?? '',
      'course': course,
      'semester': semester,
      'fileUrls': urls,
      'createdAt': Timestamp.now(),
      'isPaid': isPaid,
      'uploaderName': user?.displayName ?? 'Anonymous',
      'uploaderId' : FirebaseAuth.instance.currentUser!.uid
    };

    await FirebaseFirestore.instance.collection('notes').add(noteData);
  }

  Future<void> saveDownloadToHistory({
    required String noteId,
    required String title,
    required String fileName,
    required String fileUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('downloadHistory').add({
      'userId': user.uid,
      'noteId': noteId,
      'title': title,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'downloadedAt': Timestamp.now(),
    });
  }

}
