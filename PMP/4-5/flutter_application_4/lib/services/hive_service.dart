import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../models/app_user.dart';
import '../models/task_model.dart';

class HiveService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  static late Box<Task> tasks;
  static late Box<AppUser> users;
  static late Box<String> favorites;
  static late Box<String> settings;
  static late Box<String> compressedData;

  static late Uint8List _encryptionKey;

  static Future<void> init() async {
    final savedKey = await _storage.read(key: _keyName);

    if (savedKey == null) {
      _encryptionKey = _generateKey();
      await _storage.write(
        key: _keyName,
        value: base64Encode(_encryptionKey),
      );
    } else {
      _encryptionKey = Uint8List.fromList(
        base64Decode(savedKey),
      );
    }

    final cipher = HiveAesCipher(_encryptionKey);

    tasks = await Hive.openBox<Task>(
      'tasks',
      encryptionCipher: cipher,
    );

    users = await Hive.openBox<AppUser>(
      'users',
      encryptionCipher: cipher,
    );

    favorites = await Hive.openBox<String>(
      'favorites',
      encryptionCipher: cipher,
    );

    settings = await Hive.openBox<String>(
      'settings',
      encryptionCipher: cipher,
    );

    compressedData = await Hive.openBox<String>(
      'compressed_data',
      encryptionCipher: cipher,
    );

    await _seedUsers();
    await _seedTasks();
  }

  static Uint8List _generateKey() {
    final random = Random.secure();

    return Uint8List.fromList(
      List<int>.generate(
        32,
        (_) => random.nextInt(256),
      ),
    );
  }

  static Future<void> _seedUsers() async {
    if (users.isNotEmpty) return;

    await users.put(
      'admin',
      const AppUser(
        id: 'admin',
        name: 'Алексей',
        role: UserRole.admin,
      ),
    );

    await users.put(
      'manager',
      const AppUser(
        id: 'manager',
        name: 'Менеджер',
        role: UserRole.manager,
      ),
    );

    await users.put(
      'user',
      const AppUser(
        id: 'user',
        name: 'Пользователь',
        role: UserRole.user,
      ),
    );

    await settings.put('activeUserId', 'admin');
  }

  static Future<void> _seedTasks() async {
    if (tasks.isNotEmpty) return;

    await tasks.put(
      'task1',
      Task(
        title: 'Dashboard design for admin',
        tags: [
          TaskTag(
            label: 'High',
            backgroundColor: const Color(0xFFFFD2D2),
            textColor: Colors.red,
          ),
          TaskTag(
            label: 'On Track',
            backgroundColor: const Color(0xFFF3D2FF),
            textColor: Colors.purple,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 5,
        commentsCount: 5,
      ),
    );

    await tasks.put(
      'task2',
      Task(
        title: 'Konom web application',
        tags: [
          TaskTag(
            label: 'Low',
            backgroundColor: const Color(0xFFD2FFD2),
            textColor: Colors.green,
          ),
          TaskTag(
            label: 'Meeting',
            backgroundColor: const Color(0xFFD2DCFF),
            textColor: Colors.indigo,
          ),
        ],
        date: '14 Nov 2022',
        linksCount: 2,
        commentsCount: 4,
      ),
    );

    await tasks.put(
      'task3',
      Task(
        title: 'Research and development',
        tags: [
          TaskTag(
            label: 'Medium',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
          TaskTag(
            label: 'At Risk',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 6,
        commentsCount: 2,
        backgroundColor: const Color(0xFF4CAF50),
        isDarkText: false,
      ),
    );

    await tasks.put(
      'task4',
      Task(
        title: 'Event booking application',
        tags: [
          TaskTag(
            label: 'Medium',
            backgroundColor: const Color(0xFFFFE0B2),
            textColor: Colors.orange,
          ),
          TaskTag(
            label: 'Meeting',
            backgroundColor: const Color(0xFFD2DCFF),
            textColor: Colors.indigo,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 5,
        commentsCount: 5,
      ),
    );
  }

  static AppUser? get currentUser {
    final id = settings.get('activeUserId');
    if (id == null) return null;
    return users.get(id);
  }

  static Future<void> switchUser(AppUser user) async {
    await settings.put('activeUserId', user.id);
  }

  static bool isFavorite(String taskKey) {
    return favorites.containsKey(taskKey);
  }

  static Future<void> toggleFavorite(String taskKey) async {
    if (favorites.containsKey(taskKey)) {
      await favorites.delete(taskKey);
    } else if (tasks.containsKey(taskKey)) {
      await favorites.put(taskKey, taskKey);
    }
  }

  static List<MapEntry<String, Task>> getFavoriteTasks() {
    final result = <MapEntry<String, Task>>[];

    for (final key in favorites.keys) {
      final taskKey = favorites.get(key);
      if (taskKey == null) continue;

      final task = tasks.get(taskKey);
      if (task != null) {
        result.add(MapEntry(taskKey, task));
      }
    }

    return result;
  }

  static Future<void> compressTasks() async {
    final data = tasks.toMap().map(
      (key, task) => MapEntry(
        key.toString(),
        {
          'title': task.title,
          'date': task.date,
          'linksCount': task.linksCount,
          'commentsCount': task.commentsCount,
          'backgroundColor': task.backgroundColorValue,
          'isDarkText': task.isDarkText,
          'tags': task.tags.map((tag) => {
            'label': tag.label,
            'backgroundColor': tag.backgroundColorValue,
            'textColor': tag.textColorValue,
          }).toList(),
        },
      ),
    );

    final jsonBytes = utf8.encode(jsonEncode(data));
    final compressedBytes = gzip.encode(jsonBytes);

    await compressedData.put(
      'tasks_gzip_base64',
      base64Encode(compressedBytes),
    );
  }

  static Future<Map<String, dynamic>> readCompressedTasks() async {
    final encoded = compressedData.get('tasks_gzip_base64');

    if (encoded == null) {
      throw StateError('Сначала выполните сжатие данных.');
    }

    final compressedBytes = base64Decode(encoded);
    final jsonBytes = gzip.decode(compressedBytes);
    final jsonText = utf8.decode(jsonBytes);

    return Map<String, dynamic>.from(
      jsonDecode(jsonText) as Map,
    );
  }

  static Future<bool> testWrongEncryptionKey() async {
    const boxName = 'wrong_key_demo';

    // Записываем данные с правильным ключом.
    final correctBox = await Hive.openBox<String>(
      boxName,
      encryptionCipher: HiveAesCipher(_encryptionKey),
    );

    await correctBox.put('test', 'Секретные данные');
    await correctBox.close();

    // Пытаемся открыть коробку с другим ключом.
    final wrongKey = _generateKey();

    try {
      final wrongBox = await Hive.openBox<String>(
        boxName,
        encryptionCipher: HiveAesCipher(wrongKey),
      );

      // Если данные удалось прочитать, проверяем их.
      final value = wrongBox.get('test');
      await wrongBox.close();

      if (value != 'Секретные данные') {
        return true;
      }

      return false;
    } catch (_) {
      return true;
    }
  }
}