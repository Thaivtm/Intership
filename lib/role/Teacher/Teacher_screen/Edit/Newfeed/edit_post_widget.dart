import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Newfeed/edit_post_cubit.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Edit/Newfeed/edit_post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPostScreen extends StatelessWidget {
  final String courseId;
  final String postId;

  const EditPostScreen(
      {super.key, required this.courseId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          EditPostCubit(courseId: courseId, postId: postId)..fetchPostContent(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Post'),
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<EditPostCubit, EditPostState>(
          listener: (context, state) {
            if (state is EditPostUpdated) {
              Navigator.pop(context);
            } else if (state is EditPostError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is EditPostLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EditPostLoaded) {
              final _contentController =
                  TextEditingController(text: state.content);
              return Padding(
                padding: const EdgeInsets.all(16.0),
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
                    InputInfo(
                      title: 'New Content',
                      controller: _contentController,
                      hint: 'Enter New Content',
                      obscureText: false,
                      iconData: Icons.subject,
                      maxLines: null,
                    ),
                    const SizedBox(height: 20),
                    Button(
                      title: 'Save',
                      onPressed: () {
                        context
                            .read<EditPostCubit>()
                            .updatePost(_contentController.text);
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Something went wrong!'));
            }
          },
        ),
      ),
    );
  }
}
