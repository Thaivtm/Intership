import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/course_detail.dart';

class PublicCoursesList extends StatelessWidget {
  PublicCoursesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('course')
          .where('visibility', isEqualTo: 'Public')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No courses available'));
        }

        final courses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
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
                    builder: (context) =>
                        CourseDetailStudent(courseId: course.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
