//各ページの土台となる白いカード
//各ページで使ってあげる
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.child, this.overlap = 30.0});

  final Widget child;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    //変数
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * MainBackground.headerRatio;

    return Padding(
      padding: EdgeInsets.only(top: headerHeight - overlap),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),

        decoration: const BoxDecoration(
          color: Color(0xfffbfaff),
          //borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),

        //各ページの中身
        child: child,
      ),
    );
  }
}
