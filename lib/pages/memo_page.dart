import 'package:flutter/material.dart';
import 'package:habitapp/widgets/app_header.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppHeader(title: "Memo", showCalender: false));
  }
}
