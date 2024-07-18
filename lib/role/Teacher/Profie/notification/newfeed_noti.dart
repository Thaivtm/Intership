import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class NewFeedHandler {
  final FirebaseFirestore _firestore;
  final Map<String, List<dynamic>> _previousNewFeed = {};
  final Map<String, StreamSubscription> _NewFeedSubscriptions = {};

  NewFeedHandler(this._firestore);

  StreamSubscription newFeedListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          _listenToNewFeedChanges(courseId);
        }
      }
    });
  }

  void _listenToNewFeedChanges(String courseId) {
    _NewFeedSubscriptions[courseId]?.cancel();

    _NewFeedSubscriptions[courseId] = _firestore
        .collection('course')
        .doc(courseId)
        .collection('newfeed')
        .snapshots()
        .listen((snapshot) {
      List<dynamic> newNewFeed = snapshot.docs.map((doc) => doc.id).toList();
      List<dynamic> oldNewFeed = _previousNewFeed[courseId] ?? [];

      List<dynamic> addedNewFeed =
          newNewFeed.where((field) => !oldNewFeed.contains(field)).toList();
      List<dynamic> removedNewFeed =
          oldNewFeed.where((field) => !newNewFeed.contains(field)).toList();

      if (addedNewFeed.isNotEmpty) {
        print('Added files: $addedNewFeed');
        _notifyNewFeedChange(courseId, addedNewFeed, true);
      }

      if (removedNewFeed.isNotEmpty) {
        print('Removed files: $removedNewFeed');
        _notifyNewFeedChange(courseId, removedNewFeed, false);
      }

      _previousNewFeed[courseId] = newNewFeed;
    }, onError: (error) {
      print('Error listening to field changes for course $courseId: $error');
    });
  }

  void _notifyNewFeedChange(
      String courseId, List<dynamic> QuizzChange, bool isAdded) async {
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
              'file_change': QuizzChange,
              'timestamp': FieldValue.serverTimestamp(),
              'sendto': recipients,
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
