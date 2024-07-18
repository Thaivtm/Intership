import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/input_info.dart';
import 'package:flutter_application_1/screen/center/center_widget.dart';
import 'package:flutter_application_1/screen/login/login_logic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = "";

  Future<void> _login() async {
    final data =
        await loginLogic(_emailController.text, _passwordController.text);
    if (data.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CenterScreen()),
      );
    } else {
      setState(() {
        _errorMessage = data.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 250,
                ),
              ),
              SizedBox(height: 20),
              InputInfo(
                title: 'User Email',
                controller: _emailController,
                hint: 'Enter Email',
                iconData: Icons.mail,
                obscureText: false,
                maxLines: 1,
              ),
              SizedBox(height: 25),
              InputInfo(
                title: 'User Password',
                controller: _passwordController,
                hint: 'Enter Password',
                iconData: Icons.lock,
                obscureText: true,
                maxLines: 1,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      handleForgotPassword(context);
                    },
                    child: const Text(
                      "Forgotten Password?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromARGB(255, 5, 108, 218),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Visibility(
                visible: _errorMessage.isNotEmpty,
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(height: 10),
              Button(title: 'Login', onPressed: _login),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      handleCreateAccount(context);
                    },
                    child: const Text(
                      "Create new account!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 5, 108, 218),
                      ),
                    ),
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
