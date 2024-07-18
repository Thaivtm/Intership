import 'package:flutter/material.dart';

class InputInfo extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final IconData? iconData;
  final dynamic obscureText;
  final int? maxLines;

  const InputInfo({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
    this.iconData,
    required this.obscureText,
    this.maxLines,
  });

  @override
  Widget build(Object context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.left,
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 83, 83, 83),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Opacity(
          opacity: 0.7,
          child: TextField(
            obscureText: obscureText,
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              prefixIcon: Icon(
                iconData,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
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
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}
