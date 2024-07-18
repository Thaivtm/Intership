import 'package:flutter/material.dart';

class PageViewIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final Color color;
  final Color selectedColor;
  final double size;
  final double spacing;

  PageViewIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
    this.color = Colors.grey,
    this.selectedColor = Colors.blue,
    this.size = 10,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            itemCount,
            (index) => _buildIndicator(index),
          ),
        );
      },
    );
  }

  Widget _buildIndicator(int index) {
    double selectedSize = size * 1.5;
    double indicatorSize = controller.page == index ? selectedSize : size;
    Color indicatorColor = controller.page == index ? selectedColor : color;
    return Container(
      width: indicatorSize,
      height: indicatorSize,
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: indicatorColor,
      ),
    );
  }
}
