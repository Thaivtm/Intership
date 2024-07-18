import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';

const options = ['A', 'B', 'C', 'D'];

class AddQuestionDialog extends StatefulWidget {
  final String courseId;
  final String quizId;

  AddQuestionDialog({super.key, required this.courseId, required this.quizId});

  @override
  _AddQuestionDialogState createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _optionCtrls = options.map((o) => TextEditingController()).toList();
  String? _errorMessage;
  int _correctOptionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Question",
                      style: TextStyle(
                        color: Color.fromARGB(255, 83, 83, 83),
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                InputInfo(
                  title: 'Question',
                  controller: _questionCtrl,
                  hint: 'Enter Question',
                  iconData: Icons.question_mark,
                  obscureText: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 15),
                InputInfo(
                  title: 'Option A',
                  controller: _optionCtrls[0],
                  hint: 'Enter Option A',
                  iconData: Icons.filter_1_outlined,
                  obscureText: false,
                  maxLines: 1,
                ),
                InputInfo(
                  title: 'Option B',
                  controller: _optionCtrls[1],
                  hint: 'Enter Option B',
                  iconData: Icons.filter_2_outlined,
                  obscureText: false,
                  maxLines: 1,
                ),
                InputInfo(
                  title: 'Option C',
                  controller: _optionCtrls[2],
                  hint: 'Enter Option C',
                  iconData: Icons.filter_3_outlined,
                  obscureText: false,
                  maxLines: 1,
                ),
                InputInfo(
                  title: 'Option D',
                  controller: _optionCtrls[3],
                  hint: 'Enter Option D',
                  iconData: Icons.filter_4_outlined,
                  obscureText: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Correct Option",
                  style: TextStyle(
                    color: Color.fromARGB(255, 83, 83, 83),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options.map((option) {
                    int index = options.indexOf(option);
                    return Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctOptionIndex,
                          onChanged: (value) {
                            setState(() {
                              _correctOptionIndex = value!;
                            });
                          },
                        ),
                        Text(option),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                if (_errorMessage != null)
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 5),
                Button(
                  title: 'Add question',
                  onPressed: _saveQuestion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveQuestion() async {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      if (_questionCtrl.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all fields';
        });
        return;
      }

      for (int i = 0; i < options.length; i++) {
        if (_optionCtrls[i].text.isEmpty) {
          setState(() {
            _errorMessage = 'Please fill in all fields';
          });
          return;
        }
      }

      try {
        final newQuestionData = {
          'Question': _questionCtrl.text,
          'OptionA': _optionCtrls[0].text,
          'OptionB': _optionCtrls[1].text,
          'OptionC': _optionCtrls[2].text,
          'OptionD': _optionCtrls[3].text,
          'CorrectAnswer': _optionCtrls[_correctOptionIndex].text,
        };

        await FirebaseFirestore.instance
            .collection('course')
            .doc(widget.courseId)
            .collection('quizzes')
            .doc(widget.quizId)
            .update({
          'questions': FieldValue.arrayUnion([newQuestionData]),
        });

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to add question: $e';
        });
      }
    }
  }
}
