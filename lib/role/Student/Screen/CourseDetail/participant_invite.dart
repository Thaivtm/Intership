import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';

class InviteDialog extends StatefulWidget {
  final String courseId;

  InviteDialog({super.key, required this.courseId});

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final TextEditingController emailController = TextEditingController();
  String? errorMessage;

  Future<void> _sendInvitation(String email) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw 'User not logged in';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final CourseDoc = await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .get();

      if (!userDoc.exists) throw 'User data not found';

      final userName = userDoc['user_Name'];
      final courseName = CourseDoc['course_Name'];

      await FirebaseFirestore.instance.collection('invitations').add({
        'courseId': widget.courseId,
        'courseName': courseName,
        'email': email,
        'senderId': currentUser.uid,
        'senderName': userName,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Invite by Email'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputInfo(
            title: 'Enter the email address of the person you want to invite:',
            controller: emailController,
            hint: 'Enter Email',
            obscureText: false,
            iconData: Icons.mail,
            maxLines: 1,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 5),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        Button(
          title: 'Invite',
          onPressed: () async {
            if (emailController.text.isNotEmpty) {
              await _sendInvitation(emailController.text);
            }
          },
        ),
      ],
    );
  }
}
