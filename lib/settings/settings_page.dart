//アプリ設定画面
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitapp/debug/debug_seed_service.dart';
import 'package:habitapp/notifications/notification_preference_storage.dart';
import 'package:habitapp/notifications/notification_service.dart';
import 'package:habitapp/user/user_profile_storage.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();

  bool _loading = true;
  GlobalNotificationMode _notificationMode =
      GlobalNotificationMode.normal;
  TimeOfDay _batchTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await UserProfileStorage.loadName();
    final notification = await NotificationPreferenceStorage.load();

    _nameController.text = name ?? '';

    if (!mounted) return;

    setState(() {
      _notificationMode = notification.mode;
      _batchTime = TimeOfDay(
        hour: notification.batchHour,
        minute: notification.batchMinute,
      );
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await UserProfileStorage.saveName(name);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィールを保存しました')),
    );
  }

  Future<void> _pickBatchTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _batchTime,
    );

    if (selected == null) return;

    setState(() {
      _batchTime = selected;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final settings = GlobalNotificationSettings(
      mode: _notificationMode,
      batchHour: _batchTime.hour,
      batchMinute: _batchTime.minute,
    );

    await NotificationPreferenceStorage.save(settings);

    //全体設定を変更したら、保存済み通知を作り直す
    await NotificationService.syncAll(
      await HabitStorage.loadHabits(),
      await TaskStorage.loadTasks(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定を保存しました')),
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
                _SettingsSection(
                  title: 'プロフィール',
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '名前',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff526FC5),
                          ),
                          onPressed: _saveName,
                          child: const Text('プロフィールを保存'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _SettingsSection(
                  title: '通知',
                  child: Column(
                    children: [
                      RadioListTile<GlobalNotificationMode>(
                        value: GlobalNotificationMode.normal,
                        groupValue: _notificationMode,
                        title: const Text('個別に通知する'),
                        subtitle: const Text(
                          '習慣・タスクで設定した時刻に通知します',
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _notificationMode = value;
                          });
                        },
                      ),
                      RadioListTile<GlobalNotificationMode>(
                        value: GlobalNotificationMode.off,
                        groupValue: _notificationMode,
                        title: const Text('通知をしない'),
                        subtitle: const Text(
                          'すべての習慣・タスク通知を停止します',
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _notificationMode = value;
                          });
                        },
                      ),
                      RadioListTile<GlobalNotificationMode>(
                        value: GlobalNotificationMode.batch,
                        groupValue: _notificationMode,
                        title: const Text('通知をまとめて送る'),
                        subtitle: const Text(
                          '各項目の通知時刻は無視して、まとめた時刻に送ります',
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _notificationMode = value;
                          });
                        },
                      ),

                      if (_notificationMode ==
                          GlobalNotificationMode.batch) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: const Icon(
                            Icons.schedule,
                            color: Color(0xff526FC5),
                          ),
                          title: const Text('まとめて送る時刻'),
                          trailing: Text(
                            _batchTime.format(context),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff35415F),
                            ),
                          ),
                          onTap: _pickBatchTime,
                        ),
                      ],

                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff526FC5),
                          ),
                          onPressed: _saveNotificationSettings,
                          child: const Text('通知設定を保存'),
                        ),
                      ),
                    ],
                  ),
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  _SettingsSection(
                    title: 'デバッグ',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await DebugSeedService.addSampleData();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('確認用データを追加しました'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('確認用データを追加'),
                      ),
                    ),
                  ),
                ],
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffE1E6F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff35415F),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
