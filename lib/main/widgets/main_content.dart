//各ページの土台となる白いカード
//各ページで使ってあげる
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    //変数
    const overlap = 30.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * MainBackground.headerRatio;

    return Positioned(
      top: headerHeight - overlap,
      left: 0,
      right: 0,
      bottom: 0,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),

        decoration: const BoxDecoration(
          color: Color(0xfffbfaff),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),

        //各ページの中身
        child: child,
      ),
    );
  }
}
