//習慣編集画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';

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
  late IconData _selectedIcon;

  List<String> _categories = [];

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

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await HabitCategoryStorage.loadCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;

      if (_selectedCategory != '未設定' &&
          !_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
    });
  }

  void _saveHabit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onSave(
      Habit(
        title: title,
        icon: _selectedIcon,
        days: _selectedDays,
        category: _selectedCategory,

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
                        decoration: const InputDecoration(
                          labelText: 'タイトル',
                          border: OutlineInputBorder(),
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

                          return ChoiceChip(
                            label: Text(day),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: const Color(0xff526FC5),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xff36498C),
                            ),
                            onSelected: (_) {
                              setState(() {
                                if (selected) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                              });
                            },
                          );
                        }).toList(),
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

    return ChoiceChip(
      label: Text(category),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xff526FC5),
      backgroundColor: const Color(0xffE8EDFC),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xff4763B4),
      ),
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
