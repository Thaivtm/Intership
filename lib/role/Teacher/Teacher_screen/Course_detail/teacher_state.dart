import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TeacherState {}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherCoursesLoaded extends TeacherState {
  final List<DocumentSnapshot> courses;

  TeacherCoursesLoaded(this.courses);
}

class TeacherCoursesSearched extends TeacherState {
  final List<DocumentSnapshot> courses;

  TeacherCoursesSearched(this.courses);
}

class TeacherError extends TeacherState {
  final String message;

  TeacherError(this.message);
}
