import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';

const options = ['A', 'B', 'C', 'D'];

class CreateQuizDialog extends StatefulWidget {
  const CreateQuizDialog({super.key, this.onAdded});

  final Function(QuizObject)? onAdded;

  @override
  State<CreateQuizDialog> createState() => _CreateQuizDialogState();
}

class _CreateQuizDialogState extends State<CreateQuizDialog> {
  final _questionCtrl = TextEditingController();
  final _optionCtrls = options.map((o) => TextEditingController()).toList();
  String? _errorMessage;
  int _correctOptionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Question",
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
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
            const SizedBox(height: 15),
            Column(
              children: [
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
              ],
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                Button(
                  title: 'Add question',
                  onPressed: () {
                    if (_questionCtrl.text.isNotEmpty &&
                        _optionCtrls.every((ctrl) => ctrl.text.isNotEmpty)) {
                      final quizObject = QuizObject(
                        title: _questionCtrl.text,
                        a: _optionCtrls[0].text,
                        b: _optionCtrls[1].text,
                        c: _optionCtrls[2].text,
                        d: _optionCtrls[3].text,
                        correctAnswerIndex:
                            _optionCtrls[_correctOptionIndex].text,
                      );
                      widget.onAdded?.call(quizObject);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _errorMessage = 'Please fill in all fields';
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
