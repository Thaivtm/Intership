import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizResults/Chart/UserScore/user_score_state.dart';


class UserScoreCubit extends Cubit<UserScoreState> {
  UserScoreCubit({
    required List<BarChartGroupData> userScoreChartData,
    required Map<String, String> userNames,
  }) : super(UserScoreState(
          userScoreChartData: userScoreChartData,
          userNames: userNames,
        ));
}
