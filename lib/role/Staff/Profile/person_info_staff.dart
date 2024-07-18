import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/avatar.dart';
import 'package:flutter_application_1/role/Teacher/Profie/edit_profile.dart';

class PersonInfoStaff extends StatefulWidget {
  const PersonInfoStaff({super.key});

  @override
  State<PersonInfoStaff> createState() => _PersonInfoStaffState();
}

class _PersonInfoStaffState extends State<PersonInfoStaff> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _username = '';
  String _email = '';
  String? _dob;
  String? _phoneNumber;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['user_Name'] ?? 'N/A';
          _email = userDoc['email'] ?? 'N/A';
          _dob = userDoc['dob'];
          _phoneNumber = userDoc['phone_number'];
          _avatarUrl = userDoc['avatar'];
        });
      }
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

  Future<void> _refreshUserData() async {
    await _fetchUserInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 50),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _avatarUrl != null ? _viewAvatar(context) : null,
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
                    Positioned(
                      bottom: 10,
                      right: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfile(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                _username,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Profile',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    _email,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'DOB',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    _dob ?? 'Not available',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    _phoneNumber ?? 'Not available',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
