import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'correct_count_cubit.dart';
import 'correct_count_state.dart';

class CorrectCountChart extends StatelessWidget {
  CorrectCountChart({
    super.key,
    required this.barChartData,
    required this.userNames,
    required this.correctUsersPerQuestion,
  });

  final List<BarChartGroupData> barChartData;
  final Map<String, String> userNames;
  final Map<String, List<String>> correctUsersPerQuestion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CorrectCountCubit(
        barChartData: barChartData,
        userNames: userNames,
        correctUsersPerQuestion: correctUsersPerQuestion,
      ),
      child: BlocBuilder<CorrectCountCubit, CorrectCountState>(
        builder: (context, state) {
          return SizedBox(
            height: 350,
            child: Column(
              children: [
                const Text(
                  'Correct count per Question',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: state.barChartData,
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
                              return Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final questionIndex = group.x;
                            final correctUsers =
                                state.correctUsersPerQuestion[questionIndex.toString()] ??
                                    [];
                            final userNamesList = correctUsers
                                .map((userId) => state.userNames[userId] ?? 'Unknown')
                                .join('\n');
                            return BarTooltipItem(
                              'Q${questionIndex + 1}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: userNamesList,
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
