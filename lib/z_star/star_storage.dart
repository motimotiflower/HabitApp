//星の欠片・星座の保存処理
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class StarAward {
  StarAward({
    required this.key,
    required this.source,
    this.spent = false,
  });

  final String key;
  final String source;
  bool spent;

  Map<String, dynamic> toJson() => {
        'key': key,
        'source': source,
        'spent': spent,
      };

  factory StarAward.fromJson(Map<String, dynamic> json) {
    return StarAward(
      key: json['key'] ?? '',
      source: json['source'] ?? '',
      spent: json['spent'] ?? false,
    );
  }
}

class ConstellationRecord {
  ConstellationRecord({
    required this.name,
    required this.acquiredAt,
  });

  final String name;
  final DateTime acquiredAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'acquiredAt': acquiredAt.toIso8601String(),
      };

  factory ConstellationRecord.fromJson(Map<String, dynamic> json) {
    return ConstellationRecord(
      name: json['name'] ?? '',
      acquiredAt:
          DateTime.tryParse(json['acquiredAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class StarState {
  StarState({
    required this.awards,
    required this.constellations,
  });

  final List<StarAward> awards;
  final List<ConstellationRecord> constellations;

  int get fragments => awards.where((award) => !award.spent).length;
  int get habitFragments =>
      awards.where((award) => !award.spent && award.source == 'habit').length;
  int get taskFragments =>
      awards.where((award) => !award.spent && award.source == 'task').length;
}

class StarStorage {
  static const String _key = 'star_system';

  //最初に用意する30種類。ガチャでは被らない
  static const List<String> constellationNames = [
    'おひつじ座',
    'おうし座',
    'ふたご座',
    'かに座',
    'しし座',
    'おとめ座',
    'てんびん座',
    'さそり座',
    'いて座',
    'やぎ座',
    'みずがめ座',
    'うお座',
    'こぐま座',
    'おおぐま座',
    'カシオペヤ座',
    'ケフェウス座',
    'アンドロメダ座',
    'ペガスス座',
    'オリオン座',
    'おおいぬ座',
    'こいぬ座',
    'こと座',
    'わし座',
    'はくちょう座',
    'いるか座',
    'ヘルクレス座',
    'りゅう座',
    'ペルセウス座',
    'ぎょしゃ座',
    'かんむり座',
  ];

  static Future<StarState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return StarState(awards: [], constellations: []);
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final awards = (json['awards'] as List<dynamic>? ?? [])
        .map((item) => StarAward.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final constellations =
        (json['constellations'] as List<dynamic>? ?? [])
            .map(
              (item) => ConstellationRecord.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

    return StarState(
      awards: awards,
      constellations: constellations,
    );
  }

  static Future<void> _save(StarState state) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode({
        'awards': state.awards.map((item) => item.toJson()).toList(),
        'constellations':
            state.constellations.map((item) => item.toJson()).toList(),
      }),
    );
  }

  //同じ達成で二重に欠片を増やさない
  static Future<void> award({
    required String actionKey,
    required String source,
  }) async {
    final state = await load();

    if (state.awards.any((award) => award.key == actionKey)) return;

    state.awards.add(
      StarAward(
        key: actionKey,
        source: source,
      ),
    );

    await _save(state);
  }

  //未使用の欠片ならチェック解除で取り消せる
  static Future<void> revoke(String actionKey) async {
    final state = await load();
    final index = state.awards.indexWhere(
      (award) => award.key == actionKey,
    );

    if (index == -1 || state.awards[index].spent) return;

    state.awards.removeAt(index);
    await _save(state);
  }

  //30個を消費して、未獲得の星座からランダムに1つ獲得
  static Future<ConstellationRecord?> draw() async {
    final state = await load();
    final unspent = state.awards.where((award) => !award.spent).toList();

    if (unspent.length < 30) return null;

    final owned =
        state.constellations.map((record) => record.name).toSet();
    final available = constellationNames
        .where((name) => !owned.contains(name))
        .toList();

    if (available.isEmpty) return null;

    for (final award in unspent.take(30)) {
      award.spent = true;
    }

    final name = available[Random().nextInt(available.length)];
    final record = ConstellationRecord(
      name: name,
      acquiredAt: DateTime.now(),
    );

    state.constellations.add(record);
    await _save(state);

    return record;
  }
}
