import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/Services/supabase_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EditNoticeScreen extends StatefulWidget {
  final String noticeId;
  final String initialTitle;
  final String initialDescription;
  final List<String>? fileUrl;
  final List<String>? fileType;

  const EditNoticeScreen({
    Key? key,
    required this.noticeId,
    required this.initialTitle,
    required this.initialDescription,
    this.fileUrl,
    this.fileType,
  }) : super(key: key);

  @override
  _EditNoticeScreenState createState() => _EditNoticeScreenState();
}

class _EditNoticeScreenState extends State<EditNoticeScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  List<String> updatedFileUrls = [];
  List<String> updatedFileTypes = [];

  List<File> newFiles = [];
  List<String> newFileTypes = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    descriptionController = TextEditingController(text: widget.initialDescription);

    // Add old files to updated lists
    updatedFileUrls = List<String>.from(widget.fileUrl ?? []);
    updatedFileTypes = List<String>.from(widget.fileType ?? []);
  }

  Future<void> pickNewFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          newFiles.add(File(file.path!));
          newFileTypes.add(file.extension == 'pdf' ? 'pdf' : 'image');
        }
      }
      setState(() {});
    }
  }

  Future<void> updateNotice() async {
    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "Title and description cannot be empty");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔼 Upload new files to Supabase
      for (int i = 0; i < newFiles.length; i++) {
        final uploadedUrl = await SupabaseStorageService.uploadFileToSupabase(newFiles[i], 'notices');
        if (uploadedUrl != null) {
          updatedFileUrls.add(uploadedUrl);
          updatedFileTypes.add(newFileTypes[i]);
        }
      }

      // 🔁 Update Firestore
      await FirebaseFirestore.instance.collection('notices').doc(widget.noticeId).update({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'updatedAt': Timestamp.now(),
        'fileUrls': updatedFileUrls,
        'fileTypes': updatedFileTypes,
      });

      Get.snackbar("Success", "Notice updated successfully");
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Error", "Failed to update: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteOldFile(int index) async {
    final url = updatedFileUrls[index];
    await SupabaseStorageService.deleteFileFromSupabase(url);
    updatedFileUrls.removeAt(index);
    updatedFileTypes.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Notice")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),

            // 🔍 Show old files
            if (updatedFileUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Existing Files:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: updatedFileUrls.length,
                    itemBuilder: (context, index) {
                      final url = updatedFileUrls[index];
                      final type = updatedFileTypes[index];
                      return Card(
                        child: ListTile(
                          title: Text("File ${index + 1}"),
                          subtitle: Text(type.toUpperCase()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteOldFile(index),
                          ),
                          onTap: () async {
                            if (type == 'pdf') {
                              await launchUrl(Uri.parse(url));
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Image.network(url),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ➕ Upload new files
            ElevatedButton.icon(
              onPressed: pickNewFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Add New Files"),
            ),
            if (newFiles.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("New Files to be uploaded:"),
                  ...newFiles.map((f) => Text(f.path.split('/').last)).toList(),
                ],
              ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : updateNotice,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Notice"),
            ),
          ],
        ),
      ),
    );
  }
}
