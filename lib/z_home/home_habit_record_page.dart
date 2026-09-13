//Homeから開く習慣記録の詳細画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_star/constellation_book_page.dart';
import 'package:habitapp/z_star/star_sky_page.dart';
import 'package:habitapp/z_star/star_storage.dart';

class HomeHabitRecordPage extends StatefulWidget {
  const HomeHabitRecordPage({
    super.key,
    required this.habits,
    required this.categoryColors,
  });

  final List<Habit> habits;
  final Map<String, int> categoryColors;

  @override
  State<HomeHabitRecordPage> createState() =>
      _HomeHabitRecordPageState();
}

class _HomeHabitRecordPageState
    extends State<HomeHabitRecordPage> {
  StarState _starState = StarState(
    awards: [],
    constellations: [],
  );

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final state = await StarStorage.load();

    if (!mounted) return;

    setState(() {
      _starState = state;
    });
  }

  //ジャンル未設定なら習慣単体、それ以外はジャンルごとにまとめる
  Map<String, List<Habit>> _groupHabits() {
    final groups = <String, List<Habit>>{};

    for (final habit in widget.habits) {
      final key =
          habit.category == '未設定' ? habit.title : habit.category;

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(habit);
    }

    return groups;
  }

  int _completedCount(List<Habit> groupHabits) {
    var count = 0;

    for (final habit in groupHabits) {
      for (final completed in habit.completionHistory.values) {
        if (completed) count++;
      }
    }

    return count;
  }

  Color _groupColor(List<Habit> groupHabits) {
    final firstHabit = groupHabits.first;

    if (firstHabit.category == '未設定') {
      return const Color(0xff526FC5);
    }

    return Color(
      widget.categoryColors[firstHabit.category] ?? 0xff526FC5,
    );
  }

  Future<void> _drawConstellation() async {
    if (_starState.fragments < StarStorage.drawCost) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('星座ガチャ'),
          content: const Text(
            '星の欠片を15個使って、星座を探しますか？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff526FC5),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('星座を探す'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final record = await StarStorage.draw();

    if (!mounted) return;

    await _loadStars();

    if (!mounted || record == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffF8F7FF),
          title: const Text(
            '新しい星座を見つけました！',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 74,
                color: Color(0xffE7B95A),
              ),
              const SizedBox(height: 14),
              Text(
                record.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff526FC5),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openSky() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StarSkyPage(
          records: _starState.constellations,
        ),
      ),
    );
  }

  void _openBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConstellationBookPage(
          records: _starState.constellations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupHabits();

    //並んだカード同士で縦のマス数もそろえる
    final maxCompleted = groups.values.isEmpty
        ? 0
        : groups.values
            .map(_completedCount)
            .reduce((a, b) => a > b ? a : b);
    const columns = 11;
    const minimumCells = columns * 3;
    final roundedCells =
        ((maxCompleted + columns - 1) ~/ columns) * columns;
    final commonCellCount =
        roundedCells > minimumCells ? roundedCells : minimumCells;

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      //メモ部屋と同じ高さ・余白・戻るボタンのヘッダー
      appBar: AppBar(
        //各詳細ページで上下の余白をそろえる
        toolbarHeight: MainBackground.detailToolbarHeight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff526FC5),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          '記録',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        children: [
          _StarFragmentCard(
            fragments: _starState.fragments,
            habitFragments: _starState.habitFragments,
            taskFragments: _starState.taskFragments,
            ownedCount: _starState.constellations.length,
            onDraw: _drawConstellation,
            onSky: _openSky,
            onBook: _openBook,
          ),
          const SizedBox(height: 26),
          const Text(
            '記録',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff35415F),
            ),
          ),
          const SizedBox(height: 14),
          if (groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'まだ記録がありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff81889B),
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final columnCount = constraints.maxWidth >= 1200
                    ? 3
                    : constraints.maxWidth >= 700
                        ? 2
                        : 1;
                const gap = 18.0;
                final itemWidth = columnCount == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth -
                            gap * (columnCount - 1)) /
                        columnCount;

                return Wrap(
                  spacing: gap,
                  runSpacing: 22,
                  children: groups.entries.map((entry) {
                    return SizedBox(
                      width: itemWidth,
                      child: _RecordGrid(
                        title: entry.key,
                        completedCount: _completedCount(entry.value),
                        color: _groupColor(entry.value),
                        compact: isWide,
                        cellCount: commonCellCount,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StarFragmentCard extends StatelessWidget {
  const _StarFragmentCard({
    required this.fragments,
    required this.habitFragments,
    required this.taskFragments,
    required this.ownedCount,
    required this.onDraw,
    required this.onSky,
    required this.onBook,
  });

  final int fragments;
  final int habitFragments;
  final int taskFragments;
  final int ownedCount;
  final VoidCallback onDraw;
  final VoidCallback onSky;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final drawCount = fragments ~/ StarStorage.drawCost;

    // 星の欠片の量に合わせて瓶画像を切り替える
    final ratio = StarStorage.drawCost == 0
        ? 0.0
        : fragments / StarStorage.drawCost;
    final bottleAsset = ratio <= 0
        ? 'assets/images/bottle_blank.png'
        : ratio < 1
            ? 'assets/images/bottle_half.png'
            : 'assets/images/bottle_fill.png';
    final allCollected =
        ownedCount >= StarStorage.constellationNames.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF3F2FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffDDDDF1),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '星の欠片',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xff263A70),
            ),
          ),
          const SizedBox(height: 16),

          // 星の欠片の量に応じた瓶画像
          SizedBox(
            width: 190,
            height: 200,
            child: Image.asset(
              bottleAsset,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            fragments < StarStorage.drawCost
                ? '$fragments / ${StarStorage.drawCost}'
                : '星の欠片  $fragments個',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xff263A70),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            allCollected
                ? '30種類の星座をすべて見つけました！'
                : fragments < StarStorage.drawCost
                    ? 'あと${StarStorage.drawCost - fragments}個でガチャを引けます'
                    : '星座ガチャを$drawCount回引けます',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff697188),
            ),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: (fragments % StarStorage.drawCost == 0 &&
                    fragments > 0)
                ? 1
                : (fragments % StarStorage.drawCost) /
                    StarStorage.drawCost,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xffDDDDF1),
            color: const Color(0xff8E8BD7),
          ),

          const SizedBox(height: 16),

          if (!allCollected)
            SizedBox(
              width: double.infinity,
              height: 62,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffE7B95A),
                  foregroundColor: const Color(0xff263A70),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    fragments >= StarStorage.drawCost ? onDraw : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  '星座ガチャを引く',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _SmallInfo(
                  label: '習慣',
                  value: habitFragments,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallInfo(
                  label: 'タスク',
                  value: taskFragments,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallInfo(
                  label: '星座',
                  value: ownedCount,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: onSky,
              icon: const Icon(Icons.nightlight_outlined),
              label: const Text(
                '空を見る',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: onBook,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text(
                '図鑑を見る',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff81889B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff35415F),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordGrid extends StatelessWidget {
  const _RecordGrid({
    required this.title,
    required this.completedCount,
    required this.color,
    required this.cellCount,
    this.compact = false,
  });

  final String title;
  final int completedCount;
  final Color color;
  final int cellCount;
  final bool compact;

  static const int _columnCount = 11;

  @override
  Widget build(BuildContext context) {

    //ジャンル・習慣ごとにカードで分けて見やすくする
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffE2E7F5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xff35415F),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = compact ? 4.0 : 5.0;

              //カード幅いっぱいに11列のマスを敷き詰める
              final cellSize = (constraints.maxWidth -
                      spacing * (_columnCount - 1)) /
                  _columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(cellCount, (index) {
                  final completed = index < completedCount;

                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: completed ? color : const Color(0xffF8FAFF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: completed
                            ? color
                            : const Color(0xffDCE3F5),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
