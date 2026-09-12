//Discordのチャンネルのようにメモを壁打ちする画面
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/z_memo/memo_composer_page.dart';
import 'package:habitapp/user/user_profile_storage.dart';
import 'package:image_picker/image_picker.dart';

class MemoRoomPage extends StatefulWidget {
  const MemoRoomPage({
    super.key,
    required this.memo,
    required this.onChanged,
  });

  final Memo memo;
  final void Function(Memo memo) onChanged;

  @override
  State<MemoRoomPage> createState() => _MemoRoomPageState();
}

class _MemoRoomPageState extends State<MemoRoomPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Memo _memo;
  String? _imageBase64;
  String _userName = 'ユーザー';
  int? _selectedMessageIndex;

  @override
  void initState() {
    super.initState();
    _memo = widget.memo;
    _loadUserName();

    //Webではブラウザ標準の右クリックメニューを出さない
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  //保存してある名前を読み込む
  Future<void> _loadUserName() async {
    final name = await UserProfileStorage.loadName();

    if (!mounted || name == null) return;

    setState(() {
      _userName = name;
    });
  }

  //画像を1枚選ぶ
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _imageBase64 = base64Encode(bytes);
    });
  }

  //短文をそのまま投稿
  void _sendInline() {
    final content = _controller.text.trim();

    if (content.isEmpty && _imageBase64 == null) return;

    _addMessage(
      MemoMessage(
        content: content,
        createdAt: DateTime.now(),
        imageBase64: _imageBase64,
      ),
    );

    _controller.clear();

    setState(() {
      _imageBase64 = null;
    });
  }

  //投稿を追加して部屋の更新日時も変える
  void _addMessage(MemoMessage message) {
    final updated = Memo(
      title: _memo.title,
      updatedAt: DateTime.now(),
      isPinned: _memo.isPinned,
      messages: [..._memo.messages, message],
    );

    setState(() {
      _memo = updated;
    });

    widget.onChanged(updated);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  //投稿本文を編集する
  Future<void> _editMessage(int index) async {
    final message = _memo.messages[index];
    final controller = TextEditingController(text: message.content);

    final editedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('メモを編集'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'メモを入力',
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
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (editedText == null) return;

    //画像だけの投稿は空文字のままでも残せる
    if (editedText.isEmpty && message.imageBase64 == null) return;

    final updatedMessages = [..._memo.messages];
    updatedMessages[index] = MemoMessage(
      content: editedText,
      createdAt: message.createdAt,
      imageBase64: message.imageBase64,
    );

    final updatedMemo = Memo(
      title: _memo.title,
      updatedAt: DateTime.now(),
      isPinned: _memo.isPinned,
      messages: updatedMessages,
    );

    setState(() {
      _memo = updatedMemo;
    });

    widget.onChanged(updatedMemo);
  }

  //投稿を削除する
  Future<void> _deleteMessage(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('メモを削除'),
          content: const Text('このメモを削除しますか？'),
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

    final updatedMessages = [..._memo.messages]..removeAt(index);

    final updatedMemo = Memo(
      title: _memo.title,
      updatedAt: DateTime.now(),
      isPinned: _memo.isPinned,
      messages: updatedMessages,
    );

    setState(() {
      _memo = updatedMemo;
    });

    widget.onChanged(updatedMemo);
  }

  //長押し・右クリックから編集と削除を選ぶ
  Future<void> _showMessageMenu(int index, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    setState(() {
      _selectedMessageIndex = index;
    });

    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('編集'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('削除'),
            ],
          ),
        ),
      ],
    );

    if (mounted) {
      setState(() {
        _selectedMessageIndex = null;
      });
    }

    if (value == 'edit') {
      _editMessage(index);
    } else if (value == 'delete') {
      _deleteMessage(index);
    }
  }

  //長文用の全画面入力
  Future<void> _openComposer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return MemoComposerPage(
            onSubmit: _addMessage,
          );
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  //画像を大きく表示
  void _showImage(String imageBase64) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                base64Decode(imageBase64),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        //部屋名の場所を青くして、本文との境目を分かりやすくする
        backgroundColor: const Color(0xff526FC5),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          _memo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //投稿一覧
            Expanded(
              child: _memo.messages.isEmpty
                  ? const Center(
                      child: Text(
                        '思いついたことをここに残してみよう',
                        style: TextStyle(
                          color: Color(0xff81889B),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      itemCount: _memo.messages.length,
                      itemBuilder: (context, index) {
                        final message = _memo.messages[index];

                        final showDate = index == 0 ||
                            _formatDate(
                                  _memo.messages[index - 1].createdAt,
                                ) !=
                                _formatDate(message.createdAt);

                        //前の投稿から5分以内なら同じ投稿のまとまりとして扱う
                        final isContinuous = index > 0 &&
                            !showDate &&
                            message.createdAt
                                    .difference(
                                      _memo.messages[index - 1].createdAt,
                                    )
                                    .inMinutes <
                                5;

                        //次も連投なら、この投稿の下余白も詰める
                        final nextIsContinuous =
                            index < _memo.messages.length - 1 &&
                            _formatDate(
                                  _memo.messages[index + 1].createdAt,
                                ) ==
                                _formatDate(message.createdAt) &&
                            _memo.messages[index + 1].createdAt
                                    .difference(message.createdAt)
                                    .inMinutes <
                                5;

                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xffDCE3F5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        _formatDate(message.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff81889B),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xffDCE3F5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            //Discordのように各投稿から編集・削除できる
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  //連続投稿なら間隔を小さくする
                                  bottom: nextIsContinuous ? 2 : 16,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  //スマホは長押し、Webは右クリックで投稿メニューを開く
                                  onLongPressStart: (details) {
                                    _showMessageMenu(
                                      index,
                                      details.globalPosition,
                                    );
                                  },
                                  onSecondaryTapDown: (details) {
                                    _showMessageMenu(
                                      index,
                                      details.globalPosition,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedMessageIndex == index
                                          ? const Color(0xffE8EDFC)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    //連続投稿ではアイコンを表示しない
                                    SizedBox(
                                      width: 42,
                                      child: !isContinuous
                                          ? const CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  Color(0xffE8EDFC),
                                              child: Icon(
                                                Icons.person_rounded,
                                                size: 21,
                                                color: Color(0xff526FC5),
                                              ),
                                            )
                                          : null,
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //まとまりの最初だけ名前と時刻を表示
                                          if (!isContinuous) ...[
                                            Row(
                                              children: [
                                                Text(
                                                  _userName,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color:
                                                        Color(0xff35415F),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _formatTime(
                                                    message.createdAt,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Color(0xff9AA2B6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            //名前・時刻と本文が詰まらないよう少し広めに空ける
                                            const SizedBox(height: 8),
                                          ],

                                          if (message.content.isNotEmpty)
                                            Text(
                                              message.content,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                height: 1.55,
                                                color: Color(0xff35415F),
                                              ),
                                            ),

                                          if (message.imageBase64 != null) ...[
                                            if (message.content.isNotEmpty)
                                              const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () {
                                                _showImage(
                                                  message.imageBase64!,
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.memory(
                                                  base64Decode(
                                                    message.imageBase64!,
                                                  ),
                                                  width: 280,
                                                  height: 210,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),


                                  ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            //画像を添付した時のプレビュー
            if (_imageBase64 != null)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                color: Colors.white,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(_imageBase64!),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _imageBase64 = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('画像を外す'),
                    ),
                  ],
                ),
              ),

            //インライン入力
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xffE0E6F5),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: '画像を追加',
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xff526FC5),
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'メモを追加...',
                        filled: true,
                        fillColor: const Color(0xffF2F4FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: '大きく書く',
                    onPressed: _openComposer,
                    icon: const Icon(
                      Icons.open_in_full,
                      color: Color(0xff81889B),
                    ),
                  ),

                  IconButton.filled(
                    tooltip: '送信',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xff526FC5),
                    ),
                    onPressed: _sendInline,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }

    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
