import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/QuizPlay/result_screen.dart';

class PlayQuiz extends StatefulWidget {
  final String courseId;
  final String quizId;

  const PlayQuiz({required this.courseId, required this.quizId, super.key});

  @override
  _PlayQuizState createState() => _PlayQuizState();
}

class _PlayQuizState extends State<PlayQuiz> {
  List<Map<String, dynamic>>? _questions;
  late ValueNotifier<List<String?>> selectedOptionList;
  bool isSubmitted = false;
  Timer? _timer;
  late ValueNotifier<int> _remainingTime;
  String? _userId;

  @override
  void initState() {
    super.initState();
    selectedOptionList = ValueNotifier<List<String?>>([]);
    _remainingTime = ValueNotifier<int>(0);
    _fetchCurrentUserId();
  }

  @override
  void dispose() {
    _timer?.cancel();
    selectedOptionList.dispose();
    _remainingTime.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('course')
            .doc(widget.courseId)
            .collection('quizzes')
            .doc(widget.quizId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Quiz not found.'));
          }

          final quizData = snapshot.data!.data() as Map<String, dynamic>?;

          if (quizData == null || !quizData.containsKey('questions')) {
            return const Center(child: Text('Error: Quiz data is invalid.'));
          }

          _questions = List<Map<String, dynamic>>.from(quizData['questions']);

          if (_questions!.isEmpty) {
            return const Center(
                child: Text('No questions found for this quiz.'));
          }

          if (_userId != null) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('course')
                  .doc(widget.courseId)
                  .collection('quizzes')
                  .doc(widget.quizId)
                  .collection('results')
                  .where('userId', isEqualTo: _userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                int attemptsMade = snapshot.data?.size ?? 0;

                if (attemptsMade >= quizData['attempts_allowed']) {
                  return _buildQuizLimitExceededDialog();
                } else {
                  if (selectedOptionList.value.isEmpty) {
                    selectedOptionList.value =
                        List<String?>.filled(_questions!.length, null);
                  }

                  if (_timer == null &&
                      quizData.containsKey('time_in_minutes')) {
                    int timeInMinutes = quizData['time_in_minutes'];
                    _remainingTime.value = timeInMinutes * 60;
                    _startTimer();
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 70,
                          bottom: 10,
                        ),
                        child: _buildTimer(),
                      ),
                      Expanded(
                        child: _buildQuizScreen(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSubmitButton(),
                      ),
                    ],
                  );
                }
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildQuizLimitExceededDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Limit Exceeded'),
          content: const Text(
              'You have already attempted the maximum allowed times for this quiz.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
    return Container(); // Return an empty container to prevent building further widgets
  }

  Widget _buildTimer() {
    return ValueListenableBuilder<int>(
      valueListenable: _remainingTime,
      builder: (context, remainingTime, _) {
        int minutes = remainingTime ~/ 60;
        int seconds = remainingTime % 60;
        Color timerColor = remainingTime <= 60 ? Colors.red : Colors.black;

        return Text(
          'Time remaining: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        );
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.value > 0) {
        _remainingTime.value--;
      } else {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    if (!isSubmitted) {
      setState(() {
        isSubmitted = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            courseId: widget.courseId,
            quizId: widget.quizId,
            questions: _questions!,
            selectedOptions: selectedOptionList.value,
          ),
        ),
      );
    }
  }

  Widget _buildQuizScreen() {
    return ValueListenableBuilder<List<String?>>(
      valueListenable: selectedOptionList,
      builder: (context, selectedOptions, _) {
        return ListView.builder(
          itemCount: _questions!.length,
          itemBuilder: (BuildContext context, int index) {
            final question = _questions![index];

            return Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}: ',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          question['Question'] ?? '',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...['OptionA', 'OptionB', 'OptionC', 'OptionD']
                          .map((optionKey) {
                        final optionText = question[optionKey] ?? '';
                        final isSelected = selectedOptions[index] == optionText;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 0),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (!isSubmitted) {
                                  selectedOptionList.value =
                                      List.from(selectedOptionList.value)
                                        ..[index] = optionText;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (!isSubmitted) {
          _showSubmitConfirmationDialog();
        }
      },
      child: const Text('Submit'),
    );
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: const Text(
            'Are you sure you want to submit the quiz? You still have time remaining.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _autoSubmit();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
