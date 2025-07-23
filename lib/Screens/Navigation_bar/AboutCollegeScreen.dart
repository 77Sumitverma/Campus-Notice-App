import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCollegeScreen extends StatefulWidget {
  const AboutCollegeScreen({super.key});

  @override
  State<AboutCollegeScreen> createState() => _AboutCollegeScreenState();
}

class _AboutCollegeScreenState extends State<AboutCollegeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;


  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@studyhallcollege.org',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Show a dialog or snackbar
      print('Could not launch email');
    }
  }

  final List<Map<String, String>> facultyList = [
    {
      'name': 'Dr. Himanshu Verma',
      'position': 'Director',
      'department': 'Administration',
      'imageUrl': 'lib/assets/images/Himanshu_sir.png',
    },
    {
      'name': 'Prof. Neha Verma',
      'position': 'Dean',
      'department': 'Computer Science',
      'imageUrl': 'lib/assets/images/neha_mam.png',
    },
    {
      'name': 'Prof. Naval Kishor Gupta',
      'position': 'HOD, BCA',
      'department': 'Computer Science',
      'imageUrl': 'lib/assets/images/naval_sir.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildFacultyCard(Map<String, String> faculty) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.deepPurple.shade50,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundImage: faculty['imageUrl']!.startsWith('http')
                  ? NetworkImage(faculty['imageUrl']!)
                  : AssetImage(faculty['imageUrl']!) as ImageProvider,
              radius: 30,
            ),
            title: Text(
              faculty['name']!,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${faculty['position']} • ${faculty['department']}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildClickableRow({required IconData icon, required String label, required String url}) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.deepPurple.shade900,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: const Text("About College"),
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 4,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "lib/assets/images/study_hall_college_logo.webp",
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "The Study Hall College",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "About Us",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "The Study Hall College is a premier institute offering top-notch education in courses like BCA, BBA, B.COM, and BJMC. We aim to nurture professionals with quality teaching and modern infrastructure.",
                style: GoogleFonts.poppins(fontSize: 15),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Text(
                "Our Faculty",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              const SizedBox(height: 10),
              ...facultyList.map(buildFacultyCard).toList(),
              const SizedBox(height: 20),
              Text(
                "Contact Us",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // Phone
              buildClickableRow(
                icon: Icons.phone,
                label: "+91 84000 78621",
                url: "tel:+918400078621",
              ),

              // Email
              buildClickableRow(
                icon: Icons.email,
                label: "info@studyhallcollege.org",
                url: "mailto:info@studyhallcollege.org",
              ),

              // Location
              buildClickableRow(
                icon: Icons.location_on,
                label: "Piparsand - Kanpur Road, Lucknow (U.P.)",
                url: "https://www.google.com/maps/search/?api=1&query=Piparsand+-+Kanpur+Road,+Lucknow",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
