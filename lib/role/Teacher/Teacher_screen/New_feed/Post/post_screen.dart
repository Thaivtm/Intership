import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/New_feed/AddPost/add_post.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/New_feed/Post/post_lists.dart';

class PostScreen extends StatelessWidget {
  final String courseId;
  final Function(bool) reloadCallback;

  const PostScreen({
    super.key,
    required this.courseId,
    required this.reloadCallback,
  });

  Future<String> _getCourseCreatorId() async {
    DocumentSnapshot courseDoc = await FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .get();
    return courseDoc['creator'];
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not authenticated'));
    }
    String currentUserId = user.uid;

    return FutureBuilder(
      future: _getCourseCreatorId(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No course creator found')),
          );
        }

        String courseCreatorId = snapshot.data!;

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('course')
              .doc(courseId)
              .collection('newfeed')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPostScreen(
                            courseId: courseId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Say sth',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return PostList(
                    courseId: courseId,
                  );
                },
                childCount: 1,
              ),
            );
          },
        );
      },
    );
  }
}
