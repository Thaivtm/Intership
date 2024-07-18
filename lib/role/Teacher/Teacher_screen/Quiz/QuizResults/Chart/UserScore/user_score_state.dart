import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

class UserScoreState extends Equatable {
  final List<BarChartGroupData> userScoreChartData;
  final Map<String, String> userNames;

  const UserScoreState({
    required this.userScoreChartData,
    required this.userNames,
  });

  @override
  List<Object?> get props => [userScoreChartData, userNames];
}
