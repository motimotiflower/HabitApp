//初回だけ表示する名前設定画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/main_page.dart';
import 'package:habitapp/user/user_profile_storage.dart';

class UserSetupPage extends StatefulWidget {
  const UserSetupPage({super.key});

  @override
  State<UserSetupPage> createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await UserProfileStorage.saveName(name);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //仮アイコン。あとで画像設定に差し替えられる
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Color(0xffE8EDFC),
                    child: Icon(
                      Icons.person_rounded,
                      size: 46,
                      color: Color(0xff526FC5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'はじめまして',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff263A70),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'メモなどに表示する名前を設定してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff81889B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: InputDecoration(
                      labelText: '名前',
                      hintText: '例：さやか',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'はじめる',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
