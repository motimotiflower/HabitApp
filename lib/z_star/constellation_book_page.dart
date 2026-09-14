//獲得した星座を確認する図鑑ページ
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
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
        toolbarHeight: MainBackground.detailToolbarHeight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xffD8C7AA),
        foregroundColor: const Color(0xff5E4A38),
        title: const Text('星座図鑑'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isWide
                  ? 'assets/images/background_book.png'
                  : 'assets/images/background_book2.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: isWide
                ? _WebBook(records: records)
                : _MobileBook(records: records),
          ),
        ],
      ),
    );
  }
}

class _WebBook extends StatelessWidget {
  const _WebBook({required this.records});

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

        return _BookPageContent(name: name, record: record);
      },
    );
  }
}

class _MobileBook extends StatelessWidget {
  const _MobileBook({required this.records});

  final List<ConstellationRecord> records;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _BookScrollBehavior(),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        physics: const PageScrollPhysics(),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: _BookPageContent(name: name, record: record),
          );
        },
      ),
    );
  }
}

class _BookScrollBehavior extends MaterialScrollBehavior {
  const _BookScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _BookPageContent extends StatelessWidget {
  const _BookPageContent({
    required this.name,
    required this.record,
  });

  final String name;
  final ConstellationRecord? record;

  @override
  Widget build(BuildContext context) {
    final unlocked = record != null;

    //カードを置かず、本の紙面へ直接レイアウト
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Column(
        children: [
          Expanded(
            child: unlocked
                ? _ConstellationArtwork(name: name)
                : const Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: Color(0xff8B765F),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            unlocked ? name : '？？？',
            style: const TextStyle(
              fontSize: 21,
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

class _ConstellationArtwork extends StatelessWidget {
  const _ConstellationArtwork({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide * 0.90;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: ShaderMask(
              //画像の四角い端だけをぼかして紙になじませる
              shaderCallback: (bounds) {
                return const RadialGradient(
                  center: Alignment.center,
                  radius: 0.86,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.72, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                ConstellationData.imagePath(name),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
