//習慣を表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/widgets/habit_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/main/widgets/adaptive_editor_panel.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_habit/habit_schedule.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/z_habit/sheets/edit_habit_sheet.dart';
import 'package:habitapp/z_home/home_habit_record_page.dart';
import 'package:habitapp/z_habit/sheets/habit_category_manage_sheet.dart';
import 'package:habitapp/z_star/star_storage.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({
    super.key,
    this.onToday,
  });

  final VoidCallback? onToday;

  @override
  State<HabitPage> createState() => HabitPageState();
}

class HabitPageState extends State<HabitPage> {
  //選択中の曜日
  int selectedDayIndex = DateTime.now().weekday - 1;

  //指定した日が含まれる週の月曜日を取得
  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  //現在表示している週の月曜日
  DateTime displayedMonday = _getMonday(DateTime.now());

  //習慣一覧
  List<Habit> habits = [];

  //ジャンル一覧と色
  List<String> _categories = [];
  Map<String, int> _categoryColors = {};

  //やり残しが複数あるときだけ折りたたむ
  bool _carryOverExpanded = false;

  //この画面で達成したやり残しは、ページを離れるまで表示を残す
  final Set<String> _sessionCarryOverIds = {};

  //データの追加
  void addHabit(Habit habit) {
    //実際の今日ではなく、カレンダーで今見ている日から表示を始める
    final selectedDate = displayedMonday.add(
      Duration(days: selectedDayIndex),
    );
    final addedHabit = Habit(
      id: habit.id,
      title: habit.title,
      icon: habit.icon,
      iconAsset: habit.iconAsset,
      days: habit.days,
      category: habit.category,
      notificationEnabled: habit.notificationEnabled,
      notificationDays: habit.notificationDays,
      notificationDate: habit.notificationDate,
      notificationHour: habit.notificationHour,
      notificationMinute: habit.notificationMinute,
      completionHistory: habit.completionHistory,
      completionDates: habit.completionDates,
      shareCompletion: habit.shareCompletion,
      carryOverIfIncomplete: habit.carryOverIfIncomplete,
      priority: habit.priority,
      endDate: habit.endDate,
      deadlineWeekOffset: habit.deadlineWeekOffset,
      deadlineWeekday: habit.deadlineWeekday,
      carryOverDays: habit.carryOverDays,
      skippedDates: List<String>.from(habit.skippedDates),
      startedAt: selectedDate,
      subtasks: habit.subtasks,
    );
    setState(() {
      habits.add(addedHabit);
    });

    HabitStorage.saveHabits(habits);
    _reloadCategoryColors();
  }

  //データの編集
  void _editHabit(Habit oldHabit, Habit newHabit) {
    final index = habits.indexOf(oldHabit);
    if (index == -1) return;

    setState(() {
      habits[index] = newHabit;
    });

    HabitStorage.saveHabits(habits);
  }

  //SnackBarから元に戻せるよう、変更前の位置も保持する
  Future<void> _archiveHabit(Habit habit) async {
    final index = habits.indexOf(habit);
    if (index == -1) return;
    final archived = Habit(
      id: habit.id,
      title: habit.title,
      icon: habit.icon,
      iconAsset: habit.iconAsset,
      days: habit.days,
      category: habit.category,
      notificationEnabled: habit.notificationEnabled,
      notificationDays: habit.notificationDays,
      notificationDate: habit.notificationDate,
      notificationHour: habit.notificationHour,
      notificationMinute: habit.notificationMinute,
      completionHistory: Map<String, bool>.from(habit.completionHistory),
      completionDates: Map<String, String>.from(habit.completionDates),
      shareCompletion: habit.shareCompletion,
      carryOverIfIncomplete: habit.carryOverIfIncomplete,
      priority: habit.priority,
      endDate: habit.endDate,
      deadlineWeekOffset: habit.deadlineWeekOffset,
      deadlineWeekday: habit.deadlineWeekday,
      carryOverDays: habit.carryOverDays,
      skippedDates: List<String>.from(habit.skippedDates),
      startedAt: habit.startedAt,
      //実際の今日ではなく、カレンダーで開いている日からアーカイブ
      archivedAt: displayedMonday.add(
        Duration(days: selectedDayIndex),
      ),
      subtasks: habit.subtasks,
    );
    setState(() => habits[index] = archived);
    await HabitStorage.saveHabits(habits);
    if (!mounted) return;
    _showUndoSnackBar('アーカイブしました', () async {
      setState(() => habits[index] = habit);
      await HabitStorage.saveHabits(habits);
    });
  }

