import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Quiz/edit_quiz.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/quiz_result_widget.dart';

class QuizFileTeacher extends StatefulWidget {
  final String courseId;
  final String userId;

  QuizFileTeacher({super.key, required this.courseId, required this.userId});

  @override
  _QuizFileTeacherState createState() => _QuizFileTeacherState();
}

class _QuizFileTeacherState extends State<QuizFileTeacher> {
  Future<QuerySnapshot>? _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = _fetchQuizzes();
  }

  Future<QuerySnapshot> _fetchQuizzes() {
    return FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .collection('quizzes')
        .orderBy('timestamp')
        .get();
  }

  void _reloadQuizzes() {
    setState(() {
      _quizFuture = _fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading quizzes'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No quizzes available'));
        }

        final quizzes = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quizData = quizzes[index].data() as Map<String, dynamic>;
            final quizId = quizzes[index].id;
            final questions = quizData['questions'] as List<dynamic>;

            return QuizListItemTeacher(
              courseId: widget.courseId,
              quizId: quizId,
              quizNumber: index + 1,
              questionsCount: questions.length,
              onDelete: _reloadQuizzes,
            );
          },
        );
      },
    );
  }
}

class QuizListItemTeacher extends StatelessWidget {
  final String courseId;
  final String quizId;
  final int quizNumber;
  final int questionsCount;
  final VoidCallback onDelete;

  QuizListItemTeacher({
    super.key,
    required this.courseId,
    required this.quizId,
    required this.quizNumber,
    required this.questionsCount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultsPage(
              courseId: courseId,
              quizId: quizId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz $quizNumber',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Number of Questions: $questionsCount',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditQuiz(
                            courseId: courseId,
                            quizId: quizId,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final bool confirmDelete =
                          await _showDeleteConfirmationDialog(context);
                      if (confirmDelete) {
                        await _deleteQuiz(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteQuiz(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .delete();
      onDelete();
    } catch (e) {
      print('Failed to delete quiz: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this quiz?'),
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
}
