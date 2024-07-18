import 'dart:io';

import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {}

class CourseError extends CourseState {
  final String message;

  CourseError(this.message);
}

class CourseAdded extends CourseState {}

class CourseFileAdded extends CourseState {
  final List<File> files;

  CourseFileAdded(this.files);
}

class CourseQuizzesUpdated extends CourseState {
  final List<List<QuizObject>> quizzes;

  CourseQuizzesUpdated(this.quizzes);
}
