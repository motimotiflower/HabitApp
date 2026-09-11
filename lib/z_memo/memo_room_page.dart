//Discordのチャンネルのようにメモを壁打ちする画面
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/z_memo/memo_composer_page.dart';
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

  @override
  void initState() {
    super.initState();
    _memo = widget.memo;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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
        backgroundColor: const Color(0xffF7F9FF),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          _memo.title,
          style: const TextStyle(
            color: Color(0xff35415F),
            fontSize: 18,
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

                            //Discordのように背景へ直接投稿を並べる
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 4,
                                bottom: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Color(0xffE8EDFC),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: Color(0xff526FC5),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              '自分',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff35415F),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatTime(message.createdAt),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xff9AA2B6),
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (message.content.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            message.content,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.45,
                                              color: Color(0xff35415F),
                                            ),
                                          ),
                                        ],

                                        if (message.imageBase64 != null) ...[
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
