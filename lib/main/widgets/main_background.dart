import 'package:flutter/material.dart';
import 'dart:math';

class MainBackground extends StatelessWidget {
  const MainBackground({
    super.key,
    required this.title,
    required this.showCalendar,
    this.onDaySelected,
    this.selectedDayIndex,
    this.displayedMonday,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onToday,
    this.onSettings,
  });

  final String title;
  final bool showCalendar;
  final void Function(int)? onDaySelected;
  final int? selectedDayIndex;
  final DateTime? displayedMonday;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final VoidCallback? onToday;
  final VoidCallback? onSettings;

  //各メインページが共通で参照するヘッダー高さ
  static const double headerRatio = 0.30;

  static double headerHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * headerRatio;
  }

  //詳細ページのAppBarもここを参照する
  static const double detailToolbarHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final height = headerHeight(context);
    final horizontalPadding =
        screenWidth > 700 ? 60.0 : screenWidth * 0.06;
    final titleFontSize = min(screenWidth * 0.08, 36.0);
    final dateFontSize = min(screenWidth * 0.08, 18.0);
    final dayFontSize = min(screenWidth * 0.08, 16.0);
    final daySize = min(screenWidth * 0.09, 50.0);

    final now = DateTime.now();
    final startOfWeek =
        displayedMonday ?? now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)).day,
    );
    const days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff102d72),
            Color(0xff5e78cf),
          ],
        ),
      ),
      child: Padding(
        //上を少し詰めつつ、上下は同じ余白にする
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          18,
          horizontalPadding,
          18,
        ),
        child: showCalendar
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onToday,
                        child: const Text(
                          '今日',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          tooltip: '設定',
                          onPressed: onSettings,
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onPreviousWeek,
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Text(
                        '${startOfWeek.year}年'
                        '${startOfWeek.month}月'
                        '${startOfWeek.day}日〜',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: onNextWeek,
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;

                      return GestureDetector(
                        onTap: () => onDaySelected?.call(index),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: dayFontSize,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: daySize,
                              height: daySize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index ==
                                        (selectedDayIndex ??
                                            now.weekday - 1)
                                    ? const Color(0xffa9a6f4)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                dates[index].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: dateFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topCenter,
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: '設定',
                        onPressed: onSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
