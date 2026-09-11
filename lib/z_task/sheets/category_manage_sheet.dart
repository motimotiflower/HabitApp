//タスクジャンルを追加・編集・削除する画面
import 'package:flutter/material.dart';

class CategoryManageSheet extends StatefulWidget {
  const CategoryManageSheet({
    super.key,
    required this.categories,
    required this.onAdd,
    required this.onRename,
    required this.onDelete,
  });

  final List<String> categories;
  final Future<void> Function(String category) onAdd;
  final Future<void> Function(String oldName, String newName) onRename;
  final Future<void> Function(String category) onDelete;

  @override
  State<CategoryManageSheet> createState() => _CategoryManageSheetState();
}

class _CategoryManageSheetState extends State<CategoryManageSheet> {
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [...widget.categories];
  }

  //名前入力ダイアログ
  Future<String?> _showNameDialog({
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff526FC5),
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(dialogContext, name);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  //ジャンル追加
  Future<void> _addCategory() async {
    final name = await _showNameDialog(title: 'ジャンルを追加');
    if (name == null) return;

    if (_categories.contains(name)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('同じ名前のジャンルがあります')),
      );
      return;
    }

    await widget.onAdd(name);

    if (!mounted) return;

    setState(() {
      _categories.add(name);
      _categories.sort();
    });
  }

  //ジャンル名変更
  Future<void> _renameCategory(String oldName) async {
    final newName = await _showNameDialog(
      title: 'ジャンル名を変更',
      initialValue: oldName,
    );

    if (newName == null || newName == oldName) return;

    if (_categories.contains(newName)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('同じ名前のジャンルがあります')),
      );
      return;
    }

    await widget.onRename(oldName, newName);

    if (!mounted) return;

    setState(() {
      final index = _categories.indexOf(oldName);
      if (index != -1) {
        _categories[index] = newName;
        _categories.sort();
      }
    });
  }

  //ジャンル削除
  Future<void> _deleteCategory(String category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ジャンルを削除'),
          content: Text(
            '「$category」を削除しますか？\n'
            'このジャンルのタスクは「未設定」になります。',
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text('削除'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text('キャンセル'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await widget.onDelete(category);

    if (!mounted) return;

    setState(() {
      _categories.remove(category);
    });
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              //タイトル
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ジャンル管理',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff263A70),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff526FC5),
                    ),
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add),
                    label: const Text('追加'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //ジャンル一覧
              Expanded(
                child: _categories.isEmpty
                    ? const Center(
                        child: Text(
                          'ジャンルはまだありません',
                          style: TextStyle(color: Color(0xff81889B)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xffD5DDF4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.folder_outlined,
                                  color: Color(0xff526FC5),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xff35415F),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: '名前を変更',
                                  color: const Color(0xff526FC5),
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    _renameCategory(category);
                                  },
                                ),
                                IconButton(
                                  tooltip: '削除',
                                  color: const Color(0xff526FC5),
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    _deleteCategory(category);
                                  },
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
      ),
    );
  }
}
