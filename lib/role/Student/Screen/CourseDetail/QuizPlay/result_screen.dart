import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String courseId;
  final String quizId;
  final List<Map<String, dynamic>> questions;
  final List<String?> selectedOptions;

  const ResultPage({
    super.key,
    required this.courseId,
    required this.quizId,
    required this.questions,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    int correctAnswers = 0;

    for (int i = 0; i < questions.length; i++) {
      final correctAnswer = questions[i]['CorrectAnswer'];
      final selectedOption = selectedOptions[i];

      if (correctAnswer == selectedOption) {
        correctAnswers++;
      }
    }

    _saveResult(user.uid, correctAnswers);

    double percentage = (correctAnswers / questions.length) * 100;

    String scoreText = '$percentage';
    Color resultColor = percentage >= 50 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scoreText,
              style: TextStyle(fontSize: 48, color: resultColor),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Course Details'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveResult(String userId, int score) async {
    double percentage = (score / questions.length) * 100;
    String resultText = percentage >= 50 ? 'Pass' : 'Fail';

    final resultData = {
      'score': percentage,
      'finalState': resultText,
      'totalQuestions': questions.length,
      'timestamp': FieldValue.serverTimestamp(),
      'selectedOptions': selectedOptions,
      'userId': userId,
    };

    await FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .collection('quizzes')
        .doc(quizId)
        .collection('results')
        .add(resultData);
  }
}
