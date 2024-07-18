import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/material_noti.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/newfeed_noti.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/participants_noti.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/quizz_noti.dart';
import 'package:intl/intl.dart';

class NotiTeacherStaff extends StatefulWidget {
  NotiTeacherStaff({super.key});

  @override
  _NotiTeacherStaffState createState() => _NotiTeacherStaffState();

  static Future<bool> hasUnreadNotifications(
      FirebaseFirestore firestore, String uid) async {
    final querySnapshot = await firestore
        .collection('notifications')
        .where('sendto', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}

class _NotiTeacherStaffState extends State<NotiTeacherStaff> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription _subscription1;
  late StreamSubscription _subscription2;
  late StreamSubscription _subscription3;
  late StreamSubscription _subscription4;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _subscription1 = ParticipantsHandler(_firestore).participantsListener();
    _subscription2 = FieldsHandler(_firestore).fieldsListener();
    _subscription3 = QuizzHandler(_firestore).quizListener();
    _subscription4 = NewFeedHandler(_firestore).newFeedListener();
  }

  Future<void> _getCurrentUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription1.cancel();
    _subscription2.cancel();
    _subscription3.cancel();
    _subscription4.cancel();
    super.dispose();
  }

  Future<void> _markAsRead(DocumentSnapshot notification) async {
    await notification.reference.update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final bool hasUnread = await NotiTeacherStaff.hasUnreadNotifications(
            _firestore, _currentUser!.uid);
        Navigator.pop(context, hasUnread);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification'),
        ),
        body: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notifications')
                    .where('sendto', isEqualTo: _currentUser!.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No notifications yet.'));
                  }
                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      final timestamp =
                          (notification['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                      final isRead = notification['isRead'] as bool? ?? false;
                      return Card(
                        margin:
                            const EdgeInsets.only(left: 16, right: 16, top: 10),
                        child: Stack(
                          children: [
                            ListTile(
                              title: Text(notification['message']),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(timestamp),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              onTap: () {
                                _markAsRead(notification);
                              },
                            ),
                            if (!isRead)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
