//LINEのトーク作成のようなメモ部屋追加画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/memo.dart';

class AddMemoRoomSheet extends StatefulWidget {
  const AddMemoRoomSheet({
    super.key,
    required this.onAdd,
  });

  final void Function(Memo memo) onAdd;

  @override
  State<AddMemoRoomSheet> createState() => _AddMemoRoomSheetState();
}

class _AddMemoRoomSheetState extends State<AddMemoRoomSheet> {
  final TextEditingController _titleController = TextEditingController();

  String _selectedType = 'メモ';

  static const _types = [
    'メモ',
    'アイデア',
    '大学',
    '制作',
    'その他',
  ];

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onAdd(
      Memo(
        title: title,
        type: _selectedType,
        updatedAt: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF7F9FF),
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
                'メモ部屋を作成',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                '種類',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff35415F),
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((type) {
                  final selected = _selectedType == type;

                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xff526FC5),
                    backgroundColor: const Color(0xffE8EDFC),
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xff4763B4),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  hintText: '例：HabitApp、ゲーム制作、大学',
                  border: OutlineInputBorder(),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff526FC5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _save,
                  child: const Text('作成'),
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
