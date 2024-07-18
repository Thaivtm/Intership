import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentsPage extends StatefulWidget {
  final String courseId;
  final String postId;

  const CommentsPage({super.key, required this.courseId, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  Future<String?> _getUserAvatar(String userId) async {
    var userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userData.exists ? userData['avatar'] as String? : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('course')
                  .doc(widget.courseId)
                  .collection('newfeed')
                  .doc(widget.postId)
                  .collection('comments')
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
                  return const Center(child: Text('No comments available'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data!.docs[index];
                    final content = comment['content'] ?? 'No content';
                    final authorName = comment['authorName'] ?? 'Unknown';
                    final authorId = comment['authorId'] ?? '';
                    final timestamp =
                        (comment['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();

                    return FutureBuilder<String?>(
                      future: _getUserAvatar(authorId),
                      builder: (context, snapshot) {
                        final avatarUrl = snapshot.data;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(timestamp),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              Text(content),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16, right: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (_commentController.text.isNotEmpty) {
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
                    .doc(widget.postId)
                    .collection('comments')
                    .add({
                  'content': _commentController.text,
                  'authorId': user.uid,
                  'authorName': username,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
