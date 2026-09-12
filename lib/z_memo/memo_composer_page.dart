//長文を書くための全画面メモ入力
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/memo.dart';
import 'package:image_picker/image_picker.dart';

class MemoComposerPage extends StatefulWidget {
  const MemoComposerPage({
    super.key,
    required this.onSubmit,
  });

  final void Function(MemoMessage message) onSubmit;

  @override
  State<MemoComposerPage> createState() => _MemoComposerPageState();
}

class _MemoComposerPageState extends State<MemoComposerPage> {
  final TextEditingController _controller = TextEditingController();
  String? _imageBase64;

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

  void _submit() {
    final content = _controller.text.trim();

    if (content.isEmpty && _imageBase64 == null) return;

    widget.onSubmit(
      MemoMessage(
        content: content,
        createdAt: DateTime.now(),
        imageBase64: _imageBase64,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      appBar: AppBar(
        //各詳細ページで上下の余白をそろえる
        toolbarHeight: MainBackground.detailToolbarHeight,
        backgroundColor: const Color(0xffF7F9FF),
        elevation: 0,
        leading: IconButton(
          tooltip: '戻る',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          '新しいメモ',
          style: TextStyle(
            color: Color(0xff35415F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              '追加',
              style: TextStyle(
                color: Color(0xff526FC5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.55,
                    color: Color(0xff35415F),
                  ),
                  decoration: const InputDecoration(
                    hintText: '今思いついたことを書く...',
                    border: InputBorder.none,
                  ),
                ),
              ),

              if (_imageBase64 != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        base64Decode(_imageBase64!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filled(
                        onPressed: () {
                          setState(() {
                            _imageBase64 = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: '画像を追加',
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xff526FC5),
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
    _controller.dispose();
    super.dispose();
  }
}
