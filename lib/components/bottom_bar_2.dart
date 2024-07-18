import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNavigationBar2 extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigationBar2(
      {super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      backgroundColor: const Color.fromARGB(255, 4, 141, 91),
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.chat_bubble),
          title: const Text('Home'),
          selectedColor: Colors.white,
          unselectedColor: Colors.white70,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.storage),
          title: const Text('Add Course'),
          selectedColor: Colors.white,
          unselectedColor: Colors.white70,
        ),
      ],
    );
  }
}
