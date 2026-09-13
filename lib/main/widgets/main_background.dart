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
  static const double headerRatio = 0.245;

  static double headerHeight(BuildContext context) {
    //Habitページの内容量を基準に、上下の余白が近くなる高さへ統一
    return (MediaQuery.of(context).size.height * headerRatio)
        .clamp(218.0, 250.0)
        .toDouble();
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
        // 共通ヘッダーに幻想的な背景画像を使う
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //タイトルは少し下げ、下の部品はタイトル寄りにまとめる
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
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
                  ),

                  const SizedBox(height: 4),

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

                  const SizedBox(height: 2),

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
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
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
      ),
    );
  }
}
