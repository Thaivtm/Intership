import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/avatar.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/components/profile_material.dart';
import 'package:flutter_application_1/role/Teacher/Profie/faq.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/notification.dart';
import 'package:flutter_application_1/role/Teacher/Profie/person_info.dart';
import 'package:flutter_application_1/role/Teacher/Profie/privacy_policy.dart';
import 'package:flutter_application_1/role/Teacher/Profie/profile_cubit.dart';
import 'package:flutter_application_1/role/Teacher/Profie/profile_state.dart';
import 'package:flutter_application_1/role/Teacher/Profie/terms.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Add_course/add_course_widget.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Course_detail/teacher_widget.dart';
import 'package:flutter_application_1/screen/login/login_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _viewAvatar(BuildContext context, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvatarView(avatarUrl: avatarUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..getCurrentUser(),
      child: Scaffold(
        drawer: const NavBar(
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
          title: const Text('Profile'),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileCubit>().refreshProfile();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: ListView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _viewAvatar(context, state.avatarUrl),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 75,
                                  backgroundImage: state.avatarUrl != null &&
                                          state.avatarUrl!.isNotEmpty
                                      ? NetworkImage(state.avatarUrl!)
                                      : null,
                                  child: state.avatarUrl == null ||
                                          state.avatarUrl!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 150,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            state.username,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Setting',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              const ProfileMaterial(
                                  title: 'Personal Information',
                                  Page1: PersonInfo()),
                              const Divider(),
                              ProfileMaterial(
                                title: 'Notifications',
                                Page1: NotiTeacher(),
                                trailing: state.hasUnreadNotifications
                                    ? const Icon(
                                        Icons.notifications_active,
                                        color: Colors.red,
                                      )
                                    : null,
                              ),
                              const Divider(),
                              const SizedBox(height: 10),
                              const Text(
                                'Help & Support',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                              const ProfileMaterial(
                                  title: 'Privacy Policy',
                                  Page1: PrivacyPolicy()),
                              const Divider(),
                              const ProfileMaterial(
                                  title: 'Terms & Conditions',
                                  Page1: TermCondition()),
                              const Divider(),
                              const ProfileMaterial(
                                  title: 'FAQ ', Page1: FAQ()),
                              const Divider(),
                              const SizedBox(height: 20),
                              TextButton(
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 196, 33, 22),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('Something went wrong!'));
            }
          },
        ),
      ),
    );
  }
}
