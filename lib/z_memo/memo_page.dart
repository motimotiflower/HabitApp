//メモ部屋の一覧画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/z_memo/memo_room_page.dart';
import 'package:habitapp/z_memo/memo_storage.dart';

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
    reloadMemos();
  }

  //保存データを読み込む
  Future<void> reloadMemos() async {
    final loadedMemos = await MemoStorage.loadMemos();

    if (!mounted) return;

    setState(() {
      memos = loadedMemos;
      _sortMemos();
    });
  }

  //ピン留めを先頭、その中では更新が新しい順
  void _sortMemos() {
    memos.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  //メモ部屋を追加
  void addMemo(Memo memo) {
    setState(() {
      memos.add(memo);
      _sortMemos();
    });

    MemoStorage.saveMemos(memos);
  }

  //部屋の内容を更新
  void _updateMemo(Memo oldMemo, Memo newMemo) {
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
    final updated = Memo(
      title: memo.title,
      updatedAt: memo.updatedAt,
      isPinned: !memo.isPinned,
      messages: memo.messages,
    );

    _updateMemo(memo, updated);
  }

  //部屋を削除
  void _deleteMemo(Memo memo) {
    setState(() {
      memos.remove(memo);
    });

    MemoStorage.saveMemos(memos);
  }

  //壁打ち画面を開く
  Future<void> _openRoom(Memo memo) async {
    Memo currentMemo = memo;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return MemoRoomPage(
            memo: memo,
            onChanged: (updatedMemo) {
              _updateMemo(currentMemo, updatedMemo);
              currentMemo = updatedMemo;
            },
          );
        },
      ),
    );
  }

  //削除確認
  void _showDeleteDialog(Memo memo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('メモ部屋を削除'),
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

    if (keyword.isEmpty) return [...memos];

    return memos.where((memo) {
      final messageText = memo.messages
          .map((message) => message.content)
          .join(' ')
          .toLowerCase();

      return memo.title.toLowerCase().contains(keyword) ||
          messageText.contains(keyword);
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
          hintText: 'メモ部屋を検索',
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
          overlap: 0,
          child: visibleMemos.isEmpty
              ? Center(
                  child: Text(
                    memos.isEmpty
                        ? 'メモ部屋はまだありません'
                        : '一致するメモはありません',
                    style: const TextStyle(
                      color: Color(0xff81889B),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: visibleMemos.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0xffE6EAF4),
                  ),
                  itemBuilder: (context, index) {
                    final memo = visibleMemos[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      onTap: () {
                        _openRoom(memo);
                      },
                      leading: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xffE8EDFC),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xff526FC5),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              memo.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              color: Color(0xff9AA2B6),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          memo.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff697188),
                          ),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          memo.isPinned
                              ? Icons.push_pin
                              : Icons.more_vert,
                          color: memo.isPinned
                              ? const Color(0xff526FC5)
                              : const Color(0xff81889B),
                        ),
                        onSelected: (value) {
                          if (value == 'pin') {
                            _togglePin(memo);
                          } else if (value == 'delete') {
                            _showDeleteDialog(memo);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Text(
                              memo.isPinned
                                  ? 'ピン留めを外す'
                                  : 'ピン留め',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('削除'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
