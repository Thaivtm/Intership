import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/screen/center/center_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool showProgress = false;
  String errorMessage = '';

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  String role = "Student";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo1.png',
                            width: 250,
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputInfo(
                          title: 'User Username',
                          controller: _userNameController,
                          hint: 'Enter Username',
                          iconData: Icons.account_box,
                          obscureText: false,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        InputInfo(
                          title: 'User Email',
                          controller: _emailController,
                          hint: 'Enter Email',
                          iconData: Icons.mail,
                          obscureText: false,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        InputInfo(
                          title: 'User Password',
                          controller: _passwordController,
                          hint: 'Enter Password',
                          iconData: Icons.lock,
                          obscureText: true,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        InputInfo(
                          title: 'Confirm User Password',
                          controller: _confirmpassController,
                          hint: 'Confirm Enter Password',
                          iconData: Icons.lock,
                          obscureText: true,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Role',
                            style: TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: role,
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 83, 83, 83)),
                              border: InputBorder.none,
                            ),
                            items: <String>['Student', 'Teacher', 'Admin']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      value == 'Student'
                                          ? Icons.school
                                          : value == 'Teacher'
                                              ? Icons.person
                                              : Icons.admin_panel_settings,
                                      color:
                                          const Color.fromARGB(255, 83, 83, 83),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                role = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 35),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 10),
                        Button(
                          title: 'Register',
                          onPressed: () {
                            setState(() {
                              showProgress = true;
                            });
                            signUp(
                                _emailController.text,
                                _passwordController.text,
                                _userNameController.text,
                                role);
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp(
      String email, String password, String username, String role) async {
    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Username is required';
      });
      return;
    }
    if (!RegExp(r'^.+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() {
        errorMessage = 'Invalid email format';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }
    if (password != _confirmpassController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }
    setState(() {
      errorMessage = '';
    });
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => {postDetailsToFirestore(email, role)})
        .catchError((e) {
      setState(() {
        errorMessage = e.message;
      });
    });
  }

  postDetailsToFirestore(String email, String role) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    String status = role == 'Admin' ? 'pending' : 'approved';

    await ref.doc(user!.uid).set({
      'email': _emailController.text,
      'role': role,
      'user_Name': _userNameController.text,
      'status': status,
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const CenterScreen()));
  }
}
