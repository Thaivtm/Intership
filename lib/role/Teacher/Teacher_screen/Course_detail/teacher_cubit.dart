import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Course_detail/teacher_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherCubit extends Cubit<TeacherState> {
  late final String _userId;

  TeacherCubit() : super(TeacherInitial()) {
    _getCurrentUserId();
  }

  _getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  void updateCourseStream() {
    emit(TeacherLoading());
    FirebaseFirestore.instance
        .collection('course')
        .where('creator', isEqualTo: _userId)
        .snapshots()
        .listen((snapshot) {
      emit(TeacherCoursesLoaded(snapshot.docs));
    }, onError: (error) {
      emit(TeacherError(error.toString()));
    });
  }

  void searchCourses(String query) {
    emit(TeacherLoading());
    FirebaseFirestore.instance
        .collection('course')
        .where('creator', isEqualTo: _userId)
        .where('course_Name', isGreaterThanOrEqualTo: query)
        .where('course_Name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .listen((snapshot) {
      emit(TeacherCoursesSearched(snapshot.docs));
    }, onError: (error) {
      emit(TeacherError(error.toString()));
    });
  }
}
