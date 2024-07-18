import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Staff/Feature/pending_user.dart';
import 'package:flutter_application_1/role/Student/Screen/student_main(thesis).dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Course_detail/teacher_widget.dart';
import 'package:flutter_application_1/screen/center/center_cubit.dart';
import 'package:flutter_application_1/screen/center/center_status.dart';
import 'package:flutter_application_1/screen/login/login_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CenterScreen extends StatelessWidget {
  const CenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CenterCubit()..getRole(),
      child: BlocBuilder<CenterCubit, CenterState>(
        builder: (context, state) {
          if (state is CenterStateLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is CenterStatePendingApproval) {
            return _showPendingApprovalPopup(context);
          } else if (state is CenterStateLoaded) {
            return getScreen(state.role);
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Error occurred!'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _showPendingApprovalPopup(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your account is pending approval/ ban. Please contact 0918181480 for more infomation!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget getScreen(
    String role,
  ) {
    switch (role) {
      case 'Teacher':
        return TeacherWidget();
      case 'Student':
        return CoursesScreen();
      case 'Admin':
        return Staff();
      default:
        return Container();
    }
  }
}
