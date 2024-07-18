import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/create_quiz_dialog.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_item.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';

class EditQuizScreen extends StatefulWidget {
  final String courseId;

  const EditQuizScreen({super.key, required this.courseId});

  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  late List<QuizObject> questionList;
  TextEditingController timeController = TextEditingController();
  TextEditingController attemptsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionList = [];
  }

  @override
  void dispose() {
    timeController.dispose();
    attemptsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputInfo(
                  title: 'Time (in minutes)',
                  controller: timeController,
                  hint: 'Add Time',
                  obscureText: false,
                  iconData: Icons.access_time_outlined,
                ),
                const SizedBox(height: 16),
                InputInfo(
                  title: 'Attempts allowed',
                  controller: attemptsController,
                  hint: 'No. Attempt',
                  obscureText: false,
                  iconData: Icons.border_color,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questionList.length,
              itemBuilder: (context, index) {
                return QuizItem(
                  data: questionList[index],
                  index: index,
                  onDeletePressed: onDeleteQuiz,
                );
              },
            ),
          ),
        ],
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
              onTap: onPressAddQuiz,
              child: const Icon(Icons.add, size: 30, color: Colors.black),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: Button(title: 'Submit', onPressed: onPressSubmit),
      ),
    );
  }

  void onPressAddQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: CreateQuizDialog(
            onAdded: onAddQuiz,
          ),
        );
      },
    );
  }

  void onAddQuiz(QuizObject object) {
    setState(() {
      questionList.add(object);
    });
  }

  void onDeleteQuiz(int index) {
    setState(() {
      questionList.removeAt(index);
    });
  }

  void onPressSubmit() {
    if (questionList.isEmpty) {
      return;
    }

    int? timeInMinutes = int.tryParse(timeController.text);
    int? attemptsAllowed = int.tryParse(attemptsController.text);

    if (timeInMinutes == null || attemptsAllowed == null) {
      return;
    }

    CollectionReference quizzesRef = FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .collection('quizzes');

    List<Map<String, dynamic>> quizDataList = questionList.map((quizObject) {
      return {
        'Question': quizObject.title,
        'OptionA': quizObject.a,
        'OptionB': quizObject.b,
        'OptionC': quizObject.c,
        'OptionD': quizObject.d,
        'CorrectAnswer': quizObject.correctAnswerIndex,
      };
    }).toList();

    quizzesRef.add({
      'questions': quizDataList,
      'timestamp': Timestamp.now(),
      'time_in_minutes': timeInMinutes,
      'attempts_allowed': attemptsAllowed,
    }).then((value) {
      print('Quiz added to Firestore successfully!');

      Navigator.pop(context, true);
    }).catchError((error) {
      print('Error adding quiz questions to Firestore: $error');
    });
  }
}
