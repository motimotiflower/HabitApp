import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/subtask.dart';
import 'package:habitapp/widgets/subtask_editor.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/notifications/notification_settings_card.dart';
import 'package:habitapp/notifications/notification_preference_storage.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({
    super.key,
    required this.onAddHabit,
    this.initialDayIndex,
  });

  final void Function(Habit) onAddHabit;
  final int? initialDayIndex;

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  static const days = ["月", "火", "水", "木", "金", "土", "日"];

  final selectedDays = <String>[];
  final titleController = TextEditingController();

  List<String> _categories = [];
  Map<String, int> _categoryColors = {};
  String _selectedCategory = '未設定';
  String? _hoveredCategory;
  IconData _selectedIcon = Icons.check;
  bool _notificationEnabled = true; //新しい習慣は通知を初期ONにする
  List<String> _notificationDays = [];
  DateTime? _notificationDate;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _shareCompletion = false;
  bool _carryOverIfIncomplete = false;
  int _priority = 2;
  int? _deadlineWeekOffset;
  int? _deadlineWeekday;
  List<Subtask> _subtasks = [];

  //青系UIになじむジャンルカラー
  static const List<Color> _categoryPalette = [
    Color(0xff32448C),
    Color(0xff6880D0),
    Color(0xff8B8DD3),
    Color(0xffB4BFE9),
    Color(0xffBEBDE4),
    Color(0xffEBD3E4),
    Color(0xffF3E4DC),
  ];

  final List<IconData> _icons = const [
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.music_note_rounded,
    Icons.dark_mode_rounded,
  ];

  @override
  void initState() {
    super.initState();
    //今見ていた曜日を最初から選択する
    final initial = widget.initialDayIndex;
    if (initial != null && initial >= 0 && initial < days.length) {
      selectedDays.add(days[initial]);
    }
    _loadCategories();
  }

  //保存されているジャンルを読み込む
  Future<void> _loadCategories() async {
    final categories = await HabitCategoryStorage.loadCategories();
    final categoryColors = await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _categoryColors = categoryColors;
    });
  }

  //ジャンルを追加
  Future<void> _addCategory() async {
    final controller = TextEditingController();
    Color selectedColor = _categoryPalette.first;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('ジャンルを追加'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'ジャンル名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('色'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryPalette.map((color) {
                      final selected = selectedColor == color;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? const Color(0xff263A70)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff526FC5),
                  ),
                  onPressed: () async {
                    final value = controller.text.trim();
                    if (value.isEmpty) return;
                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (name == null || _categories.contains(name)) return;

    setState(() {
      _categories.add(name);
      _categories.sort();
      _selectedCategory = name;
      _categoryColors[name] = selectedColor.toARGB32();
    });

    await HabitCategoryStorage.saveCategories(_categories);
    await HabitCategoryStorage.saveCategoryColors(_categoryColors);
  }

    @override
  Widget build(BuildContext context) {
    //Webでも曜日ボタンが大きくなりすぎないよう固定サイズにする
    const dayButtonSize = 42.0;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xffF4F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Text(
                      "追加",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff263A70),
                      ),
                    ),
                    const SizedBox(height: 24),

                    //見出しと入力欄が重ならないよう余白をそろえる
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'タイトル',
                        style: TextStyle(fontSize: 20, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    //タイトルのすぐ下でサブタスクを追加する
                    SubtaskEditor(
                      subtasks: _subtasks,
                      onChanged: (value) {
                        setState(() => _subtasks = value);
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text("曜日", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: 80,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffC8D0E8)),
                          backgroundColor:
                              selectedDays.length == days.length
                                  ? const Color(0xff526FC5)
                                  : Colors.white,
                          foregroundColor:
                              selectedDays.length == days.length
                                  ? Colors.white
                                  : const Color(0xff36498C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (selectedDays.length == days.length) {
                              selectedDays.clear();
                            } else {
                              selectedDays
                                ..clear()
                                ..addAll(days);
                            }
                          });
                        },
                        child: const Text("毎日"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      children: [
                        for (final day in days)
                          SizedBox(
                            width: dayButtonSize,
                            height: dayButtonSize,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xffC8D0E8),
                                ),
                                backgroundColor: selectedDays.contains(day)
                                    ? const Color(0xff526FC5)
                                    : Colors.white,
                                foregroundColor: selectedDays.contains(day)
                                    ? Colors.white
                                    : const Color(0xff36498C),
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (selectedDays.contains(day)) {
                                    selectedDays.remove(day);
                                  } else {
                                    selectedDays.add(day);
                                  }
                                });
                              },
                              child: Text(day),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text("ジャンル", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _categoryChip('未設定'),
                        ..._categories.map(_categoryChip),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('追加'),
                          onPressed: _addCategory,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    //優先度は高・中・低の3段階
                    const Text('優先度', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('低')),
                        ButtonSegment(value: 2, label: Text('中')),
                        ButtonSegment(value: 3, label: Text('高')),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (value) {
                        setState(() => _priority = value.first);
                      },
                    ),

                    const SizedBox(height: 18),
                    const Text("アイコン", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _icons.map((icon) {
                        final selected = _selectedIcon == icon;

                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: CircleAvatar(
                            backgroundColor: selected
                                ? const Color(0xff526FC5)
                                : const Color(0xffE8EDFC),
                            child: Icon(
                              icon,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xff526FC5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('他の曜日と達成を共有'),
                      value: _shareCompletion,
                      onChanged: (value) {
                        setState(() => _shareCompletion = value);
                      },
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('やり残しの表示'),
                      value: _carryOverIfIncomplete,
                      onChanged: (value) {
                        setState(() => _carryOverIfIncomplete = value);
                      },
                    ),

                    NotificationSettingsCard(
                      enabled: _notificationEnabled,
                      days: _notificationDays,
                      date: _notificationDate,
                      time: _notificationTime,
                      onEnabledChanged: (value) {
                        setState(() {
                          _notificationEnabled = value;
                        });
                      },
                      onDaysChanged: (value) {
                        setState(() {
                          _notificationDays = value;
                          _notificationDate = null;
                        });
                      },
                      onDateChanged: (value) {
                        setState(() {
                          _notificationDate = value;
                          if (value != null) {
                            _notificationDays = [];
                          }
                        });
                      },
                      onTimeChanged: (value) {
                        setState(() {
                          _notificationTime = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text('習慣の締切', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        //締切は「次の何曜日か」だけを選ぶ
                        //締切曜日は習慣の実行曜日とは別に、7曜日すべてから選べる
                        final deadlineWeekdays =
                            List<int>.generate(days.length, (index) => index + 1);

                        return DropdownButtonFormField<int?>(
                          value: deadlineWeekdays.contains(_deadlineWeekday)
                              ? _deadlineWeekday
                              : null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('設定なし'),
                            ),
                            for (final weekday in deadlineWeekdays)
                              DropdownMenuItem<int?>(
                                value: weekday,
                                child: Text('次の${days[weekday - 1]}曜日'),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                                    _deadlineWeekday = value;
                                    //0は「次に来るその曜日」を表す
                              _deadlineWeekOffset =
                                  value == null ? null : 0;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff526FC5),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;

                  //曜日が1つも選ばれていない場合は保存しない
                  if (selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('曜日を1つ以上選んでください'),
                      ),
                    );
                    return;
                  }

                  final notificationSettings =
                      await NotificationPreferenceStorage.load();

                  //まとめ通知では個別の日付・曜日を使わないので入力チェックをしない
                  if (_notificationEnabled &&
                      notificationSettings.mode != GlobalNotificationMode.batch &&
                      _notificationDate == null &&
                      _notificationDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('通知する曜日か日にちを選んでください'),
                      ),
                    );
                    return;
                  }

                  final habit = Habit(
                    title: titleController.text.trim(),
                    icon: _selectedIcon,
                    days: List.from(selectedDays),
                    category: _selectedCategory,
                    notificationEnabled: _notificationEnabled,
                    notificationDays: _notificationDays,
                    notificationDate: _notificationDate,
                    notificationHour: _notificationTime.hour,
                    notificationMinute: _notificationTime.minute,
                    shareCompletion: _shareCompletion,
                    carryOverIfIncomplete: _carryOverIfIncomplete,
                    priority: _priority,
                    endDate: null,
                    deadlineWeekOffset: _deadlineWeekOffset,
                    deadlineWeekday: _deadlineWeekday,
                    carryOverDays: null,
                    subtasks: _subtasks,
                  );

                  widget.onAddHabit(habit);
                  Navigator.pop(context);
                },
                child: const Text("保存", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //ジャンル選択ボタン
  Widget _categoryChip(String category) {
    final selected = _selectedCategory == category;
    final hovered = _hoveredCategory == category;
    final categoryColor = category == '未設定'
        ? const Color(0xff526FC5)
        : Color(
            _categoryColors[category] ??
                _categoryPalette.first.toARGB32(),
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hoveredCategory = category;
        });
      },
      onExit: (_) {
        setState(() {
          if (_hoveredCategory == category) {
            _hoveredCategory = null;
          }
        });
      },
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        showCheckmark: false,
        selectedColor: categoryColor,
        backgroundColor: hovered
            ? categoryColor.withValues(alpha: 0.28)
            : categoryColor.withValues(alpha: 0.12),
        side: BorderSide(
          color: selected || hovered
              ? categoryColor
              : categoryColor.withValues(alpha: 0.35),
          width: selected || hovered ? 1.8 : 1,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xff35415F),
          fontWeight:
              selected || hovered ? FontWeight.w600 : FontWeight.normal,
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
