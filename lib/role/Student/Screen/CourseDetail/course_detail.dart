import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/attempted_list.dart';
import 'package:flutter_application_1/role/Student/Screen/material_st.dart';
import 'package:flutter_application_1/role/Student/Screen/student_main(thesis).dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/New_feed/Post/post_screen.dart';

class CourseDetailStudent extends StatefulWidget {
  final String courseId;

  CourseDetailStudent({super.key, required this.courseId});

  @override
  _CourseDetailStudentState createState() => _CourseDetailStudentState();
}

class _CourseDetailStudentState extends State<CourseDetailStudent> {
  late Future<DocumentSnapshot> _futureCourseData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureCourseData = _fetchCourseData();
  }

  Future<DocumentSnapshot> _fetchCourseData() {
    return FirebaseFirestore.instance
        .collection('course')
        .doc(widget.courseId)
        .get();
  }

  Future<void> _reloadData() async {
    setState(() {
      _futureCourseData = _fetchCourseData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showCourseCodePopup(String courseCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Text(
                courseCode,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: _futureCourseData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading course data')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Course not found')),
          );
        }

        final course = snapshot.data!.data() as Map<String, dynamic>;
        final bannerUrl = course['banner_url'] ?? '';
        final participants = course['participants'] as List<dynamic>? ?? [];
        final totalPeople = participants.length + 1;
        final String creatorId = course['creator'];
        final List<String> participantIds = participants.cast<String>();
        final String courseCode = course['Course_code'] ?? 'No code available';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoursesScreen(),
                      ),
                    );
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 17,
                        bottom: 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['course_Name'],
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttemptList(
                                      creatorId: creatorId,
                                      courseId: widget.courseId,
                                      participantIds: participantIds,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Total of People: $totalPeople',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 35,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _showCourseCodePopup(courseCode);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBodyContent(user),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.comment),
                label: 'New Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storage),
                label: 'Material',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(User user) {
    switch (_selectedIndex) {
      case 0:
        return PostScreen(
          courseId: widget.courseId,
          reloadCallback: (bool reload) async {
            await _reloadData();
          },
        );

      case 1:
        return CourseDetailStList(
          user: user,
          courseId: widget.courseId,
          reloadCallback: (bool reload) async {
            await _reloadData();
          },
        );

      default:
        return PostScreen(
          courseId: widget.courseId,
          reloadCallback: (bool reload) async {
            await _reloadData();
          },
        );
    }
  }
}
