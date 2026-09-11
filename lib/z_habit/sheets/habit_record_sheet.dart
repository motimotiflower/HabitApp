//習慣の達成記録を表示する画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitRecordSheet extends StatefulWidget {
  const HabitRecordSheet({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  @override
  State<HabitRecordSheet> createState() => _HabitRecordSheetState();
}

class _HabitRecordSheetState extends State<HabitRecordSheet> {
  String _range = '今日';

  static const _days = ['月', '火', '水', '木', '金', '土', '日'];

  //日付を保存キー形式にする
  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  //指定日の予定習慣数
  int _scheduledCount(DateTime date) {
    final dayName = _days[date.weekday - 1];

    return widget.habits
        .where((habit) => habit.days.contains(dayName))
        .length;
  }

  //指定日の達成数
  int _completedCount(DateTime date) {
    final key = _dateKey(date);

    return widget.habits
        .where((habit) => habit.completionHistory[key] == true)
        .length;
  }

  //表示範囲の日付を作る
  List<DateTime> _datesForRange() {
    final now = DateTime.now();

    if (_range == '今日') {
      return [DateTime(now.year, now.month, now.day)];
    }

    if (_range == '今週') {
      final monday = now.subtract(Duration(days: now.weekday - 1));

      return List.generate(
        7,
        (index) => DateTime(
          monday.year,
          monday.month,
          monday.day + index,
        ),
      );
    }

    final first = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final daysInMonth = nextMonth.difference(first).inDays;

    return List.generate(
      daysInMonth,
      (index) => DateTime(now.year, now.month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dates = _datesForRange();

    final scheduled = dates.fold<int>(
      0,
      (sum, date) => sum + _scheduledCount(date),
    );

    final completed = dates.fold<int>(
      0,
      (sum, date) => sum + _completedCount(date),
    );

    final progress = scheduled == 0 ? 0.0 : completed / scheduled;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF7F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '習慣の記録',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),

              const SizedBox(height: 14),

              //今日・今週・今月の切り替え
              Row(
                children: ['今日', '今週', '今月'].map((range) {
                  final selected = _range == range;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(child: Text(range)),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: const Color(0xff526FC5),
                        backgroundColor: const Color(0xffE8EDFC),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xff4763B4),
                        ),
                        onSelected: (_) {
                          setState(() {
                            _range = range;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              //達成数
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xffCDD5F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '達成状況',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff35415F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$completed / $scheduled',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff263A70),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xff526FC5),
                      backgroundColor: const Color(0xffE8EDFC),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '日ごとの記録',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff35415F),
                ),
              ),

              const SizedBox(height: 10),

              //件数が多い時もスクロールできる
              Expanded(
                child: ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final scheduledCount = _scheduledCount(date);
                    final completedCount = _completedCount(date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xffDCE3F5),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xff35415F),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                for (int i = 0; i < scheduledCount; i++)
                                  Icon(
                                    i < completedCount
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 18,
                                    color: i < completedCount
                                        ? const Color(0xff526FC5)
                                        : const Color(0xffB8C1D9),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '$completedCount/$scheduledCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff81889B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
