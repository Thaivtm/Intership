import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

class EditVideoScreen extends StatefulWidget {
  final String courseId;

  const EditVideoScreen({super.key, required this.courseId});

  @override
  _EditVideoScreenState createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen>
    with WidgetsBindingObserver {
  late Future<QuerySnapshot> _futureFiles;
  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];
  final List<Map<String, dynamic>> _updatedFiles = [];

  @override
  void initState() {
    super.initState();
    _futureFiles = _fetchFiles();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<QuerySnapshot> _fetchFiles() async {
    return FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .collection('files')
        .where('file_type', whereIn: ['audio/mp3', 'video/mp4']).get();
  }

  Future<void> _addFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp4'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      String filePath = file.path!;
      String? mimeType = lookupMimeType(filePath);

      if (mimeType == 'audio/mp3' || mimeType == 'video/mp4') {
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
        print("Unsupported file type");
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
          title: const Text('Edit Video File'),
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
          title: const Text('Delete Video File'),
          content:
              const Text('Are you sure you want to delete this video file?'),
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
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    for (var controller in _chewieControllers) {
      controller.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      for (var controller in _videoControllers) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Video Files'),
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
            return const Center(child: Text('No video files found'));
          }

          final videoFiles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videoFiles.length + _updatedFiles.length,
            itemBuilder: (context, index) {
              final data = index < videoFiles.length
                  ? videoFiles[index].data() as Map<String, dynamic>
                  : _updatedFiles[index - videoFiles.length];
              final fileName = data['file_name'] ?? '';
              final fileUrl = data['file_url'] ?? '';
              final videoPlayerController =
                  VideoPlayerController.network(fileUrl);
              final chewieController = ChewieController(
                videoPlayerController: videoPlayerController,
                autoPlay: false,
                looping: false,
              );
              _videoControllers.add(videoPlayerController);
              _chewieControllers.add(chewieController);

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                            child: Chewie(controller: chewieController),
                          ),
                        ),
                        if (index < videoFiles.length)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: () =>
                                      _editFile(videoFiles[index].id, fileName),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () =>
                                      _deleteFile(videoFiles[index].id),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
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
