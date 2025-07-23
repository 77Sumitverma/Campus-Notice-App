import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_notice_app/Screens/FullScreenImageView.dart';
import 'package:campus_notice_app/Screens/NoteEditScreen.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/notice_Card.dart';
import 'package:campus_notice_app/Services/NotesUploadService.dart';

class NotesDisplayScreen extends StatelessWidget {
  const NotesDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Student Shared Notes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes found"));
          }

          final notes = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: notes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final note = notes[index].data() as Map<String, dynamic>;
                final noteId = notes[index].id;
                final title = note['title'] ?? '';
                final description = note['description'] ?? '';
                final uploader = note['uploaderName'] ?? 'Unknown';
                final isPaid = note['isPaid'] ?? false;
                final course = note['course'] ?? '';
                final semester = note['semester'] ?? '';
                final fileUrls = List<String>.from(note['fileUrls'] ?? []);
                final uploaderId = note['uploaderId'];
                final currentUser = FirebaseAuth.instance.currentUser;
                final isUploader = uploaderId == currentUser?.uid;

                return OpenContainer(
                  transitionDuration: const Duration(milliseconds: 500),
                  closedElevation: 6,
                  closedColor: Colors.deepPurple[100]!,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  openBuilder: (context, _) {
                    return Scaffold(
                      backgroundColor: Colors.deepPurple[50],
                      appBar: AppBar(
                        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.deepPurple,
                        actions: isUploader
                            ? [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditNoteScreen(
                                    noteId: noteId,
                                    title: title,
                                    description: description,
                                    fileUrls: fileUrls,
                                    course: course,
                                    semester: semester,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Note'),
                                  content: const Text('Are you sure you want to delete this note?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ]
                            : null,
                      ),
                      body: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text(description, style: GoogleFonts.poppins(fontSize: 16)),
                                const SizedBox(height: 8),
                                Text("Uploaded by: $uploader", style: GoogleFonts.poppins(fontSize: 14)),
                                const SizedBox(height: 20),
                                Text("Course: $course", style: GoogleFonts.poppins()),
                                Text("Semester: $semester", style: GoogleFonts.poppins()),
                                const SizedBox(height: 20),
                                Chip(
                                  label: Text(isPaid ? "Paid" : "Free"),
                                  backgroundColor: isPaid ? Colors.red : Colors.green,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 20),
                                Text("Preview Files", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 160,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: fileUrls.length,
                                    itemBuilder: (context, index) {
                                      final url = fileUrls[index];
                                      final isImage = url.endsWith('.jpg') || url.endsWith('.png');
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (isPaid) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Please pay to unlock")),
                                              );
                                              return;
                                            }

                                            if (url.endsWith('.pdf')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PdfViewerScreen(url: url), // ✅ Corrected here
                                                ),
                                              );
                                            } else if (isImage) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FullScreenImageView(imageUrl: url),
                                                ),
                                              );
                                            }
                                          },

                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: isImage
                                                    ? Image.network(
                                                  url,
                                                  width: 120,
                                                  height: 160,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 120,
                                                      height: 160,
                                                      color: Colors.grey[300],
                                                      alignment: Alignment.center,
                                                      child: const Text(
                                                        'No content found',
                                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                                                      ),
                                                    );
                                                  },
                                                )
                                                    : Container(
                                                  width: 120,
                                                  height: 160,
                                                  color: Colors.deepPurple[100],
                                                  child: const Icon(Icons.picture_as_pdf, size: 40),
                                                ),
                                              ),
                                              if (isPaid)
                                                Positioned.fill(
                                                  child: Container(
                                                    color: Colors.black.withOpacity(0.4),
                                                    alignment: Alignment.center,
                                                    child: const Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.lock, color: Colors.white, size: 40),
                                                        SizedBox(height: 8),
                                                        Text("Locked", style: TextStyle(color: Colors.white)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [

                                    ElevatedButton.icon(
                                      onPressed: isPaid || fileUrls.isEmpty ? null : () async {
                                        final granted = await requestPermissions();
                                        if (!granted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("❌ Permission denied. Cannot download.")),
                                          );
                                          return;
                                        }
                                        for (String url in fileUrls) {
                                          final fileName = url.split("/").last;

                                          await _downloadFile(context, url, fileName, noteId: noteId, title: title);
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("✅ All files downloaded!")),
                                        );
                                      },
                                      icon: const Icon(Icons.download, color: Colors.white),
                                      label: const Text("Download", style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        disabledBackgroundColor: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // "Request Unlock" Button
                                    if (isPaid)
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await sendUnlockRequest(
                                            uploaderId: uploaderId,
                                            noteId: noteId,
                                            noteTitle: title,
                                          );

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("📩 Unlock request sent")),
                                          );
                                        },
                                        icon: const Icon(Icons.lock_open, color: Colors.white),
                                        label: const Text("Request Unlock", style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                )],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  closedBuilder: (context, openContainer) => GestureDetector(
                    onTap: openContainer,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepPurple[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("Uploaded by: $uploader", style: GoogleFonts.poppins(fontSize: 12)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Chip(label: Text(course), backgroundColor: Colors.deepPurple),
                              Chip(label: Text("Sem $semester"), backgroundColor: Colors.deepPurple),
                              Chip(
                                label: Text(isPaid ? 'Paid' : 'Free'),
                                backgroundColor: isPaid ? Colors.red : Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
    }
    return false;
  }

  Future<void> _downloadFile(
      BuildContext context,
      String url,
      String fileName, {
        required String noteId,
        required String title,
      }) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory("/storage/emulated/0/Download");
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (!await dir.exists()) await dir.create(recursive: true);
      final savePath = "${dir.path}/$fileName";

      Dio dio = Dio();
      await dio.download(url, savePath);

      // ✅ Save to Firestore history
      await NotesUploadService().saveDownloadToHistory(
        noteId: noteId,
        title: title,
        fileName: fileName,
        fileUrl: url,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded: $fileName")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  Future<void> sendUnlockRequest({
    required String uploaderId,
    required String noteId,
    required String noteTitle,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final requestRef = FirebaseFirestore.instance.collection('unlock_requests');

    await requestRef.add({
      'noteId': noteId,
      'noteTitle': noteTitle,
      'requestedBy': currentUser.uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'uploaderId': uploaderId,
      'status': 'pending', // pending, approved, rejected
    });
  }


}
