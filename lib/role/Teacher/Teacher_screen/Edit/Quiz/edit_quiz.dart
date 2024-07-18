import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Quiz/edit_quiz_item.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Quiz/quiz_list.dart';

class EditQuiz extends StatelessWidget {
  final String courseId;
  final String quizId;

  EditQuiz({super.key, required this.courseId, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('course')
            .doc(courseId)
            .collection('quizzes')
            .doc(quizId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No questions found'));
          }

          final quizData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> questions = quizData['questions'] ?? [];
          final int timeInMinutes = quizData['time_in_minutes'] ?? 0;
          final int attemptsAllowed = quizData['attempts_allowed'] ?? 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time in Minutes: $timeInMinutes',
                            style: const TextStyle(fontSize: 16)),
                        Text('Attempts Allowed: $attemptsAllowed',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size:25, color: Colors.black),
                      onPressed: () {
                        _showEditSettingsDialog(
                            context, timeInMinutes, attemptsAllowed);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final questionData =
                        questions[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QuizQuestionItem(
                        questionData: questionData,
                        onEditPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditQuestionScreen(
                                courseId: courseId,
                                quizId: quizId,
                                questionData: questionData,
                                questionIndex: index,
                              ),
                            ),
                          );
                        },
                        onDeletePressed: () async {
                          final bool confirmDelete =
                              await _showDeleteConfirmationDialog(context);
                          if (confirmDelete) {
                            await deleteQuestion(index);
                          }
                        },
                        questionIndex: index,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteQuestion(int index) async {
    final quizRef = FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .collection('quizzes')
        .doc(quizId);

    try {
      final quizSnapshot = await quizRef.get();
      final quizData = quizSnapshot.data() as Map<String, dynamic>;
      final questions = List.from(quizData['questions'] ?? []);

      if (index >= 0 && index < questions.length) {
        questions.removeAt(index);
        await quizRef.update({'questions': questions});
      } else {
        throw Exception('Invalid question index');
      }
    } catch (e) {
      print('Failed to delete question: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this question?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showEditSettingsDialog(
      BuildContext context, int timeInMinutes, int attemptsAllowed) {
    final TextEditingController timeController =
        TextEditingController(text: timeInMinutes.toString());
    final TextEditingController attemptsController =
        TextEditingController(text: attemptsAllowed.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Quiz Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time in Minutes'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: attemptsController,
                decoration:
                    const InputDecoration(labelText: 'Attempts Allowed'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final int newTime = int.parse(timeController.text);
                final int newAttempts = int.parse(attemptsController.text);
                await updateQuizSettings(newTime, newAttempts);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateQuizSettings(
      int timeInMinutes, int attemptsAllowed) async {
    final quizRef = FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .collection('quizzes')
        .doc(quizId);

    await quizRef.update({
      'time_in_minutes': timeInMinutes,
      'attempts_allowed': attemptsAllowed,
    });
  }
}
