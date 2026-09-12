//画面幅に応じてBottomSheetとNotion風サイドページを切り替える
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
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * mobileHeightFactor,
          child: builder(context),
        );
      },
    );
  }

  //Webなどの大画面では右側からNotion風の編集ページを出す
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '閉じる',
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = (screenWidth * 0.72).clamp(680.0, 1100.0);

      return SafeArea(
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
              child: SizedBox(
                width: panelWidth,
                height: double.infinity,
                child: builder(context),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );

      return SlideTransition(
        position: offset,
        child: child,
      );
    },
  );
}
