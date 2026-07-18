import 'package:flutter/material.dart';
import 'dart:math';

class MainBackground extends StatelessWidget {
  const MainBackground({
    super.key,
    required this.title,
    required this.showCalendar,
  });

  final String title;
  final bool showCalendar;
  static const double headerRatio = 0.26;

  @override
  Widget build(BuildContext context) {
    //変数-----------------------------------
    //高さや幅
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * headerRatio;

    final horizontalPadding = screenWidth > 700 ? 60.0 : screenWidth * 0.06;

    //タイトル
    final titlePosition = headerHeight * 0.3;
    final titlePadding = min(screenWidth * 0.07, 60.0); //小さいほう使う
    final titleFontSize = min(screenWidth * 0.08, 36.0);

    //アイコン
    final iconPosition = headerHeight * 0.3;

    //曜日
    final days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    final dayPosition = headerHeight * 0.60;
    final dayFontSize = min(screenWidth * 0.08, 16.0);
    final daySize = min(screenWidth * 0.09, 50.0);

    //日にち---------------------------------
    final dateFontSize = min(screenWidth * 0.08, 18.0);

    //今日を取得(例：2026/7/12)
    final now = DateTime.now();

    //今日の曜日をカウントしないで月曜日は何日前かで戻す
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    //月曜の日付から1週間分作る
    final dates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index)).day;
    });

    return Stack(
      //複数のwidgetを重ねる
      children: [
        //背景--------------------------
        Container(
          height: headerHeight,
          width: double.infinity, //横いっぱいに
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              //グラデーション(青から紫)
              colors: [Color(0xff102d72), Color(0xff5e78cf)],
            ),
          ),
        ),

        //タイトル----------------------
        Positioned(
          top: titlePosition,
          left: titlePadding,

          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        //設定アイコン---------------------
        Positioned(
          top: iconPosition,
          right: horizontalPadding,

          child: const Icon(Icons.settings_outlined, color: Colors.white),
        ),

        //曜日----------------------------
        if (showCalendar)
          Positioned(
            top: dayPosition,
            left: horizontalPadding,
            right: horizontalPadding,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              //曜日に番号を付ける
              children: days.asMap().entries.map((entry) {
                //変数-----------------------------
                final index = entry.key;
                final day = entry.value;

                //表示------------------------------
                return Column(
                  children: [
                    //曜日
                    Text(
                      day,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dayFontSize,
                      ),
                    ),

                    const SizedBox(height: 4),

                    //日付
                    Container(
                      width: daySize,
                      height: daySize,
                      alignment: Alignment.center,

                      //今日の日付に円
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: index == now.weekday - 1
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
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
