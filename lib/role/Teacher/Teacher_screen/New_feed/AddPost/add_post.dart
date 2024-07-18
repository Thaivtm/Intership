import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';

class AddPostScreen extends StatefulWidget {
  final String courseId;
  const AddPostScreen({super.key, required this.courseId});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 250,
                ),
              ),
              const Text(
                'Content',
                style: TextStyle(
                  color: Color.fromARGB(255, 83, 83, 83),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter content',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  prefixIcon:
                      const Icon(Icons.description, color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 201, 174, 93),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  _content = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
                maxLines: null,
              ),
              const SizedBox(height: 40),
              Button(
                title: 'Add Post',
                onPressed: _addPost,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var user = FirebaseAuth.instance.currentUser!;
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var username = userData['user_Name'];

      await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .collection('newfeed')
          .add({
        'content': _content,
        'authorId': user.uid,
        'authorName': username,
        'timestamp': FieldValue.serverTimestamp(),
        'course': widget.courseId,
      });
      Navigator.pop(context);
    }
  }
}
