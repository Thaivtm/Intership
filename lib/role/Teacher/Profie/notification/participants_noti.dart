import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParticipantsHandler {
  final FirebaseFirestore _firestore;
  Map<String, List<dynamic>> _previousParticipants = {};

  ParticipantsHandler(this._firestore) {
    _loadPreviousParticipants();
  }

  Future<void> _loadPreviousParticipants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedParticipants = prefs.getString('previousParticipants');
    if (storedParticipants != null) {
      Map<String, dynamic> decodedMap = jsonDecode(storedParticipants);
      _previousParticipants = decodedMap
          .map((key, value) => MapEntry(key, List<dynamic>.from(value)));
    }
  }

  Future<void> _savePreviousParticipants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMap = jsonEncode(_previousParticipants);
    await prefs.setString('previousParticipants', encodedMap);
  }

  StreamSubscription participantsListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          List<dynamic> newParticipants =
              change.doc.data()?['participants'] ?? [];
          List<dynamic> oldParticipants = _previousParticipants[courseId] ?? [];

          List<dynamic> addedParticipants = newParticipants
              .where((participant) => !oldParticipants.contains(participant))
              .toList();
          List<dynamic> deletedParticipants = oldParticipants
              .where((participant) => !newParticipants.contains(participant))
              .toList();

          if (addedParticipants.isNotEmpty) {
            _notifyParticipantsChange(courseId, addedParticipants, true);
          }

          if (deletedParticipants.isNotEmpty) {
            _notifyParticipantsChange(courseId, deletedParticipants, false);
          }

          _previousParticipants[courseId] = newParticipants;
          _savePreviousParticipants();
        }
      }
    });
  }

  Future<List<String>> _getParticipantNames(
      List<dynamic> participantIds) async {
    List<String> participantNames = [];
    for (String id in participantIds) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(id).get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          String? userName = userData['user_Name'];
          if (userName != null) {
            participantNames.add(userName);
          }
        }
      }
    }
    return participantNames;
  }

  void _notifyParticipantsChange(
      String courseId, List<dynamic> participantChange, bool isAdded) async {
    try {
      List<String> participantNames =
          await _getParticipantNames(participantChange);
      DocumentSnapshot courseSnapshot =
          await _firestore.collection('course').doc(courseId).get();
      if (courseSnapshot.exists) {
        Map<String, dynamic>? courseData =
            courseSnapshot.data() as Map<String, dynamic>?;

        if (courseData != null) {
          String creator = courseData['creator'];
          String courseName = courseData['course_Name'];

          _firestore.collection('notifications').add({
            'message':
                '${participantNames.join(', ')} ${isAdded ? 'joined' : 'quit'} your course $courseName',
            'participant_change': participantNames,
            'timestamp': FieldValue.serverTimestamp(),
            'sendto': creator,
            'isRead': false,
          });
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
