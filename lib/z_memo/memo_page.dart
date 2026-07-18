import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainBackground(title: "Memo", showCalendar: false),
    );
  }
}
