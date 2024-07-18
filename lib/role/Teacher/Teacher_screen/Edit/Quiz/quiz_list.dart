import 'package:flutter/material.dart';

class QuizQuestionItem extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final int questionIndex;

  QuizQuestionItem({
    super.key,
    required this.questionData,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${questionIndex + 1}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          questionData['Question'] ?? 'No question found',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Option A: ${questionData['OptionA']}'),
                  Text('Option B: ${questionData['OptionB']}'),
                  Text('Option C: ${questionData['OptionC']}'),
                  Text('Option D: ${questionData['OptionD']}'),
                  Text(
                    'Correct Answer: ${questionData['CorrectAnswer']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEditPressed,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDeletePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
