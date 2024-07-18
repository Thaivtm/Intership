import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class ResultHandler {
  final FirebaseFirestore _firestore;
  final Map<String, List<dynamic>> _previousResult= {};
  final Map<String, StreamSubscription> _ResultSubscriptions = {};

  ResultHandler(this._firestore);

  StreamSubscription ResultListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          _listenToResultChanges(courseId);
        }
      }
    });
  }

  void _listenToResultChanges(String courseId) {
    _ResultSubscriptions[courseId]?.cancel();

    _ResultSubscriptions[courseId] = _firestore
        .collection('course')
        .doc(courseId)
        .collection('results')
        .snapshots()
        .listen((snapshot) {
      List<dynamic> newResult = snapshot.docs.map((doc) => doc.id).toList();
      List<dynamic> oldResult = _previousResult[courseId] ?? [];

      List<dynamic> addedResult =
          newResult.where((field) => !oldResult.contains(field)).toList();
      List<dynamic> removedResult =
          oldResult.where((field) => !newResult.contains(field)).toList();

      if (addedResult.isNotEmpty) {
        print('Added files: $addedResult');
        _notifyResultChange(courseId, addedResult, true);
      }

      if (removedResult.isNotEmpty) {
        print('Removed files: $removedResult');
        _notifyResultChange(courseId, removedResult, false);
      }

      _previousResult[courseId] = newResult;
    }, onError: (error) {
      print('Error listening to field changes for course $courseId: $error');
    });
  }

  void _notifyResultChange(
      String courseId, List<dynamic> ResultChange, bool isAdded) async {
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

          for (var recipients in recipients) {
            _firestore.collection('notifications').add({
              'message':
                  'A new feed has been ${isAdded ? 'added to' : 'deleted from'} course $courseName',
              'file_change': ResultChange,
              'timestamp': FieldValue.serverTimestamp(),
              'sendto': recipients,
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
