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

  //データの追加
  void addHabit(Habit habit) {
    //追加した日より前には習慣を表示しない
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
      startedAt: DateTime.now(),
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

  //記録を残したまま通常一覧から外す
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
      startedAt: habit.startedAt,
      archivedAt: DateTime.now(),
      subtasks: habit.subtasks,
    );
    setState(() => habits[index] = archived);
    await HabitStorage.saveHabits(habits);
  }

  //データの削除
  void _deleteHabit(Habit habit) {
    setState(() {
      habits.remove(habit);
    });

    HabitStorage.saveHabits(habits);
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
          shareCompletion: habit.shareCompletion,
          carryOverIfIncomplete: habit.carryOverIfIncomplete,
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
          shareCompletion: habit.shareCompletion,
          carryOverIfIncomplete: habit.carryOverIfIncomplete,
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

  //削除確認
  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('習慣を削除'),
          content: Text('「${habit.title}」をどうしますか？'),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('アーカイブ'),
                      onPressed: () {
                        Navigator.pop(context);
                        _archiveHabit(habit);
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteHabit(habit);
                      },
                      child: const Text('削除'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('キャンセル'),
                    ),
                  ),
                ],
              ),
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
    final carryOverHabits = habits.where((habit) {
      return habit.archivedAt == null &&
          !habitIsScheduledOn(habit, selectedDate) &&
          habitShouldDisplayOn(habit, selectedDate);
    }).toList();

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
                    onReorder: (oldIndex, newIndex) async {
                      if (selectedDayHabits.isEmpty || showCarryOverHeader) {
                        return;
                      }
                      if (newIndex > oldIndex) newIndex--;

                      final moved = selectedDayHabits.removeAt(oldIndex);
                      selectedDayHabits.insert(newIndex, moved);

                      //表示中の習慣だけ順番を入れ替え、他曜日の習慣は残す
                      final selectedIds =
                          selectedDayHabits.map((habit) => habit.id).toSet();
                      var selectedIndex = 0;
                      setState(() {
                        for (var i = 0; i < habits.length; i++) {
                          if (selectedIds.contains(habits[i].id)) {
                            habits[i] = selectedDayHabits[selectedIndex++];
                          }
                        }
                      });
                      await HabitStorage.saveHabits(habits);
                    },
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
                      final canReorder = carryOverHabits.isEmpty;

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

                          setState(() {
                            habit.completionHistory[completionKey] = !wasDone;
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

                        //削除
                        onDelete: () {
                          _showDeleteDialog(habit);
                        },
                      );

                      if (!canReorder) {
                        return card;
                      }

                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(habit.id),
                        index: index,
                        child: card,
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
