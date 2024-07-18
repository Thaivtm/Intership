import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/forgottenpassword/forgotten_password_widget.dart';
import 'package:flutter_application_1/screen/register/register_screen.dart';

Future<User?> loginUsingEmailPassword({
  required String email,
  required String password,
}) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    String message;
    switch (e.code) {
      case "user-not-found":
        message = "The email address is not registered.";
        break;
      case "wrong-password":
        message = "The password is invalid.";
        break;
      case "invalid-email":
        message = "The email address is invalid.";
        break;
      case "user-disabled":
        message = "The user account is disabled.";
        break;
      default:
        message = "An error occurred. Please try again.";
    }
    return Future.error(message);
  } catch (e) {
    return Future.error("An unexpected error occurred.");
  }
}

void handleForgotPassword(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ForgottenPassword()),
  );
}

void handleCreateAccount(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Register()),
  );
}

Future<DataResponse> loginLogic(String email, String password) async {
  try {
    User? user = await loginUsingEmailPassword(email: email, password: password);
    return DataResponse.success(user);
  } catch (e) {
    return DataResponse.failure(e.toString());
  }
}

class DataResponse {
  final bool isSuccess;
  final dynamic data;
  final String message;

  DataResponse._({required this.isSuccess, this.data, required this.message});

  factory DataResponse.success(dynamic data) {
    return DataResponse._(isSuccess: true, data: data, message: "");
  }

  factory DataResponse.failure(String message) {
    return DataResponse._(isSuccess: false, data: null, message: message);
  }
}
