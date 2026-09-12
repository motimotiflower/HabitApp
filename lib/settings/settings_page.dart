//アプリ設定画面
import 'package:flutter/material.dart';
import 'package:habitapp/user/user_profile_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await UserProfileStorage.loadName();
    _nameController.text = name ?? '';

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await UserProfileStorage.saveName(name);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('名前を変更しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff526FC5),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('設定'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'プロフィール',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff35415F),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '名前',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff526FC5),
                    ),
                    onPressed: _saveName,
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
