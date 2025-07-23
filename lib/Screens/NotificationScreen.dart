import 'package:flutter/material.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  void closeDrawer() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop(); // Close the drawer after animation
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.85;

    return GestureDetector(
      onTap: closeDrawer, // tap outside to close
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Stack(
          children: [
            // Slide-in Drawer
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: _offsetAnimation,
                child: SizedBox(
                  width: screenWidth,
                  child: Material(
                    elevation: 8,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Column(
                      children: [
                        AppBar(
                          automaticallyImplyLeading: false,
                          title: const Text("Notifications"),
                          backgroundColor: Colors.deepPurple,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: closeDrawer,
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: const [
                              ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text("New Notice Uploaded"),
                              ),
                              ListTile(
                                leading: Icon(Icons.note_add),
                                title: Text("Someone Uploaded a Note"),
                              ),
                              ListTile(
                                leading: Icon(Icons.lock_open),
                                title: Text("Unlock Request Received"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
