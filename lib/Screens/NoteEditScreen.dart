import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  final String title;
  final String description;
  final List<String> fileUrls;
  final String course;
  final String semester;

  const EditNoteScreen({
    required this.noteId,
    required this.title,
    required this.description,
    required this.fileUrls,
    required this.course,
    required this.semester,
    super.key,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  List<String> _existingFileUrls = [];
  List<PlatformFile> _newFiles = [];
  bool _isUploading = false;

  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descController = TextEditingController(text: widget.description);
    _existingFileUrls = List.from(widget.fileUrls);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _newFiles.addAll(result.files);
      });
    }
  }

  void _removeExistingFile(String url) {
    setState(() {
      _existingFileUrls.remove(url);
    });
  }

  void _removeNewFile(int index) {
    setState(() {
      _newFiles.removeAt(index);
    });
  }

  Future<List<String>> _uploadNewFiles() async {
    List<String> urls = [];
    for (final file in _newFiles) {
      final fileBytes = File(file.path!).readAsBytesSync();
      final fileExt = file.extension ?? 'pdf';
      final fileName = "${const Uuid().v4()}.$fileExt";
      final path = "notes/$fileName";

      final response = await _supabase.storage.from('notesmedia').uploadBinary(path, fileBytes);
      final url = _supabase.storage.from('notesmedia').getPublicUrl(path);
      urls.add(url);
    }
    return urls;
  }

  Future<void> _deleteFileFromSupabase(String fileUrl) async {
    final bucket = 'notesmedia';
    final path = fileUrl.split('/').last.split('?').first;
    await _supabase.storage.from(bucket).remove(["notes/$path"]);
  }

  Future<void> _updateNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingFileUrls.isEmpty && _newFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("At least one file is required.")));
      return;
    }

    setState(() => _isUploading = true);

    final newUrls = await _uploadNewFiles();

    // Delete removed files from Supabase
    for (final originalUrl in widget.fileUrls) {
      if (!_existingFileUrls.contains(originalUrl)) {
        await _deleteFileFromSupabase(originalUrl);
      }
    }

    final updatedFiles = [..._existingFileUrls, ...newUrls];

    await _firestore.collection('notes').doc(widget.noteId).update({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'fileUrls': updatedFiles,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isUploading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null,
              ),
              const SizedBox(height: 20),
              const Text('Existing Files:'),
              Column(
                children: _existingFileUrls.map((url) {
                  return ListTile(
                    title: Text(url.split('/').last.split('?').first),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExistingFile(url),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('New Files:'),
              Column(
                children: _newFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return ListTile(
                    title: Text(file.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeNewFile(index),
                    ),
                  );
                }).toList(),
              ),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Files'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateNote,
                child: const Text('Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
