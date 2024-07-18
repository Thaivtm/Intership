import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String role;
  final String status;

  User(
      {required this.uid,
      required this.email,
      required this.role,
      required this.status});

  factory User.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      uid: snapshot.id,
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
