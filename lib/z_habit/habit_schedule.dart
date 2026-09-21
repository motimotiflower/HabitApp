import 'package:habitapp/models/habit.dart';

const habitWeekdays = ['月', '火', '水', '木', '金', '土', '日'];

//時刻を除いた日付だけにそろえる
DateTime habitDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String habitDateKey(DateTime date) {
  final value = habitDateOnly(date);
  return '${value.year}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

DateTime habitMonday(DateTime date) {
  final value = habitDateOnly(date);
  return value.subtract(Duration(days: value.weekday - 1));
}

//指定日の達成状態が参照するキーを返す
String habitCompletionKeyForDate(Habit habit, DateTime scheduledDate) {
  if (!habit.shareCompletion) return habitDateKey(scheduledDate);

  final monday = habitMonday(scheduledDate);
  return 'week-${monday.year}-'
      '${monday.month.toString().padLeft(2, '0')}-'
      '${monday.day.toString().padLeft(2, '0')}';
}

bool habitIsActiveOn(Habit habit, DateTime date) {
  final target = habitDateOnly(date);
  final started = habit.startedAt == null ? null : habitDateOnly(habit.startedAt!);
  final archived = habit.archivedAt == null ? null : habitDateOnly(habit.archivedAt!);
  //締切は繰り返しルールなので、習慣そのものは終了させない
  //作成前・アーカイブ後には新しい習慣を表示しない
  if (started != null && target.isBefore(started)) return false;
  if (archived != null && !target.isBefore(archived)) return false;
  return true;
}

bool habitIsSkippedOn(Habit habit, DateTime date) =>
    habit.skippedDates.contains(habitDateKey(date));

//曜日上の設定日かを判定。スキップ判定とは分けて使う
bool habitIsBaseScheduledOn(Habit habit, DateTime date) {
  return habitIsActiveOn(habit, date) &&
      habit.days.contains(habitWeekdays[date.weekday - 1]);
}

bool habitIsScheduledOn(Habit habit, DateTime date) {
  return habitIsBaseScheduledOn(habit, date) && !habitIsSkippedOn(habit, date);
}

//その日以前で直近の設定曜日を探す
DateTime? habitLatestScheduledDate(Habit habit, DateTime date) {
  if (habit.days.isEmpty) return null;

  final target = habitDateOnly(date);
  for (var offset = 0; offset <= 7; offset++) {
    final candidate = target.subtract(Duration(days: offset));
    if (habitIsBaseScheduledOn(habit, candidate)) return candidate;
  }
  return null;
}

//表示日に使う「元の設定日」。nullならその日は表示しない
DateTime? habitDisplaySourceDate(Habit habit, DateTime date) {
  final target = habitDateOnly(date);

  //本来の設定日は常に表示する。ただしスキップ日は表示しない
  if (habitIsBaseScheduledOn(habit, target)) {
    return habitIsSkippedOn(habit, target) ? null : target;
  }
  if (!habit.carryOverIfIncomplete) return null;

  if (!habitIsActiveOn(habit, target)) return null;

  final source = habitLatestScheduledDate(habit, target);
  if (source == null || source == target) return null;

  //「今週/来週 + 曜日」を元の設定日の週から毎回計算する
  if (habit.deadlineWeekOffset != null && habit.deadlineWeekday != null) {
    final sourceMonday = habitMonday(source);
    final deadline = sourceMonday.add(
      Duration(
        days: habit.deadlineWeekOffset! * 7 + habit.deadlineWeekday! - 1,
      ),
    );
    if (target.isAfter(deadline)) return null;
  }

  //元の設定日をスキップしていたら、やり残しにも出さない
  if (habitIsSkippedOn(habit, source)) return null;

  //まだ実際に来ていない設定日は、未来のやり残しにしない
  final today = habitDateOnly(DateTime.now());
  if (source.isAfter(today)) return null;

  final key = habitCompletionKeyForDate(habit, source);

  //達成した翌日からは繰り越し表示を終了する
  if (habit.completionHistory[key] ?? false) return null;

  //次の設定曜日に来たら、その日の新しい習慣へ切り替わるため
  //ここでは直近の設定日から次の設定日前までだけ繰り越す
  return source;
}

bool habitShouldDisplayOn(Habit habit, DateTime date) =>
    habitDisplaySourceDate(habit, date) != null;
