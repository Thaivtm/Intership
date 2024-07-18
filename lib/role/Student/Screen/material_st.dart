import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/quiz_files.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/slide_files.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/video_files.dart';

class CourseDetailStList extends StatelessWidget {
  final String courseId;
  final Function(bool) reloadCallback;
  final User user;

  const CourseDetailStList({
    super.key,
    required this.courseId,
    required this.reloadCallback,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Video Files',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              VideoFiles(courseId: courseId),
              const SizedBox(height: 20),
              const Text(
                'Slide Files',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SlideFiles(courseId: courseId),
              const SizedBox(height: 20),
              const Text(
                'Quizzes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              QuizFiles(
                courseId: courseId,
                userId: user.uid,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
