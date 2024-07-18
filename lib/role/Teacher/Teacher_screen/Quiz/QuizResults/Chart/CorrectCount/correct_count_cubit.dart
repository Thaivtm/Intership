import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import 'correct_count_state.dart';

class CorrectCountCubit extends Cubit<CorrectCountState> {
  CorrectCountCubit({
    required List<BarChartGroupData> barChartData,
    required Map<String, String> userNames,
    required Map<String, List<String>> correctUsersPerQuestion,
  }) : super(CorrectCountState(
          barChartData: barChartData,
          userNames: userNames,
          correctUsersPerQuestion: correctUsersPerQuestion,
        ));
}
