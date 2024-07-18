import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/database/User.dart';
import 'package:flutter_application_1/role/Staff/Feature/control_user.dart';
import 'package:flutter_application_1/role/Staff/Profile/profile_staff.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  List<User> pendingUsers = [];
  List<User> filteredUsers = [];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getPendingUsers();
  }

  _getPendingUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .where('role', isEqualTo: 'Admin')
          .get();
      pendingUsers =
          snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
      filteredUsers = pendingUsers;
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      filteredUsers = pendingUsers
          .where(
              (user) => user.email.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        Page1: Staff(),
        Page2: ControlUser(),
        title1: 'Pending Admins',
        icondata1: Icons.pending,
        icondata2: Icons.manage_accounts,
        title2: 'Control Users',
        icondata3: Icons.account_box_rounded,
        title3: 'Profile',
        Page3: const ProfilePageStaff(),
      ),
      appBar: AppBar(
        title: const Text('Pending Admins'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Email',
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                    const EdgeInsets.only(left: 15.0, top: 11.0, bottom: 11.0),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 83, 83, 83)),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 201, 174, 93),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return ListTile(
            title: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .update({'status': 'approved'});
                    _getPendingUsers();
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (await _confirmRejection(user.email)) {
                      await _firestore
                          .collection('users')
                          .doc(user.uid)
                          .delete();
                      _getPendingUsers();
                    }
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmRejection(String email) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reject User'),
            content: Text('Are you sure you want to reject this user: $email?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
