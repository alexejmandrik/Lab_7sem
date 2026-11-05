import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class HiveDemoScreen extends StatefulWidget {
  const HiveDemoScreen({super.key});

  @override
  State<HiveDemoScreen> createState() => _HiveDemoScreenState();
}

class _HiveDemoScreenState extends State<HiveDemoScreen> {
  String _compressionResult = 'Сжатие ещё не запускалось.';
  String _keyResult = 'Проверка ключа ещё не выполнялась.';
  bool _busy = false;

  Future<void> _compress() async {
    setState(() {
      _busy = true;
      _compressionResult = 'Выполняется сжатие...';
    });

    try {
      await HiveService.compressTasks();

      final compressed = HiveService.compressedData
          .get('tasks_gzip_base64');

      final decoded = await HiveService.readCompressedTasks();

      setState(() {
        _compressionResult =
            'Сжатие выполнено.\n'
            'Количество задач: ${decoded.length}\n'
            'Размер сохранённой строки Base64: '
            '${compressed?.length ?? 0} символов.\n'
            'Данные успешно распакованы и прочитаны.';
      });
    } catch (e) {
      setState(() {
        _compressionResult = 'Ошибка сжатия: $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testWrongKey() async {
    setState(() {
      _busy = true;
      _keyResult = 'Проверка неверного ключа...';
    });

    try {
      final rejected = await HiveService.testWrongEncryptionKey();

      setState(() {
        _keyResult = rejected
            ? 'Проверка пройдена: неверный ключ не позволил '
                'прочитать исходные данные.'
            : 'Внимание: данные прочитаны с неверным ключом.';
      });
    } catch (e) {
      setState(() {
        _keyResult = 'При проверке возникла ошибка: $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive: шифрование и сжатие'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.lock_outline,
            size: 48,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          const Text(
            'Демонстрация хранения данных',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Основные коробки Hive зашифрованы AES-256. '
            'Ключ хранится в защищённом хранилище Android.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _testWrongKey,
            icon: const Icon(Icons.key_off),
            label: const Text('Проверить неверный ключ'),
          ),
          const SizedBox(height: 8),
          SelectableText(_keyResult),
          const Divider(height: 32),
          FilledButton.icon(
            onPressed: _busy ? null : _compress,
            icon: const Icon(Icons.compress),
            label: const Text('Сжать данные задач'),
          ),
          const SizedBox(height: 8),
          SelectableText(_compressionResult),
          const SizedBox(height: 16),
          const Text(
            'Сжатие выполняется алгоритмом GZip. '
            'Результат хранится в отдельной зашифрованной '
            'коробке Hive.',
          ),
        ],
      ),
    );
  }
}