import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  File? _image;
  String? _imageUrl;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc['user_Name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _dobController.text = userDoc['dob'] ?? '';
          _phoneNumberController.text = userDoc['phone_number'] ?? '';
          _imageUrl = userDoc['avatar'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(User user) async {
    if (_image != null) {
      String fileName = 'avatars/${user.uid}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      _imageUrl = await snapshot.ref.getDownloadURL();
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _uploadImage(user);

      await _firestore.collection('users').doc(user.uid).update({
        'user_Name': _usernameController.text,
        'dob': _dobController.text.isNotEmpty ? _dobController.text : null,
        'phone_number': _phoneNumberController.text.isNotEmpty
            ? _phoneNumberController.text
            : null,
        'avatar': _imageUrl,
      });

      await _loadUserData();

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                          ? NetworkImage(_imageUrl!) as ImageProvider
                          : null),
                  child: _image == null &&
                          (_imageUrl == null || _imageUrl!.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 100,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              InputInfo(
                title: 'Username',
                controller: _usernameController,
                hint: 'Enter your username',
                iconData: Icons.person,
                obscureText: false,
              ),
              AbsorbPointer(
                absorbing: true,
                child: InputInfo(
                  title: 'Email',
                  controller: _emailController,
                  hint: 'Enter your email',
                  iconData: Icons.email,
                  obscureText: false,
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: InputInfo(
                    title: 'Date of Birth',
                    controller: _dobController,
                    hint: 'Select your date of birth',
                    iconData: Icons.calendar_today,
                    obscureText: false,
                  ),
                ),
              ),
              InputInfo(
                title: 'Phone Number',
                controller: _phoneNumberController,
                hint: 'Enter your phone number',
                iconData: Icons.phone,
                obscureText: false,
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              Button(title: 'Update', onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}
