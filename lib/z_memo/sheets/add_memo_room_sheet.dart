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

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onAdd(
      Memo(
        title: title,
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

              //部屋名だけを決める
              TextField(
                controller: _titleController,
                autofocus: true,
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
