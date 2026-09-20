import 'package:flutter/material.dart';
import 'dart:math';

class MainBackground extends StatelessWidget {
  const MainBackground({
    super.key,
    required this.showCalendar,
    this.onDaySelected,
    this.selectedDayIndex,
    this.displayedMonday,
    this.onPreviousWeek,
    this.onNextWeek,
  });

  final bool showCalendar;
  final void Function(int)? onDaySelected;
  final int? selectedDayIndex;
  final DateTime? displayedMonday;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  //各メインページが共通で参照するヘッダー高さ
  static const double headerRatio = 0.17;

  static double headerHeight(BuildContext context) {
    //通知バーの下から、上下の余白が近くなるコンパクトな高さにする
    final contentHeight = (MediaQuery.of(context).size.height * headerRatio)
        .clamp(145.0, 165.0)
        .toDouble();
    return MediaQuery.of(context).padding.top + contentHeight;
  }

  //詳細ページのAppBarもここを参照する
  static const double detailToolbarHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final height = headerHeight(context);
    final horizontalPadding =
        screenWidth > 700 ? 60.0 : screenWidth * 0.06;
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
          image: AssetImage('assets/images/background_sky.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
        //ステータスバーの下に余白を確保してタイトルを配置
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          14,
          horizontalPadding,
          14,
        ),
        child: showCalendar
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //上部にタイトルや操作ボタンは置かない

                  const SizedBox(height: 0),

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
            : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
