import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.deepPurple.shade200,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,

      /// ✅ Drawer Content
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20),

              /// Profile Avatar
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('lib/assets/images/avtar.png'),
              ),
              const SizedBox(height: 15),

              /// Name
              const Text(
                'Sumit Verma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              /// Drawer Items
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.home),
                title: const Text('Home'),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.info),
                title: const Text('About'),
              ),

              const Spacer(),

              /// Logout
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      /// ✅ Main Screen with AppBar
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: const Text(
            "Profile Page",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// ✅ Circle Avatar to open Drawer
          leading: GestureDetector(
            onTap: _handleMenuButtonPressed,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/avtar.png'),
                radius: 20,
              ),
            ),
          ),
        ),

        /// ✅ Profile Page Body
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/avtar.png'),
                radius: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'Sumit Verma',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'sumit@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Drawer Open Function
  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
