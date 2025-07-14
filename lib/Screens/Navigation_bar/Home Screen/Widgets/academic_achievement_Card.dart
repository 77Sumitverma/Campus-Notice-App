import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


Widget AcademicAchievementSection() {
  final updateController = Get.find<UpdateController>();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  return Obx(() {
    if (updateController.achievementsList.isEmpty) {
      return const Text(
        "No Achievements Available",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: updateController.achievementsList.length,
            itemBuilder: (context, index) {
              var data = updateController.achievementsList[index];
              return Transform.scale(
                scale: 0.95,
                child: academicAchievementCard(
                  studentName: data['name'] ?? '',
                  academicYear: data['year'] ?? '',
                  department: data['department'] ?? '',
                  achievement: data['achievement'] ?? '',
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: updateController.achievementsList.length,
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

Widget academicAchievementCard({
  required String studentName,
  required String academicYear,
  required String department,
  required String achievement,
}) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🏆 Student Name
          Text(
            studentName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 6),

          /// 🎓 Academic Year + Department
          Text(
            "$academicYear | $department",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          /// 🏅 Achievement Label
          Text(
            "🏅 Achievement:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),

          /// 🏆 Achievement Detail
          Text(
            achievement,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}