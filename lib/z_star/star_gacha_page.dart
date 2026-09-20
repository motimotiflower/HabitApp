//星の欠片・ガチャをまとめたページ
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/z_star/constellation_book_page.dart';
import 'package:habitapp/z_star/star_sky_page.dart';
import 'package:habitapp/z_star/star_storage.dart';

class StarGachaPage extends StatefulWidget {
  const StarGachaPage({super.key});

  @override
  State<StarGachaPage> createState() => _StarGachaPageState();
}

class _StarGachaPageState extends State<StarGachaPage> {
  StarState _starState = StarState(awards: [], constellations: []);

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final state = await StarStorage.load();
    if (!mounted) return;
    setState(() => _starState = state);
  }

  Future<void> _drawConstellation() async {
    if (_starState.fragments < StarStorage.drawCost) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('星座ガチャ'),
        content: const Text('星の欠片を15個使って、星座を探しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('星座を探す'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final record = await StarStorage.draw();
    await _loadStars();
    if (!mounted || record == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しい星座を見つけました！', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 74, color: Color(0xffE7B95A)),
            const SizedBox(height: 14),
            Text(record.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _openSky() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => StarSkyPage(records: _starState.constellations),
    ));
  }

  void _openBook() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ConstellationBookPage(records: _starState.constellations),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fragments = _starState.fragments;
    final ownedCount = _starState.constellations.length;
    final drawCount = fragments ~/ StarStorage.drawCost;
    final ratio = fragments / StarStorage.drawCost;
    final bottleAsset = ratio <= 0
        ? 'assets/images/bottle_blank.png'
        : ratio < 1
            ? 'assets/images/bottle_half.png'
            : 'assets/images/bottle_fill.png';
    final allCollected = ownedCount >= StarStorage.constellationNames.length;

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      appBar: AppBar(
        toolbarHeight: MainBackground.detailToolbarHeight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Image.asset('assets/images/background_sky.png', fit: BoxFit.cover),
        titleSpacing: 0,
        title: const Text('星座ガチャ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffF3F2FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xffDDDDF1)),
            ),
            child: Column(
              children: [
                const Text('星の欠片', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(width: 190, height: 200, child: Image.asset(bottleAsset, fit: BoxFit.contain)),
                const SizedBox(height: 14),
                Text(
                  fragments < StarStorage.drawCost ? '$fragments / ${StarStorage.drawCost}' : '星の欠片  $fragments個',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  allCollected
                      ? '12種類の星座をすべて見つけました！'
                      : fragments < StarStorage.drawCost
                          ? 'あと${StarStorage.drawCost - fragments}個でガチャを引けます'
                          : '星座ガチャを$drawCount回引けます',
                  style: const TextStyle(fontSize: 13, color: Color(0xff697188)),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (fragments % StarStorage.drawCost == 0 && fragments > 0)
                      ? 1
                      : (fragments % StarStorage.drawCost) / StarStorage.drawCost,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 16),
                if (!allCollected)
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: FilledButton.icon(
                      onPressed: fragments >= StarStorage.drawCost ? _drawConstellation : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('星座ガチャを引く', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SmallInfo(label: '習慣', value: _starState.habitFragments)),
                    const SizedBox(width: 8),
                    Expanded(child: _SmallInfo(label: 'タスク', value: _starState.taskFragments)),
                    const SizedBox(width: 8),
                    Expanded(child: _SmallInfo(label: '星座', value: ownedCount)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openSky,
                    icon: const Icon(Icons.nightlight_outlined),
                    label: const Text('空を見る'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openBook,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('図鑑を見る'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff81889B))),
          const SizedBox(height: 4),
          Text(value.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
