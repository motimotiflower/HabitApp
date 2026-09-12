//タスク編集画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/category_storage.dart';
import 'package:habitapp/notifications/notification_settings_card.dart';

class EditTaskSheet extends StatefulWidget {
  const EditTaskSheet({
    super.key,
    required this.task,
    required this.onSave,
  });

  final Task task;
  final void Function(Task task) onSave;

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _deadline;
  late bool _isFlagged;
  late bool _notificationEnabled;
  late List<String> _notificationDays;
  DateTime? _notificationDate;
  late TimeOfDay _notificationTime;
  List<String> _categories = [];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _deadline = widget.task.deadline;
    _selectedCategory = widget.task.category;
    _isFlagged = widget.task.isFlagged;
    _notificationEnabled = widget.task.notificationEnabled;
    _notificationDays = [...widget.task.notificationDays];
    _notificationDate = widget.task.notificationDate;
    _notificationTime = TimeOfDay(
      hour: widget.task.notificationHour ?? 9,
      minute: widget.task.notificationMinute ?? 0,
    );

    _loadCategories();
  }

  //保存されているジャンルを読み込む
  Future<void> _loadCategories() async {
    final categories = await CategoryStorage.loadCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;

      //古いデータのジャンルも選べるように残す
      if (_selectedCategory != '未設定' &&
          !_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
    });
  }

  //締切日を選ぶ
  Future<void> _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    setState(() {
      _deadline = selectedDate;
    });
  }

    //編集内容を保存する
  void _saveTask() {
    final title = _titleController.text.trim();

    if (title.isEmpty) return;

    if (_notificationEnabled &&
        _notificationDate == null &&
        _notificationDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('通知する曜日か日にちを選んでください')),
      );
      return;
    }

    widget.onSave(
      Task(
        id: widget.task.id,
        title: title,
        description: _descriptionController.text.trim(),
        deadline: _deadline,
        category: _selectedCategory,
        isFlagged: _isFlagged,
        notificationEnabled: _notificationEnabled,
        notificationDays: _notificationDays,
        notificationDate: _notificationDate,
        notificationHour: _notificationTime.hour,
        notificationMinute: _notificationTime.minute,
        isDone: widget.task.isDone,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF4F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'タスクを編集',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //タスク名
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'タスク名',
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

                      TextField(
                        controller: _descriptionController,
                        minLines: 6,
                        maxLines: 12,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          labelText: '詳細',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //締切日
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Color(0xff526FC5),
                        ),
                        title: Text(
                          _deadline == null
                              ? '締切日を選択'
                              : '${_deadline!.year}年${_deadline!.month}月${_deadline!.day}日',
                        ),
                        trailing: _deadline == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _deadline = null;
                                  });
                                },
                              ),
                        onTap: _selectDeadline,
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.flag_outlined,
                          color: Color(0xff526FC5),
                        ),
                        title: const Text('フラグ'),
                        subtitle: const Text('Homeに優先表示します'),
                        value: _isFlagged,
                        onChanged: (value) {
                          setState(() {
                            _isFlagged = value;
                          });
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

                      const SizedBox(height: 16),

                      const Text(
                        'ジャンル',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xff35415F),
                        ),
                      ),

                      const SizedBox(height: 8),

                      //作成済みジャンルから丸いボタンで選ぶ
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('未設定'),
                          ..._categories.map(_buildCategoryChip),
                        ],
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
                  onPressed: _saveTask,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //ジャンル選択ボタン
  Widget _buildCategoryChip(String category) {
    final selected = _selectedCategory == category;

    return ChoiceChip(
      label: Text(category),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xff526FC5),
      backgroundColor: const Color(0xffE8EDFC),
      side: const BorderSide(color: Color(0xffCDD5F0)),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xff4763B4),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
    _descriptionController.dispose();
    super.dispose();
  }
}
