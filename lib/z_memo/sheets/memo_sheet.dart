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

    if (title.isEmpty && content.isEmpty) return;

    widget.onSave(
      Memo(
        title: title.isEmpty ? '無題のメモ' : title,
        content: content,
        updatedAt: DateTime.now(),
        isPinned: widget.memo?.isPinned ?? false,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memo != null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF7F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //上部はGoogle Keepのようにシンプルにする
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'メモを編集' : 'メモを追加',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff263A70),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveMemo,
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        color: Color(0xff526FC5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              //タイトルは枠なし
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff35415F),
                ),
                decoration: const InputDecoration(
                  hintText: 'タイトル',
                  hintStyle: TextStyle(
                    color: Color(0xff9AA2B6),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 4),

              //本文も枠なしでタイトルと自然につながる
              Expanded(
                child: TextField(
                  controller: _contentController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xff4B5368),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'メモを入力...',
                    hintStyle: TextStyle(
                      color: Color(0xff9AA2B6),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
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
