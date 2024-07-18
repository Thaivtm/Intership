import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/quiz_result_state.dart';

class QuizResultsCubit extends Cubit<QuizResultsState> {
  final String courseId;
  final String quizId;

  QuizResultsCubit({required this.courseId, required this.quizId})
      : super(const QuizResultsState(
          isLoading: true,
          barChartData: [],
          userScoreChartData: [],
          userNames: {},
          correctAnswers: {},
          correctUsersPerQuestion: {},
          results: [],
        )) {
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .collection('results')
          .orderBy('timestamp', descending: true)
          .get();

      final Map<String, QueryDocumentSnapshot> latestResults = {};

      // Lọc ra userId duy nhất với timestamp mới nhất
      for (var doc in snapshot.docs) {
        final userId = (doc.data() as Map<String, dynamic>)['userId'];
        if (!latestResults.containsKey(userId)) {
          latestResults[userId] = doc; // Lưu kết quả nếu chưa có
        }
      }

      final userIds = latestResults.keys.toList();
      final userNamesAndQuizData =
          await _getUserNamesAndQuizData(latestResults.values.toList());
      final userNames =
          userNamesAndQuizData['userNames'] as Map<String, String>;
      final correctAnswers =
          userNamesAndQuizData['correctAnswers'] as Map<String, String>;
      final correctUsersPerQuestion =
          userNamesAndQuizData['correctUsersPerQuestion']
              as Map<String, List<String>>;

      final barChartData = _createBarChartData(latestResults.values.toList(),
          correctAnswers, correctUsersPerQuestion);
      final userScoreChartData =
          _createUserScoreChartData(latestResults.values.toList(), userNames);

      emit(state.copyWith(
        isLoading: false,
        barChartData: barChartData,
        userScoreChartData: userScoreChartData,
        userNames: userNames,
        correctAnswers: correctAnswers,
        correctUsersPerQuestion: correctUsersPerQuestion,
        results: latestResults.values.toList(),
      ));
    } catch (e) {
      print('Error fetching results: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserNamesAndQuizData(
      List<QueryDocumentSnapshot> docs) async {
    Map<String, String> userNames = {};
    Map<String, String> correctAnswers = {};
    Map<String, List<String>> correctUsersPerQuestion = {};

    for (var doc in docs) {
      final userId = (doc.data() as Map<String, dynamic>)['userId'];
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      userNames[userId] = userData.data()?['user_Name'] ?? 'Unknown';
    }

    final quizDoc = await FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .collection('quizzes')
        .doc(quizId)
        .get();

    if (quizDoc.exists) {
      final quizData = quizDoc.data() as Map<String, dynamic>;
      final questions = quizData['questions'] as List<dynamic>;

      for (var question in questions) {
        correctAnswers[question['Question']] = question['CorrectAnswer'];
      }
    }

    return {
      'userNames': userNames,
      'correctAnswers': correctAnswers,
      'correctUsersPerQuestion': correctUsersPerQuestion,
    };
  }

  List<BarChartGroupData> _createBarChartData(
      List<QueryDocumentSnapshot> docs,
      Map<String, String> correctAnswers,
      Map<String, List<String>> correctUsersPerQuestion) {
    Map<String, int> correctCountPerQuestion = {};

    correctAnswers.keys.forEach((question) {
      correctCountPerQuestion[question] = 0;
    });

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'];
      final selectedOptions = data['selectedOptions'] as List<dynamic>;

      correctAnswers.forEach((question, correctAnswer) {
        final questionIndex = correctAnswers.keys.toList().indexOf(question);
        if (selectedOptions[questionIndex] == correctAnswer) {
          correctCountPerQuestion[question] =
              (correctCountPerQuestion[question] ?? 0) + 1;
          correctUsersPerQuestion
              .putIfAbsent(questionIndex.toString(), () => [])
              .add(userId);
        }
      });
    }

    return correctCountPerQuestion.entries.map((entry) {
      final questionIndex = correctAnswers.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: questionIndex,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(5),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: docs.length.toDouble(),
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _createUserScoreChartData(
      List<QueryDocumentSnapshot> docs, Map<String, String> userNames) {
    return docs.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value.data() as Map<String, dynamic>;
      final score = data['score'].toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: score,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(5),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: docs.length.toDouble(),
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
  }
}
