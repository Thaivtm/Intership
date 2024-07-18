import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFiles extends StatefulWidget {
  final String courseId;

  const VideoFiles({super.key, required this.courseId});

  @override
  _VideoFilesState createState() => _VideoFilesState();
}

class _VideoFilesState extends State<VideoFiles> with WidgetsBindingObserver {
  late Future<QuerySnapshot> _futureFiles;
  late List<VideoPlayerController> _videoControllers;
  late List<ChewieController> _chewieControllers;
  bool _shouldReload = false;

  @override
  void initState() {
    super.initState();
    _futureFiles = _fetchFiles();
    _videoControllers = [];
    _chewieControllers = [];
    WidgetsBinding.instance.addObserver(this);
  }

  Future<QuerySnapshot> _fetchFiles() async {
    return FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .collection('files')
        .where('file_type', whereIn: ['video/mp4', 'video/mp3']).get();
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

  void _reloadScreen() {
    setState(() {
      _futureFiles = _fetchFiles();
      _shouldReload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _futureFiles,
      builder: (context, snapshot) {
        if (_shouldReload) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No video files attached'));
        }

        final videoFiles = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: videoFiles.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fileName = data['file_name'] ?? '';
            final fileUrl = data['file_url'] ?? '';
            final videoPlayerController =
                // ignore: deprecated_member_use
                VideoPlayerController.network(fileUrl);
            final chewieController = ChewieController(
              videoPlayerController: videoPlayerController,
              autoPlay: false,
              looping: false,
            );
            _videoControllers.add(videoPlayerController);
            _chewieControllers.add(chewieController);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Colors.white,
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
                          child: Chewie(
                            controller: chewieController,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
