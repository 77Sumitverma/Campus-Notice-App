import 'dart:io';
import 'package:campus_notice_app/Services/Event_upload_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:campus_notice_app/Services/Notice_upload_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Add updates Screen/add_updates.dart';
import 'package:campus_notice_app/Services/supabase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_notice_app/controllers/Exam_model.dart';
import 'package:campus_notice_app/Services/Exam_upload_service.dart';
import 'package:campus_notice_app/Services/util.dart';

class AddUpdates extends StatelessWidget {
  AddUpdates({super.key});

  final updateController = Get.find<UpdateController>();

  // 🔹 File selections
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString selectedFileName = ''.obs;
  final Rx<File?> selectedPdf = Rx<File?>(null);

  // 🔹 Controllers
  final noticeController = TextEditingController();
  final eventTitleController = TextEditingController();
  final eventDateController = TextEditingController();
  final eventDescController = TextEditingController();
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final departmentController = TextEditingController();
  final achievementController = TextEditingController();
  final examTitleController = TextEditingController();
  final examDateController = TextEditingController();
  final examDescController = TextEditingController();
  List<File> selectedFiles = [];
  List<String> selectedFileTypes = [];



  // 🔹 Dropdown Lists and Selected Values

  final List<String> departments = ['BCA', 'BJMC', 'BBA', 'BCOM', 'All'];
  final List<String> semesters = [
    'Sem 1',
    'Sem 2',
    'Sem 3',
    'Sem 4',
    'Sem 5',
    'Sem 6',
    'All'
  ];
  final RxString selectedDepartment = 'BCA'.obs;
  final RxString selectedSemester = 'Sem 1'.obs;