  //指定した設定日だけをスキップする
  Future<void> _skipHabit(Habit habit, DateTime date) async {
    final index = habits.indexOf(habit);
    if (index == -1) return;

    final key = habitDateKey(date);
    if (habit.skippedDates.contains(key)) return;

    final skipped = Habit(
      id: habit.id,
      title: habit.title,
      icon: habit.icon,
      iconAsset: habit.iconAsset,
      days: habit.days,
      category: habit.category,
      notificationEnabled: habit.notificationEnabled,
      notificationDays: habit.notificationDays,
      notificationDate: habit.notificationDate,
      notificationHour: habit.notificationHour,
      notificationMinute: habit.notificationMinute,
      completionHistory: Map<String, bool>.from(habit.completionHistory),
      completionDates: Map<String, String>.from(habit.completionDates),
      shareCompletion: habit.shareCompletion,
      carryOverIfIncomplete: habit.carryOverIfIncomplete,
      priority: habit.priority,
      endDate: habit.endDate,
      deadlineWeekOffset: habit.deadlineWeekOffset,
      deadlineWeekday: habit.deadlineWeekday,
      carryOverDays: habit.carryOverDays,
      skippedDates: [...habit.skippedDates, key],
      startedAt: habit.startedAt,
      archivedAt: habit.archivedAt,
      subtasks: habit.subtasks,
    );

    setState(() {
      habits[index] = skipped;
      _sessionCarryOverIds.remove(habit.id);
    });
    await HabitStorage.saveHabits(habits);

    if (!mounted) return;
    _showUndoSnackBar('この日をスキップしました', () async {
      setState(() => habits[index] = habit);
      await HabitStorage.saveHabits(habits);
    });
  }

  Future<void> _deleteHabit(Habit habit) async {
    final index = habits.indexOf(habit);
    if (index == -1) return;
    setState(() {
      habits.removeAt(index);
      //削除した習慣を画面内のやり残し情報にも残さない
      _sessionCarryOverIds.remove(habit.id);
    });

    //削除は達成記録ごと完全削除。獲得済みの星の欠片は残す
    await HabitStorage.saveHabits(habits);
    if (!mounted) return;
    _showUndoSnackBar('削除しました', () async {
      final insertIndex = index.clamp(0, habits.length);
      setState(() => habits.insert(insertIndex, habit));
      await HabitStorage.saveHabits(habits);
    });
  }

