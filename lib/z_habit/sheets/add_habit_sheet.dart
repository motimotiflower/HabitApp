import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key, required this.onAddHabit});

  final void Function(Habit) onAddHabit;

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
  IconData _selectedIcon = Icons.check;

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
                  onPressed: () {
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
                    const SizedBox(height: 16),

                    const Text("タイトル", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),

                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '習慣を入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
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

                    const SizedBox(height: 18),

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

                    if (_selectedCategory != '未設定') ...[
                      const SizedBox(height: 12),
                      const Text(
                        'ジャンルカラー',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff697188),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _categoryPalette.map((color) {
                          final selectedValue =
                              _categoryColors[_selectedCategory] ??
                                  _categoryPalette.first.toARGB32();
                          final selected =
                              selectedValue == color.toARGB32();

                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                _categoryColors[_selectedCategory] =
                                    color.toARGB32();
                              });

                              await HabitCategoryStorage.saveCategoryColors(
                                _categoryColors,
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
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

                  final habit = Habit(
                    title: titleController.text.trim(),
                    icon: _selectedIcon,
                    days: List.from(selectedDays),
                    category: _selectedCategory,
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
    final categoryColor = category == '未設定'
        ? const Color(0xff526FC5)
        : Color(
            _categoryColors[category] ??
                _categoryPalette.first.toARGB32(),
          );

    return ChoiceChip(
      label: Text(category),
      selected: selected,
      showCheckmark: false,
      selectedColor: categoryColor,
      backgroundColor: categoryColor.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? Colors.white : categoryColor,
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
    titleController.dispose();
    super.dispose();
  }
}
