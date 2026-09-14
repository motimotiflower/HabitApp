//獲得した星座を夜空に並べるページ
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/z_star/constellation_data.dart';
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
          //星空用に追加した背景を表示
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_sky1.png',
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
                final centerX = constraints.maxWidth / 2;
                final centerY = constraints.maxHeight * 0.50;

                //スマホの縦長画面に合わせて少し縦長の円にする
                final radiusX = constraints.maxWidth * 0.34;
                final radiusY = constraints.maxHeight * 0.31;

                const itemWidth = 86.0;
                const itemHeight = 104.0;

                return Stack(
                  children: records.map((record) {
                    final constellationIndex =
                        StarStorage.constellationNames.indexOf(record.name);

                    //12星座の決まった位置に置く
                    final index =
                        constellationIndex < 0 ? 0 : constellationIndex;
                    final angle = -pi / 2 + (2 * pi * index / 12);

                    final left = centerX +
                        cos(angle) * radiusX -
                        itemWidth / 2;
                    final top = centerY +
                        sin(angle) * radiusY -
                        itemHeight / 2;

                    return Positioned(
                      left: left,
                      top: top,
                      width: itemWidth,
                      height: itemHeight,
                      child: Tooltip(
                        message: record.name,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //画像を潰さず大きめに表示する
                            Expanded(
                              child: Image.asset(
                                ConstellationData.imagePath(record.name),
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              record.name,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
