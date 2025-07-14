import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:campus_notice_app/Services/Exam_upload_service.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/notice_Card.dart';
import 'package:campus_notice_app/Screens/ExamEditScreen.dart';

class ExamSection extends StatelessWidget {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  ExamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final updateController = Get.find<UpdateController>();

    return Obx(() {
      final exams = updateController.examList;
      if (exams.isEmpty) {
        return const Center(child: Text("No Exams Available"));
      }

      return Column(
        children: [
          SizedBox(
            height: 330,
            child: PageView.builder(
              controller: _pageController,
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final data = exams[index];
                return Transform.scale(
                  scale: 0.95,
                  child: ExamCard(
                    title: data['title'] ?? '',
                    description: data['description'] ?? '',
                    date: data['date'] ?? '',
                    fileUrls: (data['fileUrls'] as List?)?.whereType<String>().toList() ?? [],
                    fileTypes: (data['fileTypes'] as List?)?.whereType<String>().toList() ?? [],
                    createdAt:( data['createdAt']as Timestamp?)?.toDate(),
                    examId: data['id'],
                  ),
                );
              },
            ),
          ),

          SmoothPageIndicator(
            controller: _pageController,
            count: exams.length,
            effect: JumpingDotEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.orange,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ],
      );
    });
  }
}

class ExamCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final List<String> fileUrls;
  final List<String> fileTypes;
  final String examId;
  final DateTime? createdAt;

  const ExamCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.fileUrls,
    required this.fileTypes,
    required this.examId,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30), // space for top icons
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(child: Text("On" " $date", style: const TextStyle(fontSize: 20, color: Colors.grey))),
                    const SizedBox(height: 10),
                    //const Text("📝 Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 12),
                    if (fileUrls.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        children: List.generate(fileUrls.length, (index) {
                          final url = fileUrls[index];
                          final isPdf = fileTypes.length > index && fileTypes[index] == 'pdf';

                          return GestureDetector(
                            onTap: () {
                              Get.to(() => PdfViewerScreen(url: url));
                            },
                            child: isPdf
                                ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40)
                                : Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                          );
                        }),
                      ),
                  ],
                ),
              ),

              // 🔵 Upload Date Top Left
              Positioned(
                top: 10,
                left: 12,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      createdAt != null
                          ? "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}"
                          : "No Date",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // 🔴 Edit/Delete Top Right
              Positioned(
                top: 6,
                right: 6,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () {
                        Get.to(() => ExamEditScreen(
                          examId: examId,
                          title: title,
                          description: description,
                          date: date,
                          fileUrls: fileUrls,
                          fileTypes: fileTypes,
                        ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () async {
                        await ExamUploadService.deleteExam(
                          examId: examId,
                          fileUrls: fileUrls,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
