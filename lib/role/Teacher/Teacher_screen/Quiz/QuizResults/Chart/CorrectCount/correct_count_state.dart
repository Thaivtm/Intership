import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

class CorrectCountState extends Equatable {
  final List<BarChartGroupData> barChartData;
  final Map<String, String> userNames;
  final Map<String, List<String>> correctUsersPerQuestion;

  const CorrectCountState({
    required this.barChartData,
    required this.userNames,
    required this.correctUsersPerQuestion,
  });

  @override
  List<Object?> get props => [barChartData, userNames, correctUsersPerQuestion];
}
