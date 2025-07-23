import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/notice_card.dart'; // 👈 Import your PdfViewerScreen
import 'package:campus_notice_app/Screens/FullScreenImageView.dart'; // 👈 If you have image viewer
import 'package:intl/intl.dart';

class DownloadHistoryScreen extends StatelessWidget {
  const DownloadHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Download History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('downloadHistory')
            .where('userId', isEqualTo: user.uid)
            .orderBy('downloadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No download history found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final fileName = data['fileName'] ?? '';
              final title = data['title'] ?? 'No title';
              final fileUrl = data['fileUrl'] ?? '';
              final downloadedAt = (data['downloadedAt'] as Timestamp).toDate();

              return ListTile(
                leading: fileName.toLowerCase().endsWith(".pdf")
                    ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                    : Image.network(
                  fileUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                title: Text(title),
                subtitle: Text(
                  "Downloaded on ${DateFormat.yMMMd().add_jm().format(downloadedAt)}",
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          url: fileUrl,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: fileUrl,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
