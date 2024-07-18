import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizzHandler {
  final FirebaseFirestore _firestore;
  final Map<String, List<dynamic>> _previousQuizz = {};
  final Map<String, StreamSubscription> _quizzSubscriptions = {};

  QuizzHandler(this._firestore) {
    _loadPreviousQuizz();
  }

  Future<void> _loadPreviousQuizz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedQuizz = prefs.getString('previousQuizz');
    if (storedQuizz != null) {
      Map<String, dynamic> decodedMap = jsonDecode(storedQuizz);
      decodedMap.forEach((key, value) {
        _previousQuizz[key] = List<dynamic>.from(value);
      });
    }
  }

  Future<void> _savePreviousQuizz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMap = jsonEncode(_previousQuizz);
    await prefs.setString('previousQuizz', encodedMap);
  }

  StreamSubscription quizListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          _listenToQuizChanges(courseId);
        }
      }
    });
  }

  void _listenToQuizChanges(String courseId) {
    _quizzSubscriptions[courseId]?.cancel();

    _quizzSubscriptions[courseId] = _firestore
        .collection('course')
        .doc(courseId)
        .collection('quizzes')
        .snapshots()
        .listen((snapshot) {
      List<dynamic> newQuizz = snapshot.docs.map((doc) => doc.id).toList();
      List<dynamic> oldQuizz = _previousQuizz[courseId] ?? [];

      List<dynamic> addedQuizz =
          newQuizz.where((field) => !oldQuizz.contains(field)).toList();
      List<dynamic> removedQuizz =
          oldQuizz.where((field) => !newQuizz.contains(field)).toList();

      if (addedQuizz.isNotEmpty) {
        print('Added quizzes: $addedQuizz');
        _notifyQuizzChange(courseId, addedQuizz, true);
      }

      if (removedQuizz.isNotEmpty) {
        print('Removed quizzes: $removedQuizz');
        _notifyQuizzChange(courseId, removedQuizz, false);
      }

      _previousQuizz[courseId] = newQuizz;
      _savePreviousQuizz(); // Save to persistent storage
    }, onError: (error) {
      print('Error listening to quiz changes for course $courseId: $error');
    });
  }

  void _notifyQuizzChange(
      String courseId, List<dynamic> quizzChange, bool isAdded) async {
    try {
      DocumentSnapshot courseSnapshot =
          await _firestore.collection('course').doc(courseId).get();
      if (courseSnapshot.exists) {
        Map<String, dynamic>? courseData =
            courseSnapshot.data() as Map<String, dynamic>?;

        if (courseData != null) {
          String creator = courseData['creator'];
          String courseName = courseData['course_Name'];
          List<dynamic> participants =
              List<dynamic>.from(courseData['participants'] ?? []);
          List<String> recipients = [creator, ...participants];

          for (var recipient in recipients) {
            _firestore.collection('notifications').add({
              'message':
                  'A quiz has been ${isAdded ? 'added to' : 'deleted from'} course $courseName',
              'quiz_change': quizzChange,
              'timestamp': FieldValue.serverTimestamp(),
              'sendto': recipient,
              'isRead': false,
            });
          }
        } else {
          print('Course data is null.');
        }
      } else {
        print('Course with ID $courseId does not exist.');
      }
    } catch (e) {
      print('Error fetching course details: $e');
    }
  }
}
