//通知の曜日・日にち・時間をまとめて選ぶ共通UI
import 'package:flutter/material.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    super.key,
    required this.enabled,
    required this.days,
    required this.date,
    required this.time,
    required this.onEnabledChanged,
    required this.onDaysChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  static const _templateHours = [7, 9, 13, 19, 21];

  final bool enabled;
  final List<String> days;
  final DateTime? date;
  final TimeOfDay time;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<List<String>> onDaysChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      onDateChanged(selected);
    }
  }

  Future<void> _pickCustomTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (selected != null) {
      onTimeChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usesDate = date != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffDCE3F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.notifications_outlined,
              color: Color(0xff526FC5),
            ),
            title: const Text(
              '通知',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            value: enabled,
            onChanged: onEnabledChanged,
          ),

          if (enabled) ...[
            const SizedBox(height: 10),
            const Text(
              '通知するタイミング',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff35415F),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('曜日'),
                  selected: !usesDate,
                  onSelected: (_) {
                    onDateChanged(null);
                  },
                ),
                ChoiceChip(
                  label: const Text('日にち'),
                  selected: usesDate,
                  onSelected: (_) {
                    onDaysChanged([]);
                    _pickDate(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (!usesDate) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weekdays.map((day) {
                  final selected = days.contains(day);

                  return ChoiceChip(
                    label: Text(day),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xff526FC5),
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xff35415F),
                    ),
                    onSelected: (_) {
                      final next = [...days];

                      if (selected) {
                        next.remove(day);
                      } else {
                        next.add(day);
                      }

                      onDaysChanged(next);
                    },
                  );
                }).toList(),
              ),
            ] else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xff526FC5),
                ),
                title: Text(
                  '${date!.year}年${date!.month}月${date!.day}日',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickDate(context),
              ),

            const SizedBox(height: 14),
            const Text(
              '時間',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff35415F),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._templateHours.map((hour) {
                  final selected =
                      time.hour == hour && time.minute == 0;

                  return ChoiceChip(
                    label: Text('${hour.toString().padLeft(2, '0')}:00'),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xff526FC5),
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xff35415F),
                    ),
                    onSelected: (_) {
                      onTimeChanged(TimeOfDay(hour: hour, minute: 0));
                    },
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.tune, size: 18),
                  label: Text(
                    _templateHours.contains(time.hour) && time.minute == 0
                        ? 'カスタマイズ'
                        : time.format(context),
                  ),
                  onPressed: () => _pickCustomTime(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
