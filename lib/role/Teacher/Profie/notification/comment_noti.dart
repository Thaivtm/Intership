import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentHandler {
  final FirebaseFirestore _firestore;
  final Map<String, List<dynamic>> _previousComment = {};
  final Map<String, StreamSubscription> _CommentSubscriptions = {};

  CommentHandler(this._firestore);

  StreamSubscription CommentListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          _listenToCommentChanges(courseId);
        }
      }
    });
  }

  void _listenToCommentChanges(String courseId) {
    _CommentSubscriptions[courseId]?.cancel();

    _CommentSubscriptions[courseId] = _firestore
        .collection('course')
        .doc(courseId)
        .collection('comment')
        .snapshots()
        .listen((snapshot) {
      List<dynamic> newComment = snapshot.docs.map((doc) => doc.id).toList();
      List<dynamic> oldComment = _previousComment[courseId] ?? [];

      List<dynamic> addedComment =
          newComment.where((field) => !oldComment.contains(field)).toList();
      List<dynamic> removedComment =
          oldComment.where((field) => !newComment.contains(field)).toList();

      if (addedComment.isNotEmpty) {
        print('Added files: $addedComment');
        _notifyCommentChange(courseId, addedComment, true);
      }

      if (removedComment.isNotEmpty) {
        print('Removed files: $removedComment');
        _notifyCommentChange(courseId, removedComment, false);
      }

      _previousComment[courseId] = newComment;
    }, onError: (error) {
      print('Error listening to field changes for course $courseId: $error');
    });
  }

  void _notifyCommentChange(
      String courseId, List<dynamic> CommentChange, bool isAdded) async {
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
              'file_change': CommentChange,
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
