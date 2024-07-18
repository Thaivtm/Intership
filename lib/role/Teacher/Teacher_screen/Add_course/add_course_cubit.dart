import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Add_course/add_course_state.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class CourseCubit extends Cubit<CourseState> {
  CourseCubit() : super(CourseInitial());

  final TextEditingController courseName = TextEditingController();
  final TextEditingController courseDescription = TextEditingController();
  List<File> selectedFiles = [];
  List<List<QuizObject>> allQuizLists = [];
  String courseVisibility = 'Private';
  bool isLoading = false;

  int timeInMinutes = 0; // Thêm biến này
  int attemptsAllowed = 0; // Thêm biến này

  Future<void> sendData() async {
    emit(CourseLoading());

    if (courseName.text.isEmpty) {
      emit(CourseError('Course name is required'));
      return;
    }

    final userId = await getCurrentUserId();
    if (userId == null) return;

    String? bannerUrl = await _getRandomBannerUrl();
    if (bannerUrl == null) {
      emit(CourseError('Failed to get a banner image'));
      return;
    }

    CollectionReference courses =
        FirebaseFirestore.instance.collection('course');
    DocumentReference courseDocRef = await courses.add({
      'course_Name': courseName.text,
      'course_Description': courseDescription.text,
      'creator': userId,
      'Course_code': _generateRandomId(),
      'visibility': courseVisibility,
      'participants': [],
      'banner_url': bannerUrl,
      'timestamp': Timestamp.now(),
    });

    await _uploadFiles(courseDocRef);
    await _saveQuizzes(courseDocRef);

    emit(CourseAdded());
    courseName.clear();
    courseDescription.clear();
    selectedFiles.clear();
    allQuizLists.clear();
  }

  Future<String?> getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<String?> _getRandomBannerUrl() async {
    try {
      firebase_storage.ListResult result = await firebase_storage
          .FirebaseStorage.instance
          .ref('banner')
          .listAll();

      if (result.items.isEmpty) {
        return null;
      }

      List<String> bannerUrls = [];
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        bannerUrls.add(url);
      }

      final random = Random();
      String randomBannerUrl = bannerUrls[random.nextInt(bannerUrls.length)];
      return randomBannerUrl;
    } catch (e) {
      print('Error retrieving banners: $e');
      return null;
    }
  }

  Future<void> _uploadFiles(DocumentReference courseDocRef) async {
    for (File file in selectedFiles) {
      if (!file.existsSync()) {
        print("File $file does not exist or is invalid");
        continue;
      }

      try {
        String fileName = path.basename(file.path);
        String? mimeType = lookupMimeType(file.path);

        if (mimeType == null) {
          print("Failed to determine MIME type for file $fileName");
          continue;
        }

        firebase_storage.SettableMetadata metadata =
            firebase_storage.SettableMetadata(contentType: mimeType);
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('courses')
            .child(courseDocRef.id)
            .child(fileName);
        await ref.putFile(file, metadata);

        String downloadURL = await ref.getDownloadURL();
        print('Uploaded file: $fileName');
        print('Download URL: $downloadURL');

        await courseDocRef.collection('files').add({
          'file_name': fileName,
          'file_url': downloadURL,
          'file_type': mimeType,
          'timestamp': Timestamp.now(),
        });
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
  }

  Future<void> _saveQuizzes(DocumentReference courseDocRef) async {
    for (List<QuizObject> quizList in allQuizLists) {
      List<Map<String, dynamic>> quizDataList = quizList.map((quiz) {
        return {
          'Question': quiz.title,
          'OptionA': quiz.a,
          'OptionB': quiz.b,
          'OptionC': quiz.c,
          'OptionD': quiz.d,
          'CorrectAnswer': quiz.correctAnswerIndex,
        };
      }).toList();
      String quizId = _generateRandomId();

      await courseDocRef.collection('quizzes').doc(quizId).set({
        'questions': quizDataList,
        'timestamp': Timestamp.now(),
        'time_in_minutes': timeInMinutes,
        'attempts_allowed': attemptsAllowed,
      });
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp3', 'mp4'],
    );
    if (result != null) {
      selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      emit(CourseFileAdded(selectedFiles));
    }
  }

  void removeFile(File file) {
    selectedFiles.remove(file);
    emit(CourseFileAdded(selectedFiles));
  }

  void addQuiz(
      List<QuizObject> newQuizList, int timeInMinutes, int attemptsAllowed) {
    this.timeInMinutes = timeInMinutes;
    this.attemptsAllowed = attemptsAllowed;
    allQuizLists.add(newQuizList);
    emit(CourseQuizzesUpdated(allQuizLists));
  }

  void updateVisibility(String newVisibility) {
    courseVisibility = newVisibility;
    emit(CourseInitial());
  }

  String _generateRandomId() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }
}
