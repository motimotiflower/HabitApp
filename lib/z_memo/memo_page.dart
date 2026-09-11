//メモを表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/z_memo/memo_storage.dart';
import 'package:habitapp/z_memo/sheets/memo_sheet.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => MemoPageState();
}

class MemoPageState extends State<MemoPage> {
  List<Memo> memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  //保存データを読み込む
  Future<void> _loadMemos() async {
    final loadedMemos = await MemoStorage.loadMemos();

    if (!mounted) return;

    setState(() {
      memos = loadedMemos;
      _sortMemos();
    });
  }

  //新しい順に並べる
  void _sortMemos() {
    memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  //メモを追加
  void addMemo(Memo memo) {
    setState(() {
      memos.add(memo);
      _sortMemos();
    });

    MemoStorage.saveMemos(memos);
  }

  //メモを編集
  void _editMemo(Memo oldMemo, Memo newMemo) {
    final index = memos.indexOf(oldMemo);
    if (index == -1) return;

    setState(() {
      memos[index] = newMemo;
      _sortMemos();
    });

    MemoStorage.saveMemos(memos);
  }

  //メモを削除
  void _deleteMemo(Memo memo) {
    setState(() {
      memos.remove(memo);
    });

    MemoStorage.saveMemos(memos);
  }

  //編集画面
  void _showEditSheet(Memo memo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: MemoSheet(
            memo: memo,
            onSave: (editedMemo) {
              _editMemo(memo, editedMemo);
            },
          ),
        );
      },
    );
  }

  //削除確認
  void _showDeleteDialog(Memo memo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('メモを削除'),
          content: Text('「${memo.title}」を削除しますか？'),
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
                        Navigator.pop(context);
                        _deleteMemo(memo);
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
                        Navigator.pop(context);
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
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return MainContent(
      overlap: 10,
      child: memos.isEmpty
          ? const Center(
              child: Text(
                'メモはまだありません',
                style: TextStyle(color: Color(0xff81889B)),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _showEditSheet(memo);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F4FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xffCDD5F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.edit_note_outlined,
                          color: Color(0xff526FC5),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      memo.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff35415F),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(memo.updatedAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xff81889B),
                                    ),
                                  ),
                                ],
                              ),

                              if (memo.content.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  memo.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff616A80),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip: '削除',
                          color: const Color(0xff526FC5),
                          icon: const Icon(Icons.delete_outline, size: 19),
                          onPressed: () {
                            _showDeleteDialog(memo);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
