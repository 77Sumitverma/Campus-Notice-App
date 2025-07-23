import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:campus_notice_app/Services/NotesUploadService.dart';

class AddNotesScreen extends StatefulWidget {
  const AddNotesScreen({super.key});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? selectedCourse;
  String? selectedSemester;
  List<PlatformFile> selectedFiles = [];
  bool isPaid = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    }
  }

  void submitNote() async {
    if (_titleController.text.trim().isEmpty ||
        selectedFiles.isEmpty ||
        selectedCourse == null ||
        selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    try {
      await NotesUploadService().uploadNoteToFirestore(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        course: selectedCourse!,
        semester: selectedSemester!,
        files: selectedFiles,
        isPaid: isPaid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notes uploaded successfully")),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        setState(() {
          _titleController.clear();
          _descController.clear();
          selectedFiles.clear();
          selectedCourse = null;
          selectedSemester = null;
          isPaid = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: \${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Upload Notes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              color: Colors.deepPurple.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Note Title *", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Enter title",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Description (optional)"),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write something about the note...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Select Files (PDF/Image) *"),
                      ElevatedButton.icon(
                        onPressed: pickFiles,
                        icon: Icon(Icons.attach_file),
                        label: Text("Choose Files"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      if (selectedFiles.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: selectedFiles.map((file) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple),
                                title: Text(file.name, style: TextStyle(fontSize: 14)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      selectedFiles.remove(file);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      SizedBox(height: 15),
                      Text("Select Course *"),
                      DropdownButtonFormField<String>(
                        value: selectedCourse,
                        items: ['BCA', 'BJMC', 'BBA', 'BCOM']
                            .map((course) => DropdownMenuItem(value: course, child: Text(course)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedCourse = val),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Select Semester *"),
                      DropdownButtonFormField<String>(
                        value: selectedSemester,
                        items: ['1', '2', '3', '4', '5', '6']
                            .map((sem) => DropdownMenuItem(value: sem, child: Text("Semester $sem")))
                            .toList(),
                        onChanged: (val) => setState(() => selectedSemester = val),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(height: 15),
                      SwitchListTile(
                        title: Text("Mark as Paid Note"),
                        value: isPaid,
                        onChanged: (val) => setState(() => isPaid = val),
                        activeColor: Colors.deepPurple,
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: submitNote,
                          icon: Icon(Icons.cloud_upload),
                          label: Text("Upload Notes"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

