//獲得した星座を夜空に並べるページ
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/z_star/star_storage.dart';

class StarSkyPage extends StatelessWidget {
  const StarSkyPage({
    super.key,
    required this.records,
  });

  final List<ConstellationRecord> records;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff102D72),
      appBar: AppBar(
        //各詳細ページで上下の余白をそろえる
        toolbarHeight: MainBackground.detailToolbarHeight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xff102D72),
        foregroundColor: Colors.white,
        title: const Text('わたしの星空'),
      ),
      body: Stack(
        children: [
          // 星空の背景画像
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_sky.png',
              fit: BoxFit.cover,
            ),
          ),
          if (records.isEmpty)
            const Center(
              child: Text(
                'まだ星座がありません',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: List.generate(records.length, (index) {
                    final record = records[index];
                    final x = ((index * 137) % 83) / 100;
                    final y = ((index * 89) % 72) / 100;

                    return Positioned(
                      left: constraints.maxWidth * x,
                      top: constraints.maxHeight * y,
                      child: Tooltip(
                        message: record.name,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/constellations.png',
                              width: 42,
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
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
