import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/avatar.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/components/profile_material.dart';
import 'package:flutter_application_1/role/Student/Profile/faq_st.dart';
import 'package:flutter_application_1/role/Student/Profile/notification_st.dart';
import 'package:flutter_application_1/role/Student/Profile/person_info_st.dart';
import 'package:flutter_application_1/role/Student/Profile/privacy_policy_st.dart';
import 'package:flutter_application_1/role/Student/Profile/term_condition_st.dart';
import 'package:flutter_application_1/role/Student/Screen/invite_acp.dart';
import 'package:flutter_application_1/role/Student/Screen/student_main(thesis).dart';
import 'package:flutter_application_1/screen/login/login_widget.dart';

class ProfilePageSt extends StatefulWidget {
  const ProfilePageSt({super.key});

  @override
  _ProfilePageStState createState() => _ProfilePageStState();
}

class _ProfilePageStState extends State<ProfilePageSt> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasUnreadNotifications = false;
  String _username = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _checkForUnreadNotifications(user.uid);
          _fetchUserData(user.uid);
        });
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        _username = userDoc['user_Name'];
        _avatarUrl = userDoc['avatar'];
      });
    }
  }

  Future<void> _checkForUnreadNotifications(String uid) async {
    bool hasUnread =
        await NotiTeacherSt.hasUnreadNotifications(_firestore, uid);
    setState(() {
      _hasUnreadNotifications = hasUnread;
    });
  }

  Future<void> _refreshProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _checkForUnreadNotifications(user.uid);
      await _fetchUserData(user.uid);
    }
  }

  void _viewAvatar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarView(avatarUrl: _avatarUrl ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        Page1: CoursesScreen(),
        Page2: const InvitationsScreen(),
        title1: 'Home',
        icondata1: Icons.home,
        icondata2: Icons.add,
        title2: 'Invitations',
        icondata3: Icons.account_box_rounded,
        title3: 'Profile',
        Page3: const ProfilePageSt(),
      ),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () =>
                        _avatarUrl != null ? _viewAvatar(context) : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundImage:
                              _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 150,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    _username,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
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
                          title: 'Personal Information', Page1: PersonInfoSt()),
                      const Divider(),
                      ProfileMaterial(
                        title: 'Notifications',
                        Page1: NotiTeacherSt(),
                        trailing: _hasUnreadNotifications
                            ? const Icon(
                                Icons.notifications_active,
                                color: Colors.red,
                              )
                            : null,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      const ProfileMaterial(
                          title: 'Privacy Policy', Page1: PrivacyPolicySt()),
                      const Divider(),
                      const ProfileMaterial(
                          title: 'Terms & Conditions',
                          Page1: TermConditionSt()),
                      const Divider(),
                      const ProfileMaterial(title: 'FAQ ', Page1: FAQSt()),
                      const Divider(),
                      const SizedBox(
                        height: 20,
                      ),
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
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
