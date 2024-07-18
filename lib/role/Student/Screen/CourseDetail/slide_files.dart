import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Student/Screen/CourseDetail/pdf_viewer.dart';

class SlideFiles extends StatelessWidget {
  final String courseId;

  SlideFiles({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('course')
          .doc(courseId)
          .collection('files')
          .where('file_type', isEqualTo: 'application/pdf')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text('No slide files attached');
        }

        final slideFiles = snapshot.data!.docs;
        if (slideFiles.isEmpty) {
          return const Text('No slide files attached');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slideFiles.length,
          itemBuilder: (context, index) {
            final data = slideFiles[index].data() as Map<String, dynamic>;
            final fileName = data['file_name'] ?? '';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyPdfViewer(fileUrl: data['file_url']),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
