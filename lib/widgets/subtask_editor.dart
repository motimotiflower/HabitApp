import 'package:flutter/material.dart';
import 'package:habitapp/models/subtask.dart';

//追加・編集画面で共通利用する簡単なサブタスク編集UI
class SubtaskEditor extends StatefulWidget {
  const SubtaskEditor({
    super.key,
    required this.subtasks,
    required this.onChanged,
  });

  final List<Subtask> subtasks;
  final ValueChanged<List<Subtask>> onChanged;

  @override
  State<SubtaskEditor> createState() => _SubtaskEditorState();
}

class _SubtaskEditorState extends State<SubtaskEditor> {
  final _controller = TextEditingController();

  void _add() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() {
      widget.subtasks.add(Subtask(title: title));
      _controller.clear();
    });
    widget.onChanged(List<Subtask>.from(widget.subtasks));
  }

  void _remove(int index) {
    setState(() => widget.subtasks.removeAt(index));
    widget.onChanged(List<Subtask>.from(widget.subtasks));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'サブタスク',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < widget.subtasks.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.subdirectory_arrow_right, size: 18),
            title: Text(widget.subtasks[i].title),
            trailing: IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _remove(i),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'サブタスクを追加',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: '追加',
              onPressed: _add,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
