import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/slide_card.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/pdf_viewer.dart';
import 'package:mime/mime.dart';

class EditSlideScreen extends StatefulWidget {
  final String courseId;

  const EditSlideScreen({super.key, required this.courseId});

  @override
  _EditSlideScreenState createState() => _EditSlideScreenState();
}

class _EditSlideScreenState extends State<EditSlideScreen> {
  late Future<QuerySnapshot> _futureFiles;
  List<Map<String, dynamic>> _updatedFiles = [];

  @override
  void initState() {
    super.initState();
    _futureFiles = _fetchFiles();
  }

  Future<QuerySnapshot> _fetchFiles() async {
    return FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .collection('files')
        .where('file_type', isEqualTo: 'application/pdf')
        .get();
  }

  Future<void> _addFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      String filePath = file.path!;

      String? mimeType = lookupMimeType(filePath);

      if (mimeType == 'application/pdf') {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('courses')
            .child(widget.courseId)
            .child(fileName);

        try {
          await ref.putFile(File(filePath),
              firebase_storage.SettableMetadata(contentType: mimeType));
          String downloadURL = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('course')
              .doc(widget.courseId)
              .collection('files')
              .add({
            'file_name': fileName,
            'file_url': downloadURL,
            'file_type': mimeType,
          });

          setState(() {
            _futureFiles = _fetchFiles();
          });
        } catch (e) {
          print("Error uploading file: $e");
        }
      } else {
        print("Selected file is not a PDF.");
      }
    }
  }

  void _editFile(String fileId, String currentFileName) {
    TextEditingController _controller =
        TextEditingController(text: currentFileName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Slide File'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'File Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('course')
                    .doc(widget.courseId)
                    .collection('files')
                    .doc(fileId)
                    .update({'file_name': _controller.text}).then((_) {
                  setState(() {
                    _futureFiles = _fetchFiles();
                  });
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(String fileId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Slide File'),
          content:
              const Text('Are you sure you want to delete this slide file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('course')
                    .doc(widget.courseId)
                    .collection('files')
                    .doc(fileId)
                    .delete()
                    .then((_) {
                  setState(() {
                    _futureFiles = _fetchFiles();
                  });
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUpdates() async {
    try {
      for (var file in _updatedFiles) {
        if (file['is_new'] == true) {
          await FirebaseFirestore.instance
              .collection('course')
              .doc(widget.courseId)
              .collection('files')
              .add(file);
        }
      }
      setState(() {
        _futureFiles = _fetchFiles();
        _updatedFiles.clear();
      });
      Navigator.pop(context, true);
    } catch (e) {
      print("Error saving updates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Slide Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUpdates,
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _futureFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No slide files found'));
          }

          final slideFiles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: slideFiles.length + _updatedFiles.length,
            itemBuilder: (context, index) {
              if (index < slideFiles.length) {
                final doc = slideFiles[index];
                final data = doc.data() as Map<String, dynamic>;
                final fileName = data['file_name'] ?? '';
                final fileUrl = data['file_url'] ?? '';

                return SlideFileCard(
                  fileName: fileName,
                  fileUrl: fileUrl,
                  onEdit: () => _editFile(doc.id, fileName),
                  onDelete: () => _deleteFile(doc.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPdfViewer(fileUrl: fileUrl),
                      ),
                    );
                  },
                );
              } else {
                final newFile = _updatedFiles[index - slideFiles.length];
                final fileName = newFile['file_name'];
                final fileUrl = newFile['file_url'];

                return SlideFileCard(
                  fileName: fileName,
                  fileUrl: fileUrl,
                  onEdit: null,
                  onDelete: null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPdfViewer(fileUrl: fileUrl),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _addFile,
              child: const Icon(Icons.add, size: 30, color: Colors.black),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