  //画面下に数秒だけ「元に戻す」を表示する
  void _showUndoSnackBar(String message, Future<void> Function() onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () {
              onUndo();
            },
          ),
        ),
      );
  }

  Future<void> _addCategory(String name, int color) async {
    if (_categories.contains(name)) return;

    setState(() {
      _categories.add(name);
      _categories.sort();
      _categoryColors[name] = color;
    });

    await HabitCategoryStorage.saveCategories(_categories);
    await HabitCategoryStorage.saveCategoryColors(_categoryColors);
  }

  Future<void> _renameCategory(String oldName, String newName) async {
    if (newName.isEmpty || _categories.contains(newName)) return;

    setState(() {
      final index = _categories.indexOf(oldName);
      if (index != -1) {
        _categories[index] = newName;
        _categories.sort();
      }

      final oldColor = _categoryColors.remove(oldName);
      if (oldColor != null) {
        _categoryColors[newName] = oldColor;
      }

      habits = habits.map((habit) {
        if (habit.category != oldName) return habit;

        return Habit(
          id: habit.id,
          title: habit.title,
          icon: habit.icon,
          iconAsset: habit.iconAsset,
          days: habit.days,
          category: newName,
          notificationEnabled: habit.notificationEnabled,
          notificationDays: habit.notificationDays,
          notificationDate: habit.notificationDate,
          notificationHour: habit.notificationHour,
          notificationMinute: habit.notificationMinute,
          completionHistory: Map<String, bool>.from(
            habit.completionHistory,
          ),
          completionDates: Map<String, String>.from(habit.completionDates),
          shareCompletion: habit.shareCompletion,
          carryOverIfIncomplete: habit.carryOverIfIncomplete,
          priority: habit.priority,
          endDate: habit.endDate,
          deadlineWeekOffset: habit.deadlineWeekOffset,
          deadlineWeekday: habit.deadlineWeekday,
          carryOverDays: habit.carryOverDays,
          skippedDates: List<String>.from(habit.skippedDates),
          startedAt: habit.startedAt,
          archivedAt: habit.archivedAt,
          subtasks: habit.subtasks,
        );
      }).toList();
    });

    await HabitCategoryStorage.saveCategories(_categories);
    await HabitCategoryStorage.saveCategoryColors(_categoryColors);
    await HabitStorage.saveHabits(habits);
  }

  Future<void> _deleteCategory(String category) async {
    setState(() {
      _categories.remove(category);
      _categoryColors.remove(category);

      habits = habits.map((habit) {
        if (habit.category != category) return habit;

        return Habit(
          id: habit.id,
          title: habit.title,
          icon: habit.icon,
          days: habit.days,
          category: '未設定',
          notificationEnabled: habit.notificationEnabled,
          notificationDays: habit.notificationDays,
          notificationDate: habit.notificationDate,
          notificationHour: habit.notificationHour,
          notificationMinute: habit.notificationMinute,
          completionHistory: Map<String, bool>.from(
            habit.completionHistory,
          ),
          completionDates: Map<String, String>.from(habit.completionDates),
          shareCompletion: habit.shareCompletion,
          carryOverIfIncomplete: habit.carryOverIfIncomplete,
          priority: habit.priority,
          endDate: habit.endDate,
          deadlineWeekOffset: habit.deadlineWeekOffset,
          deadlineWeekday: habit.deadlineWeekday,
          carryOverDays: habit.carryOverDays,
          skippedDates: List<String>.from(habit.skippedDates),
          startedAt: habit.startedAt,
          archivedAt: habit.archivedAt,
          subtasks: habit.subtasks,
        );
      }).toList();
    });

    await HabitCategoryStorage.saveCategories(_categories);
    await HabitCategoryStorage.saveCategoryColors(_categoryColors);
    await HabitStorage.saveHabits(habits);
  }

  Future<void> _changeCategoryColor(String category, int color) async {
    setState(() {
      _categoryColors[category] = color;
    });

    await HabitCategoryStorage.saveCategoryColors(_categoryColors);
  }

  Future<void> _showCategoryManageSheet() async {
    await showAdaptiveEditor(
      context: context,
      mobileHeightFactor: 0.80,
      builder: (context) {
        return HabitCategoryManageSheet(
          categories: _categories,
          colors: _categoryColors,
          onAdd: _addCategory,
          onRename: _renameCategory,
          onDelete: _deleteCategory,
          onColorChanged: _changeCategoryColor,
        );
      },
    );

    await reloadHabits();
  }

  //編集画面
  void _showEditSheet(Habit habit) {
    showAdaptiveEditor(
      context: context,
      mobileHeightFactor: 0.82,
      builder: (context) {
        return EditHabitSheet(
          habit: habit,
          onSave: (editedHabit) {
            _editHabit(habit, editedHabit);
          },
        );
      },
    ).whenComplete(_reloadCategoryColors);
  }

  //HomeとHabitで同じ記録ページを使う
  void _showRecordSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeHabitRecordPage(
          habits: habits,
          categoryColors: _categoryColors,
          onHabitsChanged: (updated) async {
            setState(() => habits = updated);
            await HabitStorage.saveHabits(habits);
          },
        ),
      ),
    );
  }

  //削除は完全削除なので最後に確認する
  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('習慣を削除'),
          content: Text('「${habit.title}」を完全に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteHabit(habit);
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  //表示する曜日を変更
  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  //表示する週を変更
  void changeDisplayedWeek(DateTime monday) {
    setState(() {
      displayedMonday = monday;
    });
  }

  @override
  void initState() {
    super.initState();
    reloadHabits();
  }

  //保存データの読み込み
  Future<void> reloadHabits() async {
    final loadedHabits = await HabitStorage.loadHabits();
    final categories = await HabitCategoryStorage.loadCategories();
    final categoryColors =
        await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      habits = loadedHabits;
      _categories = categories;
      _categoryColors = categoryColors;
    });
  }

  //ジャンル色だけを読み直す
  Future<void> _reloadCategoryColors() async {
    final categoryColors =
        await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      _categoryColors = categoryColors;
    });
  }

  Widget _sectionTitle(String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff526FC5),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              thickness: 0.7,
              color: Color(0xffCDD5F0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const days = ["月", "火", "水", "木", "金", "土", "日"];

    final selectedDay = days[selectedDayIndex];

    //表示中の週から、選択した曜日の日付を取得
    final selectedDate = displayedMonday.add(
      Duration(days: selectedDayIndex),
    );

    //本来の習慣と「やり残し」を分ける
    final scheduledHabits = habits.where((habit) {
      return habit.archivedAt == null &&
          habitIsScheduledOn(habit, selectedDate);
    }).toList();
    scheduledHabits.sort((a, b) => b.priority.compareTo(a.priority));

    final carryOverHabits = habits.where((habit) {
      return habit.archivedAt == null &&
          !habitIsScheduledOn(habit, selectedDate) &&
          (habitShouldDisplayOn(habit, selectedDate) ||
              _sessionCarryOverIds.contains(habit.id));
    }).toList();
    carryOverHabits.sort((a, b) => b.priority.compareTo(a.priority));

    //やり残しは件数行で折りたたみ、通常習慣はその下に表示
    //閉じている時は要約だけ、開いた時に全件を表示する
    final visibleCarryOvers =
        _carryOverExpanded ? carryOverHabits : <Habit>[];
    final selectedDayHabits = [...visibleCarryOvers, ...scheduledHabits];
    final showCarryOverHeader = carryOverHabits.isNotEmpty;
    final showTodayHeader = scheduledHabits.isNotEmpty;

    //達成履歴で使用する日付キー
    final dateKey =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    //共有ONなら、その週は同じキーで達成状態を持つ
    final weekKey =
        'week-${displayedMonday.year}-'
        '${displayedMonday.month.toString().padLeft(2, '0')}-'
        '${displayedMonday.day.toString().padLeft(2, '0')}';

    return MainContent(
      overlap: 0,
      child: Column(
        children: [
          //記録画面への入口
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _showCategoryManageSheet,
                icon: const Icon(Icons.folder_outlined, size: 18),
                label: const Text('ジャンル管理'),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff526FC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                  ),
                  onPressed: _showRecordSheet,
                  icon: const Icon(
                    Icons.auto_graph,
                    size: 19,
                  ),
                  label: const Text(
                    '記録',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: widget.onToday,
                child: const Text('今日'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          //習慣が増えても一覧だけスクロールできる
          Expanded(
            child: RefreshIndicator(
              // 下に引っ張るとウィジェット側の変更を読み直す
              onRefresh: reloadHabits,
              child: ReorderableListView.builder(
                    //行を長押しして並び替える
                    buildDefaultDragHandles: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    //右下の＋ボタンと最後のチェックが重ならないよう下に余白
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: selectedDayHabits.isEmpty
                        ? 1
                        : selectedDayHabits.length +
                            (showCarryOverHeader ? 1 : 0) +
                            (showTodayHeader ? 1 : 0),
                    //表示順は優先度で決まるため手動並び替えは行わない
                    onReorder: (_, __) {},
                    itemBuilder: (context, index) {
                      if (selectedDayHabits.isEmpty &&
                          !showCarryOverHeader &&
                          !showTodayHeader) {
                        return const SizedBox(
                          key: ValueKey('empty'),
                          height: 320,
                          child: Center(
                            child: Text(
                              'この日の習慣はありません',
                              style: TextStyle(color: Color(0xff81889B)),
                            ),
                          ),
                        );
                      }
                      var dataIndex = index;

                      if (showCarryOverHeader && dataIndex == 0) {
                        return Column(
                          key: const ValueKey('carry-over-header'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //見出し全体をタップして開閉できるようにする
                            InkWell(
                              onTap: () => setState(
                                () => _carryOverExpanded = !_carryOverExpanded,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
                                child: Row(
                                  children: [
                                    const Text('やり残し', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffD95C5C))),
                                    const SizedBox(width: 8),
                                    const Expanded(child: Divider(thickness: 0.7, color: Color(0xffE5B7B7))),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _carryOverExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                      color: const Color(0xffD95C5C),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //閉じている時だけ内容の要約を表示する
                            if (!_carryOverExpanded)
                              InkWell(
                                onTap: () => setState(() => _carryOverExpanded = true),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                                  child: Text(
                                    '${carryOverHabits.first.title} など${carryOverHabits.length}件',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xffD95C5C)),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
                      if (showCarryOverHeader) dataIndex--;

                      final carryCount = visibleCarryOvers.length;
                      if (showTodayHeader && dataIndex == carryCount) {
                        return _sectionTitle(
                          '今日の習慣',
                          key: const ValueKey('today-habit-header'),
                        );
                      }
                      if (showTodayHeader && dataIndex > carryCount) {
                        dataIndex--;
                      }

                      final habit = selectedDayHabits[dataIndex];
                      final categoryColor = habit.category == '未設定'
                          ? null
                          : Color(
                              _categoryColors[habit.category] ??
                                  0xff526FC5,
                            );

                      final sourceDate =
                          habitDisplaySourceDate(habit, selectedDate) ??
                              selectedDate;
                      final completionKey =
                          habitCompletionKeyForDate(habit, sourceDate);

                      final card = HabitCard(
                        key: ValueKey(habit.id),
                        habit: habit,
                        isDone:
                            habit.completionHistory[completionKey] ?? false,
                        categoryColor: categoryColor,

                        //達成状態の変更
                        onChanged: () async {
                          final wasDone =
                              habit.completionHistory[completionKey] ?? false;
                          final wasCarryOver =
                              !habitIsScheduledOn(habit, selectedDate);

                          setState(() {
                            habit.completionHistory[completionKey] = !wasDone;
                            //達成直後にやり残し欄から消えないよう画面内だけ保持
                            if (wasCarryOver && !wasDone) {
                              _sessionCarryOverIds.add(habit.id);
                            }
                          });

                          await HabitStorage.saveHabits(habits);

                          //達成で星の欠片+1、ガチャ前なら解除で取り消す
                          final actionKey =
                              'habit|${habit.id}|$completionKey';

                          if (!wasDone) {
                            await StarStorage.award(
                              actionKey: actionKey,
                              source: 'habit',
                            );
                          } else {
                            await StarStorage.revoke(actionKey);
                          }
                        },

                        //サブタスクも親とは独立して達成できる
                        subtaskIsDone: (subtaskIndex) {
                          return habit.subtasks[subtaskIndex]
                                  .completionHistory[completionKey] ??
                              false;
                        },
                        onSubtaskChanged: (subtaskIndex) async {
                          final subtask = habit.subtasks[subtaskIndex];
                          final wasDone =
                              subtask.completionHistory[completionKey] ?? false;
                          setState(() {
                            subtask.completionHistory[completionKey] = !wasDone;
                          });
                          await HabitStorage.saveHabits(habits);

                          final actionKey =
                              'habit-subtask|${habit.id}|${subtask.id}|$completionKey';
                          if (!wasDone) {
                            await StarStorage.award(
                              actionKey: actionKey,
                              source: 'habit-subtask',
                            );
                          } else {
                            await StarStorage.revoke(actionKey);
                          }
                        },
                        //編集
                        onEdit: () {
                          _showEditSheet(habit);
                        },

                        //3点メニューから各操作を行う
                        onSkip: () {
                          _skipHabit(habit, sourceDate);
                        },
                        onArchive: () {
                          _archiveHabit(habit);
                        },
                        onDelete: () {
                          _showDeleteDialog(habit);
                        },
                      );

                      return card;
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
