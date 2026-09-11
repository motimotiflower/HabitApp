//メモの追加・編集画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/memo.dart';

class MemoSheet extends StatefulWidget {
  const MemoSheet({
    super.key,
    this.memo,
    required this.onSave,
  });

  //編集時だけ既存メモを受け取る
  final Memo? memo;
  final void Function(Memo memo) onSave;

  @override
  State<MemoSheet> createState() => _MemoSheetState();
}

class _MemoSheetState extends State<MemoSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.memo?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.memo?.content ?? '',
    );
  }

  //メモを保存する
  void _saveMemo() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    //タイトルも本文も空なら保存しない
    if (title.isEmpty && content.isEmpty) return;

    widget.onSave(
      Memo(
        title: title.isEmpty ? '無題のメモ' : title,
        content: content,
        updatedAt: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memo != null;

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
              Text(
                isEditing ? 'メモを編集' : 'メモを追加',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),
              const SizedBox(height: 20),

              //タイトル
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              //本文
              Expanded(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: '本文',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
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
                  onPressed: _saveMemo,
                  child: Text(isEditing ? '保存' : '追加'),
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
    _contentController.dispose();
    super.dispose();
  }
}
