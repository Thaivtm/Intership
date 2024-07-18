import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FieldsHandler {
  final FirebaseFirestore _firestore;
  Map<String, Map<String, String>> _previousFiles = {};
  final Map<String, StreamSubscription> _fieldSubscriptions = {};

  FieldsHandler(this._firestore) {
    _loadPreviousFiles();
  }

  Future<void> _loadPreviousFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedFiles = prefs.getString('previousFiles');
    if (storedFiles != null) {
      Map<String, dynamic> decodedMap = jsonDecode(storedFiles);
      _previousFiles = decodedMap.map((key, value) => MapEntry(
            key,
            Map<String, String>.from(value),
          ));
    }
  }

  Future<void> _savePreviousFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedMap = jsonEncode(_previousFiles);
    await prefs.setString('previousFiles', encodedMap);
  }

  StreamSubscription fieldsListener() {
    return _firestore.collection('course').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          String courseId = change.doc.id;
          _listenToFieldsChanges(courseId);
        }
      }
    });
  }

  void _listenToFieldsChanges(String courseId) {
    _fieldSubscriptions[courseId]?.cancel();

    _fieldSubscriptions[courseId] = _firestore
        .collection('course')
        .doc(courseId)
        .collection('files')
        .snapshots()
        .listen((snapshot) {
      Map<String, String> newFiles = {
        for (var doc in snapshot.docs)
          doc.id: doc.data()?['file_name'] ?? doc.id
      };
      Map<String, String> oldFiles = _previousFiles[courseId] ?? {};

      List<String> addedFiles = newFiles.keys
          .where((fileId) => !oldFiles.containsKey(fileId))
          .toList();
      List<String> removedFiles = oldFiles.keys
          .where((fileId) => !newFiles.containsKey(fileId))
          .toList();

      if (addedFiles.isNotEmpty) {
        print('Added files: $addedFiles');
        _notifyFieldsChange(courseId, addedFiles, true, newFiles);
      }

      if (removedFiles.isNotEmpty) {
        print('Removed files: $removedFiles');
        _notifyFieldsChange(courseId, removedFiles, false, oldFiles);
      }

      _previousFiles[courseId] = newFiles;
      _savePreviousFiles(); // Save to persistent storage
    }, onError: (error) {
      print('Error listening to field changes for course $courseId: $error');
    });
  }

  void _notifyFieldsChange(String courseId, List<String> fileChangeIds,
      bool isAdded, Map<String, String> filesMap) async {
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

          List<String> fileNames = [];
          for (var fileId in fileChangeIds) {
            fileNames.add(filesMap[fileId] ?? fileId);
          }

          List<String> recipients = [creator, ...participants];

          for (var recipient in recipients) {
            _firestore.collection('notifications').add({
              'message':
                  '${fileNames.join(', ')} has been ${isAdded ? 'added to' : 'deleted from'} course $courseName',
              'file_change': fileNames,
              'timestamp': FieldValue.serverTimestamp(),
              'sendto': recipient,
              'file_name': fileNames.join(', '),
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
