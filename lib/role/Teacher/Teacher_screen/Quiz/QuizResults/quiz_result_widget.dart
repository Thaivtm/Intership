import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/CorrectCount/correct_count_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/UserScore/user_score_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/page_indicator.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/quiz_result_cubit.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/quiz_result_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizResultsPage extends StatefulWidget {
  final String courseId;
  final String quizId;

  QuizResultsPage({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  @override
  _QuizResultsPageState createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QuizResultsCubit(courseId: widget.courseId, quizId: widget.quizId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: BlocBuilder<QuizResultsCubit, QuizResultsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.results.isEmpty) {
              return const Center(child: Text('No results found.'));
            }

            return Column(
              children: [
                SizedBox(
                  height: 350,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      CorrectCountChart(
                        barChartData: state.barChartData,
                        userNames: state.userNames,
                        correctUsersPerQuestion: state.correctUsersPerQuestion,
                      ),
                      UserScoreChart(
                        userScoreChartData: state.userScoreChartData,
                        userNames: state.userNames,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: _buildPageIndicator(),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final doc = state.results[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final userName = state.userNames[data['userId']];
                      final selectedOptions =
                          data['selectedOptions'] as List<dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User: $userName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text('Score: ${data['score']}'),
                              const SizedBox(height: 5),
                              Text(
                                'Submit Time: ${(data['timestamp'] as Timestamp).toDate()}',
                              ),
                              const SizedBox(height: 5),
                              _buildAnswersTable(
                                  selectedOptions, state.correctAnswers),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return PageViewIndicator(
      controller: _pageController,
      itemCount: 2,
      color: Colors.grey,
      selectedColor: Colors.blue,
      size: 10,
      spacing: 8,
    );
  }

  Widget _buildAnswersTable(
      List<dynamic> selectedOptions, Map<String, String> correctAnswers) {
    List<Widget> columns = [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Question No.',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
                Text('Question', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Selected Option',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Correct Answer',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ];

    correctAnswers.forEach((question, correctAnswer) {
      final selectedAnswer =
          selectedOptions[correctAnswers.keys.toList().indexOf(question)];
      final questionNo = correctAnswers.keys.toList().indexOf(question) + 1;
      bool isCorrect = selectedAnswer == correctAnswer;
      Color textColor = isCorrect ? Colors.green : Colors.red;

      columns.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$questionNo'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(question),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedAnswer,
                style: TextStyle(color: textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(correctAnswer),
            ),
          ],
        ),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        children: columns
            .map((column) => Container(
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: column,
                ))
            .toList(),
      ),
    );
  }
}
