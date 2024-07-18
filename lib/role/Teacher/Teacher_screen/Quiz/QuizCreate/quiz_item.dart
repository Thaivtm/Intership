import 'package:flutter/material.dart';
import 'package:flutter_application_1/role/Teacher/Teacher_screen/Quiz/QuizCreate/quiz_object.dart';

class QuizItem extends StatelessWidget {
  const QuizItem({
    super.key,
    required this.data,
    required this.index,
    this.onDeletePressed,
  });

  final QuizObject data;
  final int index;
  final Function? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDeletePressed!(index);
                },
              ),
            ],
          ),
          Text('Question: ${data.title}'),
          const SizedBox(height: 5),
          Text('Option A: ${data.a}'),
          const SizedBox(height: 1),
          Text('Option B: ${data.b}'),
          const SizedBox(height: 1),
          Text('Option C: ${data.c}'),
          const SizedBox(height: 1),
          Text('Option D: ${data.d}'),
          const SizedBox(height: 1),
          Text(
            'Answer: ${data.correctAnswerIndex}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
