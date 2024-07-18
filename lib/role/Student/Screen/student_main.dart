import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Student/Profile/profile_st.dart';
import 'package:flutter_application_1/role/Student/Screen/Attempt_course/attempt_course.dart';
import 'package:flutter_application_1/role/Student/Screen/invite_acp.dart';
import 'package:flutter_application_1/role/Student/Screen/public_course_list.dart';
import 'package:flutter_application_1/role/Student/Screen/student_main(thesis).dart';

class CoursesScreen1 extends StatefulWidget {
  CoursesScreen1({super.key});

  @override
  _CoursesScreen1State createState() => _CoursesScreen1State();
}

class _CoursesScreen1State extends State<CoursesScreen1> {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTab = 'Public';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: _selectedTab == 'Public'
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: 115,
                    child: Center(
                      child: Text(
                        'Public',
                        style: TextStyle(
                          color: _selectedTab == 'Public'
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTab = 'My Course';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: _selectedTab == 'My Course'
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'My Course',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 'Public'
                ? PublicCoursesList()
                : CourseAttempt(),
          ),
        ],
      ),
    );
  }
}
