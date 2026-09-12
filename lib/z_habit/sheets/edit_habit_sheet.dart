//習慣編集画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/notifications/notification_settings_card.dart';

class EditHabitSheet extends StatefulWidget {
  const EditHabitSheet({
    super.key,
    required this.habit,
    required this.onSave,
  });

  final Habit habit;
  final void Function(Habit habit) onSave;

  @override
  State<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends State<EditHabitSheet> {
  static const days = ["月", "火", "水", "木", "金", "土", "日"];

  late final TextEditingController _titleController;
  late List<String> _selectedDays;
  late String _selectedCategory;
  String? _hoveredCategory;
  late IconData _selectedIcon;
  late bool _notificationEnabled;
  late List<String> _notificationDays;
  DateTime? _notificationDate;
  late TimeOfDay _notificationTime;

  List<String> _categories = [];
  Map<String, int> _categoryColors = {};

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
    Icons.menu_book,
    Icons.water_drop,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.favorite,
    Icons.star,
    Icons.music_note,
    Icons.nightlight_round,
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.habit.title);
    _selectedDays = [...widget.habit.days];
    _selectedCategory = widget.habit.category;
    _selectedIcon = widget.habit.icon;
    _notificationEnabled = widget.habit.notificationEnabled;
    _notificationDays = [...widget.habit.notificationDays];
    _notificationDate = widget.habit.notificationDate;
    _notificationTime = TimeOfDay(
      hour: widget.habit.notificationHour ?? 9,
      minute: widget.habit.notificationMinute ?? 0,
    );

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await HabitCategoryStorage.loadCategories();
    final categoryColors = await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _categoryColors = categoryColors;

      if (_selectedCategory != '未設定' &&
          !_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
    });
  }

  void _saveHabit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    //曜日が1つも選ばれていない場合は保存しない
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('曜日を1つ以上選んでください'),
        ),
      );
      return;
    }

    if (_notificationEnabled &&
        _notificationDate == null &&
        _notificationDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('通知する曜日か日にちを選んでください'),
        ),
      );
      return;
    }

    widget.onSave(
      Habit(
        id: widget.habit.id,
        title: title,
        icon: _selectedIcon,
        days: _selectedDays,
        category: _selectedCategory,
        notificationEnabled: _notificationEnabled,
        notificationDays: _notificationDays,
        notificationDate: _notificationDate,
        notificationHour: _notificationTime.hour,
        notificationMinute: _notificationTime.minute,

        //編集しても達成履歴は残す
        completionHistory: Map<String, bool>.from(
          widget.habit.completionHistory,
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF4F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '習慣を編集',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'タイトル',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Text('曜日', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),

                      //毎日をまとめて選択・解除
                      ChoiceChip(
                        label: const Text('毎日'),
                        selected: _selectedDays.length == days.length,
                        showCheckmark: false,
                        selectedColor: const Color(0xff526FC5),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedDays.length == days.length
                              ? Colors.white
                              : const Color(0xff36498C),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (_selectedDays.length == days.length) {
                              _selectedDays.clear();
                            } else {
                              _selectedDays
                                ..clear()
                                ..addAll(days);
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: days.map((day) {
                          final selected = _selectedDays.contains(day);

                          return SizedBox(
                            width: 42,
                            height: 42,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xffC8D0E8),
                                ),
                                backgroundColor: selected
                                    ? const Color(0xff526FC5)
                                    : Colors.white,
                                foregroundColor: selected
                                    ? Colors.white
                                    : const Color(0xff36498C),
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (selected) {
                                    _selectedDays.remove(day);
                                  } else {
                                    _selectedDays.add(day);
                                  }
                                });
                              },
                              child: Text(day),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

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
                      const Text('ジャンル', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _categoryChip('未設定'),
                          ..._categories.map(_categoryChip),
                        ],
                      ),



                      const SizedBox(height: 18),
                      const Text('アイコン', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _icons.map((icon) {
                          final selected = _selectedIcon == icon;

                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff526FC5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveHabit,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    _titleController.dispose();
    super.dispose();
  }
}
