import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';

class EditQuestionScreen extends StatefulWidget {
  final String courseId;
  final String quizId;
  final Map<String, dynamic> questionData;
  final int questionIndex;

  EditQuestionScreen({
    super.key,
    required this.courseId,
    required this.quizId,
    required this.questionData,
    required this.questionIndex,
  });

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _optionAController;
  late TextEditingController _optionBController;
  late TextEditingController _optionCController;
  late TextEditingController _optionDController;
  late TextEditingController _correctAnswerController;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.questionData['Question']);
    _optionAController =
        TextEditingController(text: widget.questionData['OptionA']);
    _optionBController =
        TextEditingController(text: widget.questionData['OptionB']);
    _optionCController =
        TextEditingController(text: widget.questionData['OptionC']);
    _optionDController =
        TextEditingController(text: widget.questionData['OptionD']);
    _correctAnswerController =
        TextEditingController(text: widget.questionData['CorrectAnswer']);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      final updatedQuestionData = {
        'Question': _questionController.text,
        'OptionA': _optionAController.text,
        'OptionB': _optionBController.text,
        'OptionC': _optionCController.text,
        'OptionD': _optionDController.text,
        'CorrectAnswer': _correctAnswerController.text,
      };

      final docSnapshot = await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (docSnapshot.exists) {
        final questions = docSnapshot.data()?['questions'];
        if (questions != null) {
          List<Map<String, dynamic>> updatedQuestions = List.from(questions);
          updatedQuestions[widget.questionIndex] = updatedQuestionData;

          await FirebaseFirestore.instance
              .collection('course')
              .doc(widget.courseId)
              .collection('quizzes')
              .doc(widget.quizId)
              .update({
            'questions': updatedQuestions,
          });
        } else {
          List<Map<String, dynamic>> updatedQuestions = List.generate(
            widget.questionIndex + 1,
            (index) => index == widget.questionIndex ? updatedQuestionData : {},
            growable: true,
          );

          await FirebaseFirestore.instance
              .collection('course')
              .doc(widget.courseId)
              .collection('quizzes')
              .doc(widget.quizId)
              .set({
            'questions': updatedQuestions,
          }, SetOptions(merge: true));
        }

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InputInfo(
                title: 'Question',
                controller: _questionController,
                hint: 'Enter Question',
                obscureText: false,
                iconData: Icons.question_mark,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              InputInfo(
                title: 'Option A',
                controller: _optionAController,
                hint: 'Enter Option A',
                obscureText: false,
                iconData: Icons.filter_1_outlined,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              InputInfo(
                title: 'Option B',
                controller: _optionBController,
                hint: 'Enter Option B',
                obscureText: false,
                iconData: Icons.filter_2_outlined,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              InputInfo(
                title: 'Option C',
                controller: _optionCController,
                hint: 'Enter Option C',
                obscureText: false,
                iconData: Icons.filter_3_outlined,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              InputInfo(
                title: 'Option D',
                controller: _optionDController,
                hint: 'Enter Option D',
                obscureText: false,
                iconData: Icons.filter_4_outlined,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              InputInfo(
                title: 'Correct Answer',
                controller: _correctAnswerController,
                hint: 'Enter Correct Answer',
                obscureText: false,
                iconData: Icons.done,
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              Button(
                title: 'Save',
                onPressed: _saveQuestion,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
