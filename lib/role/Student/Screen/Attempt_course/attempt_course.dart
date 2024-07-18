import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/course_detail.dart';

class CourseAttempt extends StatefulWidget {
  CourseAttempt({super.key});

  @override
  _CourseAttemptState createState() => _CourseAttemptState();
}

class _CourseAttemptState extends State<CourseAttempt> {
  late final TextEditingController _courseCodeController;
  late TextEditingController _searchController;
  String? _error;
  List<DocumentSnapshot> _courses = [];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _courseCodeController = TextEditingController();
    _searchController = TextEditingController();
    _updateCourseStream();
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateCourseStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('course')
          .where('participants', arrayContains: user.uid)
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
  }

  void _searchCourses(String query) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('course')
          .where('participants', arrayContains: user.uid)
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _showAttemptCourseDialog();
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

        return GestureDetector(
          onTap: () {
            navigateToCourseDetails(course);
          },
          onLongPress: () {
            _showRemoveCourseConfirmation(course);
          },
          child: ListTile(
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
          ),
        );
      },
    );
  }

  void _showRemoveCourseConfirmation(DocumentSnapshot course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Course'),
          content: const Text('Are you sure you want to leave this course?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                _removeFromCourse(course);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeFromCourse(DocumentSnapshot courseDoc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final courseId = courseDoc.id;

      await FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .update({
        'participants': FieldValue.arrayRemove([user.uid]),
      });
    }
  }

  void navigateToCourseDetails(DocumentSnapshot courseDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailStudent(
          courseId: courseDoc.id,
        ),
      ),
    ).then((_) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  void _showAttemptCourseDialog() {
    String? localError;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo1.png',
                      width: 250,
                    ),
                    const Text(
                      "Attempt Course",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    InputInfo(
                      controller: _courseCodeController,
                      title: 'Course Code',
                      hint: 'Enter Course Code',
                      obscureText: false,
                      iconData: Icons.find_in_page_outlined,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    if (localError != null)
                      Text(
                        localError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 5),
                    Button(
                      title: 'Attempt',
                      onPressed: () {
                        _attemptCourse().then((success) {
                          if (success) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              localError = _error;
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _attemptCourse() async {
    final courseCode = _courseCodeController.text.trim();

    if (courseCode.isEmpty) {
      setState(() {
        _error = 'Course code cannot be empty';
      });
      return false;
    }

    final courseQuery = await FirebaseFirestore.instance
        .collection('course')
        .where('Course_code', isEqualTo: courseCode)
        .get();

    if (courseQuery.docs.isEmpty) {
      setState(() {
        _error = 'Course not found';
      });
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final courseDoc = courseQuery.docs.first;
      final courseId = courseDoc.id;

      await FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .update({
        'participants': FieldValue.arrayUnion([user.uid]),
      });

      _courseCodeController.clear();
      setState(() {
        _error = null;
      });
      return true;
    }

    return false;
  }
}
