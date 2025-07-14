import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/Services/Exam_upload_service.dart';

class ExamEditScreen extends StatefulWidget {
  final String examId;
  final String title;
  final String description;
  final String date;
  final List<String> fileUrls;
  final List<String> fileTypes;

  const ExamEditScreen({
    super.key,
    required this.examId,
    required this.title,
    required this.description,
    required this.date,
    required this.fileUrls,
    required this.fileTypes,
  });

  @override
  State<ExamEditScreen> createState() => _ExamEditScreenState();
}

class _ExamEditScreenState extends State<ExamEditScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  List<File> newFiles = [];
  List<String> currentFileUrls = [];
  List<String> currentFileTypes = [];
  List<String> filesToDelete = [];

  bool filesChanged = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
    dateController = TextEditingController(text: widget.date);

    currentFileUrls = List.from(widget.fileUrls);
    currentFileTypes = List.from(widget.fileTypes);
  }

  void pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      newFiles = result.paths.map((path) => File(path!)).toList();
      setState(() {
        filesChanged = true;
      });
    }
  }

  void updateExam() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        dateController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    await ExamUploadService.updateExam(
      examId: widget.examId,
      title: titleController.text,
      description: descriptionController.text,
      date: dateController.text,
      newFiles: newFiles,
      oldFileUrls: currentFileUrls,
      oldFileTypes: currentFileTypes,
      filesChanged: filesChanged,
      filesToDelete: filesToDelete,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Exam")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Exam Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Exam Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Exam Date"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Pick New Files (Optional)"),
              onPressed: pickFiles,
            ),
            const SizedBox(height: 10),
            if (filesChanged)
              Wrap(
                spacing: 10,
                children: newFiles
                    .map((file) => Chip(label: Text(file.path.split("/").last)))
                    .toList(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Files:"),
                  Wrap(
                    spacing: 10,
                    children: List.generate(currentFileUrls.length, (index) {
                      final url = currentFileUrls[index];
                      final isPdf = currentFileTypes[index] == 'pdf';

                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            child: isPdf
                                ? Container(
                              width: 60,
                              height: 60,
                              color: Colors.white,
                              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            )
                                : Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                filesToDelete.add(url);
                                currentFileUrls.removeAt(index);
                                currentFileTypes.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: updateExam,
              child: const Text("Update Exam"),
            ),
          ],
        ),
      ),
    );
  }
}
