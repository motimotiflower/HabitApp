import 'package:flutter/material.dart';
import 'package:habitapp/widgets/app_header.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppHeader(title: "Task", showCalender: false));
  }
}
