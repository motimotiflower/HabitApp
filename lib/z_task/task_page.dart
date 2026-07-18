import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainBackground(title: "Task", showCalendar: false),
    );
  }
}
