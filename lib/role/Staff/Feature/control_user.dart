import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/role/Staff/Feature/pending_user.dart';
import 'package:flutter_application_1/role/Staff/Profile/profile_staff.dart';

class ControlUser extends StatefulWidget {
  ControlUser({super.key});

  @override
  State<ControlUser> createState() => _ControlUserState();
}

class _ControlUserState extends State<ControlUser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  _fetchUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['Teacher', 'Student']).get();
      allUsers = snapshot.docs;
      filteredUsers = allUsers;
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      filteredUsers = allUsers.where((user) {
        var data = user.data() as Map<String, dynamic>;
        return data['email'] != null &&
            data['email'].toString().toLowerCase().contains(text.toLowerCase());
      }).toList();
    });
  }

  void _toggleStatus(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    bool isApproved = data['status'] == 'approved';
    String newStatus = isApproved ? 'pending' : 'approved';

    _firestore
        .collection('users')
        .doc(doc.id)
        .update({'status': newStatus}).then((_) {
      // Gọi lại _fetchUsers để cập nhật danh sách người dùng
      _fetchUsers();
    }).catchError((error) {
      print("Failed to update status: $error");
    });
  }

  void _showConfirmationDialog(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    bool isApproved = data['status'] == 'approved';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change User Status'),
          content: Text(
            'Do you want to change the status to ${isApproved ? 'Inactive' : 'Active'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _toggleStatus(doc);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        Page1: Staff(),
        Page2: ControlUser(),
        title1: 'Pending Users',
        icondata1: Icons.pending,
        icondata2: Icons.manage_accounts,
        title2: 'Control Users',
        icondata3: Icons.account_box_rounded,
        title3: 'Profile',
        Page3: const ProfilePageStaff(),
      ),
      appBar: AppBar(
        title: const Text('Control Users'),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 0.5),
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
          final doc = filteredUsers[index];
          var data = doc.data() as Map<String, dynamic>;
          return ListTile(
            title: Text(data['user_Name'] ?? 'No name'),
            subtitle: Text(data['email'] ?? 'No email'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data['role'] ?? 'No role'),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showConfirmationDialog(doc),
                  child: Text(
                    data['status'] == 'approved' ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 15,
                      color: data['status'] == 'approved'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
