import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizResultsState extends Equatable {
  final bool isLoading;
  final List<BarChartGroupData> barChartData;
  final List<BarChartGroupData> userScoreChartData;
  final Map<String, String> userNames;
  final Map<String, String> correctAnswers;
  final Map<String, List<String>> correctUsersPerQuestion;
  final List<dynamic> results;

  const QuizResultsState({
    required this.isLoading,
    required this.barChartData,
    required this.userScoreChartData,
    required this.userNames,
    required this.correctAnswers,
    required this.correctUsersPerQuestion,
    required this.results,
  });

  QuizResultsState copyWith({
    bool? isLoading,
    List<BarChartGroupData>? barChartData,
    List<BarChartGroupData>? userScoreChartData,
    Map<String, String>? userNames,
    Map<String, String>? correctAnswers,
    Map<String, List<String>>? correctUsersPerQuestion,
    List<dynamic>? results,
  }) {
    return QuizResultsState(
      isLoading: isLoading ?? this.isLoading,
      barChartData: barChartData ?? this.barChartData,
      userScoreChartData: userScoreChartData ?? this.userScoreChartData,
      userNames: userNames ?? this.userNames,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      correctUsersPerQuestion: correctUsersPerQuestion ?? this.correctUsersPerQuestion,
      results: results ?? this.results,
    );
  }

  @override
  List<Object> get props => [isLoading, barChartData, userScoreChartData, userNames, correctAnswers, correctUsersPerQuestion, results];
}
