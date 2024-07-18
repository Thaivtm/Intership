import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Teacher/Mainscreen/course_details.dart';
import 'package:flutter_application_1/role/Teacher/Profie/profile_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Add_course/add_course_widget.dart';

class TeacherWidget extends StatelessWidget {
  const TeacherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeacherView();
  }
}

class TeacherView extends StatefulWidget {
  const TeacherView({super.key});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _courses = [];
  bool _loading = true;
  String _errorMessage = '';

  late final String _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _updateCourseStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  void _updateCourseStream() {
    FirebaseFirestore.instance
        .collection('course')
        .where('creator', isEqualTo: _userId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _courses = snapshot.docs;
        _loading = false;
      });
    }, onError: (error) {
      setState(() {
        _errorMessage = error.toString();
        _loading = false;
      });
    });
  }

  void _searchCourses(String query) {
    FirebaseFirestore.instance
        .collection('course')
        .where('creator', isEqualTo: _userId)
        .where('course_Name', isGreaterThanOrEqualTo: query)
        .where('course_Name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _courses = snapshot.docs;
      });
    }, onError: (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    });
  }

  void _deleteCourse(String courseId) {
    FirebaseFirestore.instance
        .collection('course')
        .doc(courseId)
        .delete()
        .then((_) {
      _updateCourseStream();
    }).catchError((error) {
      setState(() {
        _errorMessage = error.toString();
      });
    });
  }

  void _showDeleteConfirmationDialog(String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCourse(courseId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        title1: 'Home',
        icondata1: Icons.home,
        Page1: TeacherWidget(),
        title2: 'Add Course',
        icondata2: Icons.upload,
        Page2: AddCourse(),
        title3: 'Profile',
        icondata3: Icons.account_box_rounded,
        Page3: ProfilePage(),
      ),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchCourses(value);
              },
              decoration: InputDecoration(
                hintText: 'Search courses',
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 83, 83, 83)),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 201, 174, 93),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _courses.isEmpty
                        ? const Center(child: Text('No courses found'))
                        : _buildCourseList(),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCourse()),
                );
              },
              child: const Icon(Icons.add, size: 30, color: Colors.black),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        final bannerUrl = course['banner_url'] ?? '';
        return ListTile(
          subtitle: Stack(
            children: [
              if (bannerUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    bannerUrl,
                    height: 135,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    course['course_Name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailTeacher(courseId: course.id),
              ),
            );
          },
          onLongPress: () {
            _showDeleteConfirmationDialog(course.id);
          },
        );
      },
    );
  }
}
