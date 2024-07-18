import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/UserScore/user_score_cubit.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/UserScore/user_score_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScoreChart extends StatelessWidget {
  final List<BarChartGroupData> userScoreChartData;
  final Map<String, String> userNames;

  UserScoreChart({
    super.key,
    required this.userScoreChartData,
    required this.userNames,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserScoreCubit(
        userScoreChartData: userScoreChartData,
        userNames: userNames,
      ),
      child: BlocBuilder<UserScoreCubit, UserScoreState>(
        builder: (context, state) {
          return SizedBox(
            height: 350,
            child: Column(
              children: [
                const Text(
                  'User Scores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: state.userScoreChartData,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              final userId = state.userNames.keys.toList()[index];
                              final userName = state.userNames[userId] ?? 'Unknown';
                              return Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 50,
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final userIndex = group.x;
                            final userId = state.userNames.keys.toList()[userIndex];
                            final userName = state.userNames[userId] ?? 'Unknown';
                            final userScore = rod.toY;
                            return BarTooltipItem(
                              '$userName\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Score: $userScore',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback:
                            (FlTouchEvent event, BarTouchResponse? touchResponse) {},
                      ),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
