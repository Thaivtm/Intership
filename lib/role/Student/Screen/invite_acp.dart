import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Student/Profile/profile_st.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/course_detail.dart';
import 'package:flutter_application_1/role/Student/Screen/student_main(thesis).dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _respondToInvitation(String invitationId, bool accept) async {
    try {
      final invitationRef = FirebaseFirestore.instance
          .collection('invitations')
          .doc(invitationId);
      final invitation = await invitationRef.get();

      if (!invitation.exists) throw 'Invitation not found';

      final courseId = invitation['courseId'];
      final currentUser = FirebaseAuth.instance.currentUser;

      if (accept) {
        await FirebaseFirestore.instance
            .collection('course')
            .doc(courseId)
            .update({
          'participants': FieldValue.arrayUnion([currentUser?.uid]),
        });

        await invitationRef.update({
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailStudent(courseId: courseId),
          ),
        );
      } else {
        await invitationRef.update({
          'status': 'rejected',
          'respondedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error responding to invitation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        Page1: CoursesScreen(),
        Page2: InvitationsScreen(),
        title1: 'Home',
        icondata1: Icons.home,
        icondata2: Icons.add,
        title2: 'Invitations',
        icondata3: Icons.account_box_rounded,
        title3: 'Profile',
        Page3: ProfilePageSt(),
      ),
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invitations')
            .where('email', isEqualTo: currentUser?.email)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No invitations'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text.rich(
                  TextSpan(
                    text: 'Invitation to join course ',
                    children: [
                      TextSpan(
                        text: doc['courseName'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                subtitle: Text('From: ${doc['senderName']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _respondToInvitation(doc.id, true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _respondToInvitation(doc.id, false),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
