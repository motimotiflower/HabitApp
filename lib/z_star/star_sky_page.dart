//獲得した星座を夜空に並べるページ
import 'package:flutter/material.dart';
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
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff102D72),
                    Color(0xff394E9B),
                    Color(0xff6278C7),
                  ],
                ),
              ),
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
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xffFFE6A3),
                              size: 30,
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
