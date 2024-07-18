import 'package:flutter/material.dart';

class AvatarView extends StatelessWidget {
  final String avatarUrl;

  const AvatarView({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: 'avatarHero',
          child: Image.network(avatarUrl),
        ),
      ),
    );
  }
}