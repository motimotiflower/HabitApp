//アプリ設定画面
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
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
  List<TimeOfDay> _batchTimes = const [
    TimeOfDay(hour: 21, minute: 0),
  ];

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
      _batchTimes = notification.batchTimes.map((value) {
        final parts = value.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts.first) ?? 21,
          minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
        );
      }).toList();
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

  Future<void> _addBatchTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _batchTimes.isEmpty
          ? const TimeOfDay(hour: 21, minute: 0)
          : _batchTimes.last,
    );

    if (selected == null) return;

    final alreadyExists = _batchTimes.any(
      (time) =>
          time.hour == selected.hour &&
          time.minute == selected.minute,
    );

    if (alreadyExists) return;

    setState(() {
      _batchTimes = [..._batchTimes, selected]
        ..sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(
              b.hour * 60 + b.minute,
            ));
    });
  }

  void _removeBatchTime(int index) {
    setState(() {
      _batchTimes = [..._batchTimes]..removeAt(index);
    });
  }

  Future<void> _saveNotificationSettings() async {
    if (_notificationMode == GlobalNotificationMode.batch &&
        _batchTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('まとめ通知の時刻を1つ以上設定してください'),
        ),
      );
      return;
    }

    final settings = GlobalNotificationSettings(
      mode: _notificationMode,
      batchTimes: _batchTimes.map((time) {
        final hour = time.hour.toString().padLeft(2, '0');
        final minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }).toList(),
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
        //各詳細ページで上下の余白をそろえる
        toolbarHeight: MainBackground.detailToolbarHeight,
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
                        const SizedBox(height: 10),

                        ...List.generate(
                          _batchTimes.length,
                          (index) {
                            final time = _batchTimes[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffF3F6FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xffDCE3F5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    color: Color(0xff526FC5),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      time.format(context),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff35415F),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '削除',
                                    onPressed: () =>
                                        _removeBatchTime(index),
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _addBatchTime,
                            icon: const Icon(Icons.add),
                            label: const Text('時刻を追加'),
                          ),
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
