import 'package:flutter/material.dart';

class FAQStaff extends StatefulWidget {
  const FAQStaff({super.key});

  @override
  State<FAQStaff> createState() => _FAQStaffState();
}

class _FAQStaffState extends State<FAQStaff> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<FAQItem> _faqItems = [
    FAQItem(
        question: 'What is a Learning Management System (LMS)?',
        answer:
            'A Learning Management System (LMS) is a software application used to manage, deliver, and track educational courses and training programs.'),
    FAQItem(
        question:
            'What are the key features of the LMS described in this mobile app?',
        answer:
            'The LMS allows teachers to create and edit courses, exercises, and materials such as videos and slides. Teachers can also check exercise status, and view learners scores. Learners can access courses using course IDs, watch videos, view slides, and complete exercises.'),
    FAQItem(
        question: 'How can teachers benefit from using this LMS?',
        answer:
            'Teachers can use the LMS to create interactive courses, monitor learner progress, and easily assess learners performance through exercises and scores.'),
    FAQItem(
        question: 'What advantages do learners have when using this system?',
        answer:
            'Learners can access course materials anytime, anywhere, complete exercises, and track their own progress within the courses.'),
    FAQItem(
        question:
            'How does this Learning Management System support teachers teaching?',
        answer:
            'The LMS provides a versatile support tool for teachers to create engaging courses, monitor learner participation, and assess student performance effectively.'),
    FAQItem(
        question: 'How are learners able to access courses within the system?',
        answer:
            'Learners can easily access courses by using the unique course IDs provided by teachers.'),
    FAQItem(
        question:
            'How are exercises and assessments conducted within the system?',
        answer:
            'Teachers can create exercises for learners to complete, and learners can submit their responses for assessment within the system.'),
    FAQItem(
        question:
            'Can teachers track learners progress and performance in real-time?',
        answer:
            'Yes, teachers can monitor learner progress, exercise completion, and scores in real-time within the system.'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView.builder(
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            transform:
                Matrix4.translationValues(0.0, _animation.value * 100, 0.0),
            child: ExpansionTile(
              title: Text(_faqItems[index].question),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_faqItems[index].answer),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
