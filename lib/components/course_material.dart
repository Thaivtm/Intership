import 'package:flutter/material.dart';

class CourseMaterial extends StatelessWidget {
  final String title;
  final VoidCallback onchange;
  final IconData? iconData;

  const CourseMaterial(
      {super.key, required this.title, required this.onchange, this.iconData});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(iconData),
          onPressed: () {
            onchange();
          },
        ),
      ],
    );
  }
}
