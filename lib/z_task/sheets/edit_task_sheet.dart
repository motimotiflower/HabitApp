//タスク編集画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_task/category_storage.dart';

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

  DateTime? _deadline;
  List<String> _categories = [];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _deadline = widget.task.deadline;
    _selectedCategory = widget.task.category;

    _loadCategories();
  }

  //保存されているジャンルを読み込む
  Future<void> _loadCategories() async {
    final categories = await CategoryStorage.loadCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;

      //古いデータのジャンルも選択肢から消さない
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

    widget.onSave(
      Task(
        title: title,
        deadline: _deadline,
        category: _selectedCategory,
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

                      const SizedBox(height: 16),

                      //作成済みジャンルから選択
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'ジャンル',
                          prefixIcon: Icon(
                            Icons.folder_outlined,
                            color: Color(0xff526FC5),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '未設定',
                            child: Text('未設定'),
                          ),
                          ..._categories.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCategory = value;
                          });
                        },
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
