import 'package:campus_notice_app/Services/Event_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:path/path.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/notice_Card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_notice_app/Screens/EventEditScreen.dart';

Widget UpcomingEventSection() {
  final updateController = Get.find<UpdateController>();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  return Obx(() {
    if (updateController.eventsList.isEmpty) {
      return const Text(
        "No Events Available",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: updateController.eventsList.length,
            itemBuilder: (context, index) {
              var event = updateController.eventsList[index];
              return Transform.scale(
                scale: 0.95,
                child: upcomingEventCard(
                  title: event.title ?? '',
                  date: event.date ?? '',
                  description: event.description ?? '',
                  fileUrls: event.fileUrls,
                  fileTypes: event.fileTypes,
                  createdAt: event.createdAt,
                  onEdit: () async {
                   await Get.to(() => EventEditScreen(
                      eventId: event.eventID,
                      title: event.title ?? '',
                      description: event.description ?? '',
                      date: event.date ?? '',
                      fileUrls: event.fileUrls,
                      fileTypes: event.fileTypes,
                    ));
                    print("Edit button clicked: ${event.title}");
                  },
                  onDelete: () {
                    EventUploadService.deleteEvent(event.eventID, event.fileUrls);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: updateController.eventsList.length,
          effect: JumpingDotEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  });
}

String formatTimestamp(Timestamp timestamp) {
  final dt = timestamp.toDate();
  return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
}

Widget upcomingEventCard({
  required String title,
  required String date,
  required String description,
  required List<String> fileUrls,
  required List<String> fileTypes,
  required Timestamp? createdAt,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return SingleChildScrollView(
    child: SizedBox(height: 250,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.blue,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🗓️ Event Date & Upload Date (left top)
                  if (createdAt != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🎯 Event Date: $date",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "📥 Uploaded: ${formatTimestamp(createdAt)}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  /// 📝 Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 🔥 This centers the icon + text
                    children: [
                      const Icon(Icons.event, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// 📄 Description
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  /// 📁 Attached Files
                  if (fileUrls.isNotEmpty && fileUrls.length == fileTypes.length)
                    Wrap(
                      spacing: 10,
                      children: List.generate(fileUrls.length, (index) {
                        final url = fileUrls[index];
                        final type = fileTypes[index];
                        return GestureDetector(
                          onTap: () {
                            if (type == 'pdf') {
                              Get.to(() => PdfViewerScreen(url: url));
                            } else {
                              showDialog(
                                context: Get.context!,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: InteractiveViewer(
                                    child: Image.network(url),
                                  ),
                                ),
                              );
                            }
                          },
                          child: type == 'pdf'
                              ? Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                            child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),

            /// ✏️ Edit & Delete Buttons (right top)
            Positioned(
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
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
