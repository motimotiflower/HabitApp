import 'package:flutter/material.dart';
import 'package:habitapp/widgets/app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppHeader(title: "Home", showCalender: false));
  }
}
