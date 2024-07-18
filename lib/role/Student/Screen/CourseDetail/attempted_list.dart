import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/participant_invite.dart';

class AttemptList extends StatefulWidget {
  final String creatorId;
  final List<String> participantIds;
  final String courseId;

  AttemptList({
    super.key,
    required this.creatorId,
    required this.participantIds,
    required this.courseId,
  });

  @override
  _AttemptListState createState() => _AttemptListState();
}

class _AttemptListState extends State<AttemptList> {
  Future<Map<String, dynamic>> _fetchUser(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> _fetchParticipants(
      List<String> userIds) async {
    List<Map<String, dynamic>> users = [];
    for (String id in userIds) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userDoc.exists) {
        users.add(userDoc.data() as Map<String, dynamic>);
      }
    }
    return users;
  }

  Future<Map<String, dynamic>> _fetchCourse() async {
    DocumentSnapshot courseDoc = await FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .get();
    if (courseDoc.exists) {
      return courseDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return InviteDialog(courseId: widget.courseId);
      },
    );
  }

  Future<void> _deleteParticipant(String participantId) async {
    await FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .update({
      'participants': FieldValue.arrayRemove([participantId])
    });

    setState(() {
      widget.participantIds.remove(participantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _fetchCourse(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Course not found');
            }

            final course = snapshot.data!;
            return Text(course['course_Name']);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUser(widget.creatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Teacher not found'));
          }

          final teacher = snapshot.data!;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchParticipants(widget.participantIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final participants = snapshot.hasData ? snapshot.data! : [];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teacher',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      title: Text(teacher['user_Name'] ?? 'Unknown'),
                      subtitle: Text(teacher['email'] ?? 'No email'),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text(
                          'Students',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_outlined),
                          onPressed: _showInviteDialog,
                        ),
                      ],
                    ),
                    Expanded(
                      child: participants.isNotEmpty
                          ? ListView.builder(
                              itemCount: participants.length,
                              itemBuilder: (context, index) {
                                final student = participants[index];
                                return ListTile(
                                  title:
                                      Text(student['user_Name'] ?? 'Unknown'),
                                  subtitle:
                                      Text(student['email'] ?? 'No email'),
                                  trailing: currentUser?.uid == widget.creatorId
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteParticipant(
                                              widget.participantIds[index]),
                                        )
                                      : null,
                                );
                              },
                            )
                          : const Center(
                              child: Text('No participants found'),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
