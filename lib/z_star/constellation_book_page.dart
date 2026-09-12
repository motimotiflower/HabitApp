//獲得した星座を確認する図鑑ページ
import 'package:flutter/material.dart';
import 'package:habitapp/z_star/constellation_data.dart';
import 'package:habitapp/z_star/star_storage.dart';

class ConstellationBookPage extends StatelessWidget {
  const ConstellationBookPage({
    super.key,
    required this.records,
  });

  final List<ConstellationRecord> records;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xffEEE4D3),
      appBar: AppBar(
        backgroundColor: const Color(0xffD8C7AA),
        foregroundColor: const Color(0xff5E4A38),
        title: const Text('星座図鑑'),
      ),
      body: isWide
          ? _WebBook(records: records)
          : _MobileBook(records: records),
    );
  }
}

class _WebBook extends StatelessWidget {
  const _WebBook({
    required this.records,
  });

  final List<ConstellationRecord> records;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.82,
      ),
      itemCount: StarStorage.constellationNames.length,
      itemBuilder: (context, index) {
        final name = StarStorage.constellationNames[index];
        ConstellationRecord? record;

        for (final item in records) {
          if (item.name == name) {
            record = item;
            break;
          }
        }

        return _BookCard(
          name: name,
          record: record,
        );
      },
    );
  }
}

class _MobileBook extends StatelessWidget {
  const _MobileBook({
    required this.records,
  });

  final List<ConstellationRecord> records;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: StarStorage.constellationNames.length,
      itemBuilder: (context, index) {
        final name = StarStorage.constellationNames[index];
        ConstellationRecord? record;

        for (final item in records) {
          if (item.name == name) {
            record = item;
            break;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 20,
          ),
          child: _BookCard(
            name: name,
            record: record,
          ),
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.name,
    required this.record,
  });

  final String name;
  final ConstellationRecord? record;

  @override
  Widget build(BuildContext context) {
    final unlocked = record != null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffF7EEDC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffD8C7AA),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff253C82),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: unlocked
                    ? const Icon(
                        Icons.auto_awesome,
                        size: 72,
                        color: Color(0xffFFE6A3),
                      )
                    : const Icon(
                        Icons.lock_outline,
                        size: 54,
                        color: Colors.white38,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            unlocked ? name : '？？？',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff5E4A38),
            ),
          ),
          const SizedBox(height: 8),
          if (unlocked) ...[
            Text(
              '${record!.acquiredAt.year}/${record!.acquiredAt.month}/${record!.acquiredAt.day}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff8B765F),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ConstellationData.description(name),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xff6A5847),
              ),
            ),
          ] else
            const Text(
              'まだ見つけていない星座です',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff8B765F),
              ),
            ),
        ],
      ),
    );
  }
}
