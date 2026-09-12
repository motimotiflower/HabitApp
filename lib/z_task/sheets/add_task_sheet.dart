//タスク追加画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/category_storage.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, required this.onAddTask});

  final void Function(Task task) onAddTask;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();

  DateTime? _deadline;
  bool _isFlagged = false;
  bool _notificationEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  List<String> _categories = [];
  String _selectedCategory = '未設定';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  //保存されているジャンルを読み込む
  Future<void> _loadCategories() async {
    final categories = await CategoryStorage.loadCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;
    });
  }

  //締切日を選ぶ
  Future<void> _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    setState(() {
      _deadline = selectedDate;
    });
  }

  //通知時刻を選ぶ
  Future<void> _selectNotificationTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (selected == null) return;

    setState(() {
      _notificationTime = selected;
    });
  }

  //タスクを追加する
  void _addTask() {
    final title = _titleController.text.trim();

    if (title.isEmpty) return;

    widget.onAddTask(
      Task(
        title: title,
        deadline: _deadline,
        category: _selectedCategory,
        isFlagged: _isFlagged,
        notificationEnabled:
            _notificationEnabled && _deadline != null,
        notificationHour: _notificationTime.hour,
        notificationMinute: _notificationTime.minute,
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
                'タスクを追加',
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
                        decoration: const InputDecoration(
                          labelText: 'タスク名',
                          border: OutlineInputBorder(),
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

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xff526FC5),
                        ),
                        title: const Text('通知'),
                        subtitle: Text(
                          _deadline == null
                              ? '締切日を設定すると通知できます'
                              : '締切日の指定時刻に通知します',
                        ),
                        value: _notificationEnabled,
                        onChanged: _deadline == null
                            ? null
                            : (value) {
                                setState(() {
                                  _notificationEnabled = value;
                                });
                              },
                      ),

                      if (_notificationEnabled && _deadline != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.schedule,
                            color: Color(0xff526FC5),
                          ),
                          title: const Text('通知時刻'),
                          trailing: Text(
                            _notificationTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: _selectNotificationTime,
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

                      if (_categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'ジャンルはタスク画面の＋から作成できます',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff81889B),
                            ),
                          ),
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
                  onPressed: _addTask,
                  child: const Text('追加'),
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
    super.dispose();
  }
}
