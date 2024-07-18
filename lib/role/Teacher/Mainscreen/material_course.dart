import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/course_material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/slide_files.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/video_files.dart';
import 'package:flutter_application_1/role/Teacher/Mainscreen/quiz_file.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Quiz/more_quiz.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/edit_slide.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/edit_video.dart';

class CourseDetailList extends StatelessWidget {
  final String courseId;
  final Function(bool) reloadCallback;
  final User user;

  const CourseDetailList({
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
              CourseMaterial(
                iconData: Icons.edit,
                title: 'Video Files',
                onchange: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditVideoScreen(
                        courseId: courseId,
                      ),
                    ),
                  );

                  if (result == true) {
                    reloadCallback(true);
                  }
                },
              ),
              const SizedBox(height: 10),
              VideoFiles(courseId: courseId),
              const SizedBox(height: 20),
              CourseMaterial(
                iconData: Icons.edit,
                title: 'Slide Files',
                onchange: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSlideScreen(
                        courseId: courseId,
                      ),
                    ),
                  );

                  if (result == true) {
                    reloadCallback(true);
                  }
                },
              ),
              SlideFiles(courseId: courseId),
              const SizedBox(height: 20),
              CourseMaterial(
                iconData: Icons.add,
                title: 'Quizzes',
                onchange: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditQuizScreen(
                        courseId: courseId,
                      ),
                    ),
                  );

                  if (result == true) {
                    reloadCallback(true);
                  }
                },
              ),
              QuizFileTeacher(
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
