import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudBackupStatus {
  const CloudBackupStatus({
    required this.exists,
    required this.updatedAt,
  });

  final bool exists;
  final DateTime? updatedAt;
}

class CloudBackupService {
  static const _localKeys = [
    'habits',
    'tasks',
    'memos',
    'star_system',
    'user_name',
  ];

  static const _localUpdatedAtKey = 'cloud_backup_local_updated_at';

  static DocumentReference<Map<String, dynamic>>? get _backupDocument {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // UIDごとに保存場所を分けるので、他ユーザーのデータと混ざらない
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('backups')
        .doc('main');
  }

  // 端末内にHabitAppの保存データがあるか確認
  static Future<bool> hasLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _localKeys) {
      final value = prefs.get(key);
      if (value == null) continue;

      if (value is String && value.trim().isEmpty) continue;
      return true;
    }

    return false;
  }

  static Future<DateTime?> getLocalUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_localUpdatedAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  static Future<void> markLocalUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localUpdatedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<CloudBackupStatus> getStatus() async {
    final document = _backupDocument;
    if (document == null) {
      return const CloudBackupStatus(exists: false, updatedAt: null);
    }

    final snapshot = await document.get();
    final data = snapshot.data();
    final timestamp = data?['updatedAt'];

    return CloudBackupStatus(
      exists: data != null,
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  // 端末内のSharedPreferencesをFirestoreへバックアップ
  static Future<void> backup() async {
    final document = _backupDocument;
    if (document == null) return;

    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};

    for (final key in _localKeys) {
      final value = prefs.get(key);
      if (value != null) {
        data[key] = value;
      }
    }

    await document.set({
      'data': data,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // バックアップ成功時刻も端末側に残す
    await prefs.setString(
      _localUpdatedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  // Firestoreのバックアップをこの端末へ復元
  static Future<bool> restore() async {
    final document = _backupDocument;
    if (document == null) return false;

    final snapshot = await document.get();
    final cloud = snapshot.data();
    if (cloud == null) return false;

    final data = Map<String, dynamic>.from(cloud['data'] as Map? ?? {});
    final prefs = await SharedPreferences.getInstance();

    for (final entry in data.entries) {
      final value = entry.value;

      if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is List) {
        // SharedPreferencesの文字列リストも扱えるようにする
        await prefs.setStringList(
          entry.key,
          value.map((item) => item.toString()).toList(),
        );
      }
    }

    final timestamp = cloud['updatedAt'];
    final restoredAt = timestamp is Timestamp
        ? timestamp.toDate().toUtc()
        : DateTime.now().toUtc();

    await prefs.setString(
      _localUpdatedAtKey,
      restoredAt.toIso8601String(),
    );

    return true;
  }

  // 端末とクラウドの更新時刻を比べて、新しい方を採用する
  static Future<void> syncLatest() async {
    final document = _backupDocument;
    if (document == null) return;

    final localExists = await hasLocalData();
    final localUpdatedAt = await getLocalUpdatedAt();

    final snapshot = await document.get();
    final cloud = snapshot.data();

    if (cloud == null) {
      if (localExists) {
        await backup();
      }
      return;
    }

    final cloudTimestamp = cloud['updatedAt'];
    final cloudUpdatedAt =
        cloudTimestamp is Timestamp ? cloudTimestamp.toDate() : null;

    if (!localExists) {
      await restore();
      return;
    }

    // 更新時刻が分からない既存データは、最初の1回だけ端末側を優先
    if (localUpdatedAt == null || cloudUpdatedAt == null) {
      await backup();
      return;
    }

    if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
      await restore();
    } else if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
      await backup();
    }
  }

  // デバッグ確認用。Firestoreに保存する内容をJSONで確認できる
  static Future<String> previewLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};

    for (final key in _localKeys) {
      data[key] = prefs.get(key);
    }

    return jsonEncode(data);
  }
}
