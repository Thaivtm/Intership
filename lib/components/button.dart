import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String title;
  final void Function() onPressed;

  const Button({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RawMaterialButton(
        fillColor: Color.fromARGB(255, 5, 108, 218),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
