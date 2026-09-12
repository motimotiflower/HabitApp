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

  //曜日が押された時に、何番目の曜日かを親に渡す
  final void Function(int)? onDaySelected;
  final int? selectedDayIndex;

  //表示している週の月曜日
  final DateTime? displayedMonday;

  //週移動ボタンが押された時の処理
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  //今日に戻る処理
  final VoidCallback? onToday;

  //設定画面を開く
  final VoidCallback? onSettings;

  static const double headerRatio = 0.30;

  @override
  Widget build(BuildContext context) {
    //変数-----------------------------------
    //高さや幅
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * headerRatio;

    final horizontalPadding = screenWidth > 700 ? 60.0 : screenWidth * 0.06;

    //タイトル
    final titlePosition = headerHeight * 0.26;
    final titlePadding = min(screenWidth * 0.07, 60.0); //小さいほう使う
    final titleFontSize = min(screenWidth * 0.08, 36.0);

    //アイコン
    final iconPosition = headerHeight * 0.26;

    //週表示
    final weekPosition = headerHeight * 0.45;

    //曜日
    final days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    final dayPosition = headerHeight * 0.65;
    final dayFontSize = min(screenWidth * 0.08, 16.0);
    final daySize = min(screenWidth * 0.09, 50.0);

    //日にち---------------------------------
    final dateFontSize = min(screenWidth * 0.08, 18.0);

    //今日を取得(例：2026/7/12)
    final now = DateTime.now();

    //表示する週の月曜日(指定がなければ今週の月曜日を使う)
    final startOfWeek =
        displayedMonday ?? now.subtract(Duration(days: now.weekday - 1));

    //月曜の日付から1週間分作る
    final dates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index)).day;
    });

    return Stack(
      //複数のwidgetを重ねる
      children: [
        //背景--------------------------
        Container(
          height: double.infinity,
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

        //今日ボタン・設定アイコン---------------------
        Positioned(
          top: iconPosition,
          right: horizontalPadding,

          child: Row(
            children: [
              //今日に戻るボタン
              if (showCalendar)
                TextButton(
                  onPressed: onToday,
                  child: const Text(
                    '今日',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              //どのページでも同じ位置になるよう高さを固定
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

        //週の切り替え----------------------------
        if (showCalendar)
          Positioned(
            top: weekPosition,
            left: horizontalPadding,
            right: horizontalPadding,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //前の週へ
                IconButton(
                  onPressed: onPreviousWeek,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                //表示中の年月
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

                //次の週へ
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
                return GestureDetector(
                  onTap: () {
                    onDaySelected?.call(index);
                  },

                  child: Column(
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

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == (selectedDayIndex ?? now.weekday - 1)
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
          ),
      ],
    );
  }
}
