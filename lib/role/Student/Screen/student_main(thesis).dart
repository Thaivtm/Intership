import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Student/Profile/profile_st.dart';
import 'package:flutter_application_1/role/Student/Screen/Attempt_course/attempt_course.dart';
import 'package:flutter_application_1/role/Student/Screen/invite_acp.dart';

class CoursesScreen extends StatefulWidget {
  CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedTab = 'Public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        Page1: CoursesScreen(),
        Page2: InvitationsScreen(),
        title1: 'Home',
        icondata1: Icons.home,
        icondata2: Icons.add,
        title2: 'Invite',
        icondata3: Icons.account_box_rounded,
        title3: 'Profile',
        Page3: const ProfilePageSt(),
      ),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: CourseAttempt(),
    );
  }
}
