import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainBackground(title: "Home", showCalendar: false),
    );
  }
}
