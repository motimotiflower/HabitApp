//習慣ジャンルの名前・色を管理する画面
import 'package:flutter/material.dart';

class HabitCategoryManageSheet extends StatelessWidget {
  const HabitCategoryManageSheet({
    super.key,
    required this.categories,
    required this.colors,
    required this.onAdd,
    required this.onRename,
    required this.onDelete,
    required this.onColorChanged,
  });

  static const palette = [
    Color(0xff32448C),
    Color(0xff6880D0),
    Color(0xff8B8DD3),
    Color(0xffB4BFE9),
    Color(0xffBEBDE4),
    Color(0xffEBD3E4),
    Color(0xffF3E4DC),
  ];

  final List<String> categories;
  final Map<String, int> colors;
  final Future<void> Function(String name, int color) onAdd;
  final Future<void> Function(String oldName, String newName) onRename;
  final Future<void> Function(String category) onDelete;
  final Future<void> Function(String category, int color) onColorChanged;

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    Color selectedColor = palette.first;

    final result = await showDialog<(String, Color)>(
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
                    children: palette.map((color) {
                      final selected = selectedColor == color;
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
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
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(dialogContext, (name, selectedColor));
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
    if (result == null) return;
    await onAdd(result.$1, result.$2.toARGB32());
  }

  Future<void> _rename(BuildContext context, String category) async {
    final controller = TextEditingController(text: category);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ジャンル名を変更'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'ジャンル名',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(dialogContext, value);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (name == null || name == category) return;
    await onRename(category, name);
  }

  Future<void> _pickColor(BuildContext context, String category) async {
    var selectedColor = Color(
      colors[category] ?? palette.first.toARGB32(),
    );

    final result = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('$category の色'),
              content: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: palette.map((color) {
                  final selected = selectedColor.toARGB32() == color.toARGB32();

                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    selectedColor,
                  ),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await onColorChanged(category, result.toARGB32());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF7F9FF),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ジャンル管理',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff263A70),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: Text(
                        'ジャンルはまだありません',
                        style: TextStyle(color: Color(0xff81889B)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final color = Color(
                          colors[category] ?? palette.first.toARGB32(),
                        );

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _pickColor(context, category),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child: const Icon(
                                Icons.palette_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          title: Text(
                            category,
                            style: const TextStyle(fontSize: 17),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: '色を変更',
                                onPressed: () =>
                                    _pickColor(context, category),
                                icon: const Icon(Icons.palette_outlined),
                              ),
                              IconButton(
                                tooltip: '名前を変更',
                                onPressed: () =>
                                    _rename(context, category),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: '削除',
                                onPressed: () => onDelete(category),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
