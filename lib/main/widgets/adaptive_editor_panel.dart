//追加・編集画面を端末幅に合わせて表示する共通処理
import 'package:flutter/material.dart';

Future<T?> showAdaptiveEditor<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double mobileHeightFactor = 0.82,
}) {
  final width = MediaQuery.of(context).size.width;
  final isWide = width >= 700;

  if (!isWide) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * mobileHeightFactor,
          child: builder(context),
        );
      },
    );
  }

  //Webなどの大画面では左からNotion風の編集ページを出す
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '閉じる',
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: (width * 0.68).clamp(620.0, 980.0).toDouble(),
            height: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xffF4F7FF),
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(30),
                right: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(8, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: builder(context),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
