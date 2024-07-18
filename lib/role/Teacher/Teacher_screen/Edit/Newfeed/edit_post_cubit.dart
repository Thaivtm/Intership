import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Newfeed/edit_post_state.dart';

class EditPostCubit extends Cubit<EditPostState> {
  final String courseId;
  final String postId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EditPostCubit({required this.courseId, required this.postId})
      : super(EditPostInitial());

  Future<void> fetchPostContent() async {
    try {
      emit(EditPostLoading());
      final postSnapshot = await _firestore
          .collection('course')
          .doc(courseId)
          .collection('newfeed')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        String content = postSnapshot['content'];
        emit(EditPostLoaded(content: content));
      } else {
        emit(EditPostError(message: 'Post not found'));
      }
    } catch (e) {
      emit(EditPostError(message: e.toString()));
    }
  }

  Future<void> updatePost(String newContent) async {
    try {
      emit(EditPostLoading());
      await _firestore
          .collection('course')
          .doc(courseId)
          .collection('newfeed')
          .doc(postId)
          .update({'content': newContent});
      emit(EditPostUpdated());
    } catch (e) {
      emit(EditPostError(message: e.toString()));
    }
  }
}