  Widget buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => DropdownButtonFormField<String>(
                value: selectedDepartment.value,
                decoration: InputDecoration(
                  labelText: 'Select Department',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: (value) {
                  selectedDepartment.value = value!;
                },
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() => DropdownButtonFormField<String>(
                value: selectedSemester.value,
                decoration: InputDecoration(
                  labelText: 'Select Semester',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: semesters.map((sem) {
                  return DropdownMenuItem(value: sem, child: Text(sem));
                }).toList(),
                onChanged: (value) {
                  selectedSemester.value = value!;
                },
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Add Information",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildSectionTitle("Add Notice"),
              buildNoticeCard(),
              const SizedBox(height: 30),
              buildSectionTitle("Add Upcoming Event"),
              buildEventCard(),
              const SizedBox(height: 30),
              // buildSectionTitle("Add Academic Achievement"),
              // buildAchievementCard(),
              //const SizedBox(height: 30),
              buildSectionTitle("Add Exam Details"),
              buildExamCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 Notice Section
  Widget buildNoticeCard() {
    RxInt wordCount = 0.obs;
    RxString warningText = ''.obs;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final RxList<File> selectedFiles = <File>[].obs;
    final RxList<String> fileNames = <String>[].obs;

    return Card(
      color: Colors.deepPurple,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildDropdowns(),
            const SizedBox(height: 12),

            // 🔹 Title Field
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter Notice Title",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Description Field
            TextField(
              controller: descriptionController,
              maxLines: null,
              onChanged: (val) {
                int count = val.trim().split(RegExp(r'\s+')).length;
                wordCount.value = count;
                warningText.value = count > 100 ? "Description can't exceed 100 words!" : '';
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter Notice Description",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Word Count Display
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Word Count: ${wordCount.value}/100", style: const TextStyle(color: Colors.white70)),
                if (warningText.isNotEmpty)
                  Text(warningText.value, style: const TextStyle(color: Colors.redAccent)),
              ],
            )),
            const SizedBox(height: 12),

            // 🔹 File Picker Button
            ElevatedButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                );

                if (result != null) {
                  for (var platformFile in result.files) {
                    if (platformFile.path != null) {
                      File file = File(platformFile.path!);
                      if (await file.exists()) {
                        selectedFiles.add(file);
                        fileNames.add(platformFile.name);
                      }
                    }
                  }
                } else {
                  Get.snackbar("No File", "No file selected");
                }
              },
              icon: const Icon(Icons.attach_file),
              label: const Text("Upload PDF/Photo (Multiple Allowed)"),
            ),

            // 🔹 Show Selected Files
            Obx(() => selectedFiles.isEmpty
                ? const Text("No files selected", style: TextStyle(color: Colors.white70))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: selectedFiles[index].path.endsWith('.pdf')
                      ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                      : const Icon(Icons.image, color: Colors.greenAccent),
                  title: Text(fileNames[index], style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      selectedFiles.removeAt(index);
                      fileNames.removeAt(index);
                    },
                  ),
                );
              },
            )),

            const SizedBox(height: 12),

            // 🔹 Upload Button
            ElevatedButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String desc = descriptionController.text.trim();

                if (title.isEmpty || desc.isEmpty) {
                  Get.snackbar("Error", "Please fill both title and description");
                  return;
                }

                final userName = GetStorage().read('userName') ?? 'Admin';
                final department = selectedDepartment.value;
                final semester = selectedSemester.value;

                List<String> uploadedUrls = [];
                List<String> uploadedFileTypes = [];

                try {
                  // 🔹 Upload all files to Supabase and collect URLs
                  for (var file in selectedFiles) {
                    final fileType = file.path.endsWith(".pdf") ? "pdf" : "image";

                    final fileUrl = await SupabaseStorageService.uploadFileToSupabase(file, "notices");
                    if (fileUrl != null) {
                      uploadedUrls.add(fileUrl);
                      uploadedFileTypes.add(fileType);
                    }
                  }

                  //p 🔹 Now create ONE Firestore document with all info
                   await NoticeUploadService.uploadNotice(
                     title: title,
                     description: desc,
                     uploadedBy: userName,
                     department: department,
                     semester: semester,
                     fileUrls: uploadedUrls,               // 👈 pass full list
                     fileTypes: uploadedFileTypes,         // 👈 pass file types too
                   );

                  // 🔹 Clear everything
                  titleController.clear();
                  descriptionController.clear();
                  selectedFiles.clear();
                  fileNames.clear();

                  Get.snackbar("Success", "Notice uploaded with multiple files");
                } catch (e) {
                  Get.snackbar("Error", "Upload failed: $e");
                }
              },
              child: const Text("Upload Notice"),
            ),

          ],
        ),
      ),
    );
  }


  /// 🔥 Event Section
  Widget buildEventCard() {
    return Card(
      color: Colors.blue,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(eventTitleController, "Event Title"),
            const SizedBox(height: 8),
            TextFormField(
              controller: eventDateController,
              readOnly: true,
              style: const TextStyle(color: Colors.white), // <-- input text color
              decoration: InputDecoration(
                labelText: "Event Date",
                labelStyle: const TextStyle(color: Colors.white), // <-- label color
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.white), // <-- calendar icon white
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  eventDateController.text = formattedDate;
                }
              },
            ),

            const SizedBox(height: 8),
            customTextField(eventDescController, "Event Description"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                String title = eventTitleController.text.trim();
                String date = eventDateController.text.trim();
                String desc = eventDescController.text.trim();

                final user = FirebaseAuth.instance.currentUser;

                if (title.isEmpty || date.isEmpty || desc.isEmpty || selectedFiles.isEmpty || user == null) {
                  Get.snackbar("Error", "Fill all fields and select files");
                  return;
                }

                try {
                  await EventUploadService.uploadEvent(
                    title: title,
                    description: desc,
                    date: date,
                    files: selectedFiles,
                    uploaderUID: user.uid,
                    uploaderName: user.displayName ?? "Admin",
                  );

                  // Clear after successful upload
                  eventTitleController.clear();
                  eventDateController.clear();
                  eventDescController.clear();
                  selectedFiles.clear();
                  selectedFileTypes.clear();

                  Get.snackbar("Success", "Event uploaded successfully");
                } catch (e) {
                  Get.snackbar("Error", "Upload failed: $e");
                }
              },
              child: const Text("Add Event"),
            ),
            const SizedBox(height: 12),

            /// 📎 Pick Files Button
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Attach Image or PDF"),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                );

                if (result != null) {
                  selectedFiles = result.paths.map((path) => File(path!)).toList();
                  selectedFileTypes = result.files.map((file) => file.extension == 'pdf' ? 'pdf' : 'image').toList();
                } else {
                  Get.snackbar("Cancelled", "No file selected");
                }
              },
            ),

            /// 🗂️ Preview Selected Files
            if (selectedFiles.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(selectedFiles.length, (index) {
                  final fileType = selectedFileTypes[index];
                  final fileName = selectedFiles[index].path.split('/').last;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            selectedFiles.removeAt(index);
                            selectedFileTypes.removeAt(index);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),


          ],
        ),
      ),
    );
  }

  /// 🔥 Achievement Section
  Widget buildAchievementCard() {
    return Card(
      color: Colors.teal,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(nameController, "Student Name"),
            const SizedBox(height: 8),
            customTextField(yearController, "Academic Year"),
            const SizedBox(height: 8),
            customTextField(departmentController, "Department"),
            const SizedBox(height: 8),
            customTextField(achievementController, "Achievement"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                String year = yearController.text.trim();
                String dept = departmentController.text.trim();
                String ach = achievementController.text.trim();

                if (name.isNotEmpty &&
                    year.isNotEmpty &&
                    dept.isNotEmpty &&
                    ach.isNotEmpty) {
                  updateController.addAchievement(name, year, dept, ach);
                  nameController.clear();
                  yearController.clear();
                  departmentController.clear();
                  achievementController.clear();
                  Get.snackbar("Success", "Achievement Added");
                }
              },
              child: const Text("Add Achievement"),
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 Exam Section

  Widget buildExamCard() {
    return Card(
      color: Colors.orange,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(examTitleController, "Exam Title"),
            const SizedBox(height: 8),
          TextFormField(
            controller: examDateController,
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                examDateController.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              }
            },
            decoration: InputDecoration(
              labelText: "Exam Date",
              labelStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
            const SizedBox(height: 8),
            customTextField(examDescController, "Exam Description"),
            const SizedBox(height: 8),

            /// PDF Picker
            Obx(() => Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result =
                    await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null) {
                      selectedPdf.value = File(result.files.single.path!);
                      Get.snackbar("PDF Selected", "${result.files.single.name}");
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload PDF"),
                ),
                selectedPdf.value != null
                    ? Text(
                  "Selected: ${selectedPdf.value!.path.split('/').last}",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                )
                    : const Text(
                  "No PDF selected",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            )),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                String title = examTitleController.text.trim();
                String date = examDateController.text.trim();
                String desc = examDescController.text.trim();
                File? pdfFile = selectedPdf.value;

                if (title.isNotEmpty &&
                    date.isNotEmpty &&
                    desc.isNotEmpty &&
                    pdfFile != null) {
                  // ✅ Step 1: Get current user
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    Get.snackbar("Error", "User not logged in");
                    return;
                  }

                  // ✅ Step 2: Create ExamModel
                  final exam = ExamModel(
                    title: title,
                    description: desc,
                    date: date,
                    fileUrls: [], // URLs will be filled by service
                    fileTypes: [], // Types will be filled too
                    uploaderName: user.displayName ?? user.email ?? 'Unknown',
                    uploaderUID: user.uid,
                  );

                  // ✅ Step 3: Upload exam to Firestore + Supabase
                  await ExamUploadService.uploadExam(exam: exam, files: [pdfFile]);

                  // ✅ Step 4: Reset UI
                  examTitleController.clear();
                  examDateController.clear();
                  examDescController.clear();
                  selectedPdf.value = null;
                  Get.snackbar("Success", "Exam uploaded successfully");
                } else {
                  Get.snackbar("Error", "Please fill all fields and select PDF");
                }
              },
              child: const Text("Add Exam"),
            )
          ],
        ),
      ),
    );
  }


  /// 🔥 Section Title
  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  /// 🔥 Custom Text Field
  Widget customTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
