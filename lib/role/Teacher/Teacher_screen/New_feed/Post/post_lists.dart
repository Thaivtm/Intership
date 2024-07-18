import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Newfeed/edit_post_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/New_feed/AddPost/add_post.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/New_feed/Comment/comment.dart';
import 'package:intl/intl.dart';

class PostList extends StatefulWidget {
  final String courseId;

  const PostList({super.key, required this.courseId});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late User? _currentUser;
  late bool _isCourseCreator = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      var courseData = await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .get();
      if (courseData.exists && courseData['creator'] == _currentUser!.uid) {
        setState(() {
          _isCourseCreator = true;
        });
      }
    }
  }

  Future<String?> _getUserAvatar(String userId) async {
    var userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userData.exists ? userData['avatar'] as String? : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPostScreen(courseId: widget.courseId),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to navigate: $e')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icon(
                    Icons.add,
                    color: Colors.grey,
                  ),
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
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('course')
              .doc(widget.courseId)
              .collection('newfeed')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts available'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                final content = post['content'] ?? 'No content';
                final authorName = post['authorName'] ?? 'Unknown';
                final authorId = post['authorId'] ?? '';
                final timestamp = (post['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now();
                final isAuthor =
                    _currentUser != null && authorId == _currentUser!.uid;

                return FutureBuilder<String?>(
                  future: _getUserAvatar(authorId),
                  builder: (context, snapshot) {
                    final avatarUrl = snapshot.data;
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 10),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authorName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(timestamp),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (isAuthor || _isCourseCreator)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditPostScreen(
                                              courseId: widget.courseId,
                                              postId: post.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (isAuthor || _isCourseCreator)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _confirmDeletePost(post.id);
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                content,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(),
                              const SizedBox(height: 5),
                              _buildCommentsCount(post.id),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsCount(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .collection('newfeed')
          .doc(postId)
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('No comments'),
          );
        }

        int commentsCount = snapshot.data!.docs.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsPage(
                    courseId: widget.courseId,
                    postId: postId,
                  ),
                ),
              );
            },
            child: Text(
              '$commentsCount ${commentsCount == 1 ? "Comment" : "Comments"}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletePost(String postId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure about deleting this post?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(postId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .collection('newfeed')
          .doc(postId)
          .delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }
}
