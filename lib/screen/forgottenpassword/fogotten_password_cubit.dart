import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screen/forgottenpassword/forgotten_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgottenPasswordCubit extends Cubit<ForgottenPasswordState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ForgottenPasswordCubit() : super(ForgottenPasswordInitial());

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      emit(ForgottenPasswordSuccess());
      return true;
    } catch (e) {
      emit(ForgottenPasswordError(e.toString()));
      return false;
    }
  }
}
