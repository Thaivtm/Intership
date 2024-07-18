import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/QuizPlay/quiz_play.dart';

class QuizFiles extends StatelessWidget {
  final String courseId;
  final String userId;

  QuizFiles({super.key, required this.courseId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .collection('quizzes')
          .orderBy('timestamp')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No quizzes available'));
        }

        final quizzes = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quizId = 'Quiz ${index + 1}';

                final resultsSnapshot = quizzes[index]
                    .reference
                    .collection('results')
                    .where('userId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots();

                return StreamBuilder<QuerySnapshot>(
                  stream: resultsSnapshot,
                  builder: (context, resultsSnapshot) {
                    String scoreText = 'Not Done';
                    Color scoreColor = Colors.black;

                    if (resultsSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        !resultsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final resultDocs = resultsSnapshot.data!.docs;

                    if (resultDocs.isNotEmpty) {
                      final resultData =
                          resultDocs.first.data() as Map<String, dynamic>;

                      if (resultData.containsKey('score')) {
                        final score = resultData['score'] as num;

                        scoreText = '$score';
                        scoreColor = score >= 50 ? Colors.green : Colors.red;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayQuiz(
                              courseId: courseId,
                              quizId: quizzes[index].id,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quizId,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                scoreText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
