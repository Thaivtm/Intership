import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/screen/forgottenpassword/fogotten_password_cubit.dart';
import 'package:flutter_application_1/screen/forgottenpassword/forgotten_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgottenPassword extends StatelessWidget {
  const ForgottenPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgottenPasswordCubit(),
      child: const ForgottenPasswordForm(),
    );
  }
}

class ForgottenPasswordForm extends StatefulWidget {
  const ForgottenPasswordForm({super.key});

  @override
  _ForgottenPasswordFormState createState() => _ForgottenPasswordFormState();
}

class _ForgottenPasswordFormState extends State<ForgottenPasswordForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword(BuildContext context) {
    final cubit = context.read<ForgottenPasswordCubit>();
    cubit.resetPassword(_emailController.text).then((success) {
      if (success) {
        _showResetPasswordConfirmation();
      }
    });
  }

  void _showResetPasswordConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text(
              "An email has been sent to your email address with instructions to reset your password."),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo1.png',
                width: 250,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Enter your email to recover the password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 83, 83, 83),
                ),
              ),
            ),
            const SizedBox(height: 30),
            InputInfo(
              title: 'User Email',
              controller: _emailController,
              hint: 'Enter Email',
              iconData: Icons.mail,
              obscureText: false,
              maxLines: 1,
            ),
            const SizedBox(height: 45),
            BlocBuilder<ForgottenPasswordCubit, ForgottenPasswordState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is ForgottenPasswordError)
                      Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 5),
                    Button(
                      title: 'Reset Password',
                      onPressed: () => _resetPassword(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
