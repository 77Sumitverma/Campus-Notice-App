import 'package:campus_notice_app/Screens/Login_screen.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Add updates Screen/add_updates.dart';
import 'package:campus_notice_app/Screens/SignUp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/notice_Card.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/upcoming_events_Card.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/academic_achievement_Card.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/exam_Card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  final _advancedDrawerController = AdvancedDrawerController();

  String userName = "Loading...";
  String userEmail = "Email...";
  String userPhone = "Phone...";


  int _currentIndex = 0;

  final pageList = [
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 15),
          Text("Latest updates", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          NoticeCard(),
          SizedBox(height: 5),
          Text("Exams", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 5),
          ExamSection(),
          Text("Upcoming Events", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          UpcomingEventSection(),
          // SizedBox(height: 5),
          // Text("Academic Achievement", style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)),
          // SizedBox(height: 10),
          // AcademicAchievementSection()
        ]),
      ),
    ),

    Center(child: Text("Search", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(child: AddUpdates()),
    Center(child: Text("Downloads", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(child: Text("About Campus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);

    fetchUserName(); // 🔥 fetch name on login
  }

  Future<void> fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? "User";
          userEmail = doc['email'] ?? "Email";
          userPhone = doc['mobile'] ?? "Phone";
        });
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      controller: _advancedDrawerController,
      backdropColor: Colors.deepPurple,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('lib/assets/images/avtar.png'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 📧 Email Display
              ListTile(
                leading: Icon(Icons.email, color: Colors.white),
                title: Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              // 📞 Phone Display
              ListTile(
                leading: Icon(Icons.phone, color: Colors.white),
                title: Text(
                  userPhone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // About App
              drawerItem(Icons.info, 'About', () {
                _advancedDrawerController.hideDrawer();
                Get.defaultDialog(
                  title: "About App",
                  middleText: "Campus Notice App\nVersion 1.0\nMade by Sumit ❤️",
                  textConfirm: "OK",
                  onConfirm: () {
                    Get.back();
                  },
                );
              }),

              const Spacer(),

              // Logout
              drawerItem(Icons.logout, 'Logout', () async {
                _advancedDrawerController.hideDrawer();

                // ✅ Show Confirmation Dialog
                Get.defaultDialog(
                  title: "Confirm Logout",
                  middleText: "Are you sure you want to logout?",
                  textCancel: "Cancel",
                  textConfirm: "Yes",
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    Get.back(); // Close the dialog
                    await FirebaseAuth.instance.signOut();
                    Get.snackbar("Logout", "Logged out successfully");
                    Get.offAll(() => LoginScreen());
                  },
                );
              }),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),


      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700.withOpacity(0.9),
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScaleTransition(
                scale: _animation,
                child: GestureDetector(
                  onTap: () {
                    _advancedDrawerController.showDrawer();
                  },
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/images/avtar.png'),
                    radius: 20,
                  ),
                ),
              ),
              const Text(
                "Campus Notice",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.snackbar("Notification", "No New Notifications");
                },
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
            ],
          ),
        ),

        body: pageList[_currentIndex],

        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.blue.shade50,
          color: Colors.blue.shade700,
          buttonBackgroundColor: Colors.blue.shade900,
          animationDuration: Duration(milliseconds: 400),
          height: 60,
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            Icon(Icons.home, color: Colors.white, size: 30),
            Icon(Icons.search, color: Colors.white, size: 30),
            Icon(Icons.add, color: Colors.white, size: 30),
            Icon(Icons.download, color: Colors.white, size: 30),
            Icon(Icons.apartment, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: () {
        onTap();
      },
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
