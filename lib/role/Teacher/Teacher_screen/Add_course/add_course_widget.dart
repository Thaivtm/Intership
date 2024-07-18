import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/components/loading_screen.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Teacher/Profie/profile_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Add_course/add_course_cubit.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Add_course/add_course_state.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Course_detail/teacher_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/create_quiz.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_item.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

class AddCourse extends StatelessWidget {
  const AddCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        title1: 'Home',
        icondata1: Icons.home,
        Page1: const TeacherWidget(),
        title2: 'Add Course',
        icondata2: Icons.upload,
        Page2: const AddCourse(),
        title3: 'Profile',
        icondata3: Icons.account_box_rounded,
        Page3: ProfilePage(),
      ),
      appBar: AppBar(
        title: const Text('Add Course'),
      ),
      body: BlocProvider(
        create: (context) => CourseCubit(),
        child: BlocConsumer<CourseCubit, CourseState>(
          listener: (context, state) {
            if (state is CourseError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ));
            } else if (state is CourseAdded) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const TeacherWidget()));
            }
          },
          builder: (context, state) {
            final courseCubit = context.read<CourseCubit>();

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 0, right: 15, left: 15),
                      child: Column(
                        children: [
                          Center(
                              child: Image.asset('assets/images/logo1.png',
                                  width: 250)),
                          InputInfo(
                            title: "Course Title",
                            controller: courseCubit.courseName,
                            hint: 'Enter Course Title',
                            iconData: Icons.title_sharp,
                            obscureText: false,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 15),
                          InputInfo(
                            title: "Course Description",
                            controller: courseCubit.courseDescription,
                            hint: 'Enter Course Description',
                            iconData: Icons.subtitles,
                            obscureText: false,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 30),
                          ...courseCubit.selectedFiles
                              .map((file) => _buildFileRow(context, file))
                              .toList(),
                          _buildFilePicker(context),
                          const SizedBox(height: 15),
                          _buildQuizSection(context),
                          const SizedBox(height: 40),
                          if (state is CourseError)
                            Text(state.message,
                                style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 5),
                          Button(
                              title: 'Add Course',
                              onPressed: courseCubit.sendData),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is CourseLoading) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFileRow(BuildContext context, File file) {
    String fileName = path.basename(file.path);
    String fileExtension = path.extension(file.path);
    return Row(
      children: [
        Expanded(
          child: Text(
            '$fileName ($fileExtension)',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => context.read<CourseCubit>().removeFile(file),
        ),
      ],
    );
  }

  Widget _buildFilePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CourseCubit>().pickFiles(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 83, 83, 83)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          children: [
            Icon(Icons.cloud_upload, size: 50),
            Text(
              "Drop Files Here",
              style: TextStyle(
                color: Color.fromARGB(255, 127, 123, 123),
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(BuildContext context) {
    final courseCubit = context.read<CourseCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Quizzes',
              style: TextStyle(
                color: Color.fromARGB(255, 83, 83, 83),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateQuiz(
                      courseName: courseCubit.courseName.text,
                      courseDescription: courseCubit.courseDescription.text,
                      selectedFiles: courseCubit.selectedFiles,
                      quizList: courseCubit.allQuizLists.isNotEmpty
                          ? courseCubit.allQuizLists.last
                          : [],
                    ),
                  ),
                );

                if (result != null) {
                  courseCubit.addQuiz(
                    result['quizList'] as List<QuizObject>,
                    result['timeInMinutes'] as int,
                    result['attemptsAllowed'] as int,
                  );
                }
              },
            ),
          ],
        ),
        Wrap(
          children: courseCubit.allQuizLists.asMap().entries.map((entry) {
            int index = entry.key;
            var quizList = entry.value;
            var timeInMinutes = courseCubit.timeInMinutes;
            var attemptsAllowed = courseCubit.attemptsAllowed;

            return GestureDetector(
              onTap: () => _handleQuizTap(
                  context, quizList, timeInMinutes, attemptsAllowed),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 83, 83, 83)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text('Quiz ${index + 1}',
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVisibilityDropdown(BuildContext context) {
    final courseCubit = context.read<CourseCubit>();

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: DropdownButtonFormField<String>(
          value: courseCubit.courseVisibility,
          items: ['Public', 'Private'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            courseCubit.updateVisibility(newValue!);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 83, 83, 83)),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 201, 174, 93), width: 4),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuizTap(BuildContext context, List<QuizObject> quizList,
      int timeInMinutes, int attemptsAllowed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Quiz Questions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time Allowed: $timeInMinutes minutes',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Attempts Allowed: $attemptsAllowed',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...quizList
                    .map((quiz) =>
                        QuizItem(data: quiz, index: quizList.indexOf(quiz)))
                    .toList(),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
