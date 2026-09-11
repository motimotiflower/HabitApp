//メモを表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
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
  String _searchText = '';

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

  //ピン留めを先頭、その中では新しい順
  void _sortMemos() {
    memos.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      return b.updatedAt.compareTo(a.updatedAt);
    });
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

  //ピン留め切り替え
  void _togglePin(Memo memo) {
    final index = memos.indexOf(memo);
    if (index == -1) return;

    final updatedMemo = Memo(
      title: memo.title,
      content: memo.content,
      updatedAt: memo.updatedAt,
      isPinned: !memo.isPinned,
    );

    setState(() {
      memos[index] = updatedMemo;
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

  //検索条件を反映
  List<Memo> _getVisibleMemos() {
    final keyword = _searchText.trim().toLowerCase();

    if (keyword.isEmpty) {
      return [...memos];
    }

    return memos.where((memo) {
      return memo.title.toLowerCase().contains(keyword) ||
          memo.content.toLowerCase().contains(keyword);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  //青いヘッダーに置く検索欄
  Widget _buildHeaderSearch(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * MainBackground.headerRatio * 0.50,
      left: 20,
      right: 20,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        style: const TextStyle(
          color: Color(0xff35415F),
        ),
        decoration: InputDecoration(
          hintText: 'メモを検索',
          hintStyle: const TextStyle(
            color: Color(0xff81889B),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xff526FC5),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.96),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleMemos = _getVisibleMemos();

    return Stack(
      children: [
        _buildHeaderSearch(context),

        MainContent(
          overlap: 10,
          child: visibleMemos.isEmpty
              ? Center(
                  child: Text(
                    memos.isEmpty
                        ? 'メモはまだありません'
                        : '一致するメモはありません',
                    style: const TextStyle(
                      color: Color(0xff81889B),
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    //スマホは2列、広い画面では3列
                    final crossAxisCount =
                        constraints.maxWidth > 900 ? 3 : 2;

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.12,
                      ),
                      itemCount: visibleMemos.length,
                      itemBuilder: (context, index) {
                        final memo = visibleMemos[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            _showEditSheet(memo);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffCDD5F0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        memo.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff35415F),
                                        ),
                                      ),
                                    ),

                                    IconButton(
                                      tooltip: memo.isPinned
                                          ? 'ピン留めを外す'
                                          : 'ピン留め',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: const Color(0xff526FC5),
                                      icon: Icon(
                                        memo.isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _togglePin(memo);
                                      },
                                    ),
                                  ],
                                ),

                                if (memo.content.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      memo.content,
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.35,
                                        color: Color(0xff616A80),
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Spacer(),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Text(
                                      _formatDate(memo.updatedAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff81889B),
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      tooltip: 'メニュー',
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        color: Color(0xff81889B),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _showDeleteDialog(memo);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('削除'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
