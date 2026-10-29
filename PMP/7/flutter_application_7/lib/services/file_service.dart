
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/student.dart';

class DirectoryResult {
  final String label;
  final Directory? directory;
  final String? error;
  final bool supported;

  const DirectoryResult({
    required this.label,
    required this.directory,
    this.error,
    this.supported = true,
  });
}

class FileService {
  static Future<List<DirectoryResult>>
      getDirectories() async {
    final results = <DirectoryResult>[];

    Future<void> addDirectory(
      String label,
      Future<Directory?> Function() getter,
    ) async {
      try {
        final directory = await getter();

        if (directory == null) {
          results.add(
            DirectoryResult(
              label: label,
              directory: null,
              error: 'Android не предоставил эту директорию.',
            ),
          );
        } else {
          results.add(
            DirectoryResult(
              label: label,
              directory: directory,
            ),
          );
        }
      } catch (e) {
        results.add(
          DirectoryResult(
            label: label,
            directory: null,
            error: 'Ошибка получения директории на Android: $e',
          ),
        );
      }
    }

    // 1. Temporary
    await addDirectory(
      'Temporary',
      () => getTemporaryDirectory(),
    );

    // 2. Application Support
    await addDirectory(
      'Application Support',
      () => getApplicationSupportDirectory(),
    );

    // 3. Application Library
    results.add(
      const DirectoryResult(
        label: 'Application Library',
        directory: null,
        supported: false,
        error: 'Не поддерживается на Android. '
            'Эта директория предназначена для Apple-платформ.',
      ),
    );

    // 4. Application Documents
    await addDirectory(
      'Application Documents',
      () => getApplicationDocumentsDirectory(),
    );

    // 5. Application Cache
    try {
      final support = await getApplicationSupportDirectory();
      final cacheDirectory = Directory(
        path.join(support.path, 'cache'),
      );

      await cacheDirectory.create(recursive: true);

      results.add(
        DirectoryResult(
          label: 'Application Cache (папка приложения)',
          directory: cacheDirectory,
        ),
      );
    } catch (e) {
      results.add(
        DirectoryResult(
          label: 'Application Cache',
          directory: null,
          error: 'Не удалось создать папку кэша на Android: $e',
        ),
      );
    }

    // 6. External Storage
    await addDirectory(
      'External Storage',
      () => getExternalStorageDirectory(),
    );

    // 7. External Cache Directories
    try {
      final directories =
          await getExternalCacheDirectories();

      if (directories == null || directories.isEmpty) {
        results.add(
          const DirectoryResult(
            label: 'External Cache Directories',
            directory: null,
            error: 'Android не предоставил внешние папки кэша.',
          ),
        );
      } else {
        for (var i = 0; i < directories.length; i++) {
          results.add(
            DirectoryResult(
              label: 'External Cache Directories ${i + 1}',
              directory: directories[i],
            ),
          );
        }
      }
    } catch (e) {
      results.add(
        DirectoryResult(
          label: 'External Cache Directories',
          directory: null,
          error: 'Ошибка на Android: $e',
        ),
      );
    }

    // 8. External Storage Directories
    try {
      final directories =
          await getExternalStorageDirectories();

      if (directories == null || directories.isEmpty) {
        results.add(
          const DirectoryResult(
            label: 'External Storage Directories',
            directory: null,
            error: 'Android не предоставил внешние директории.',
          ),
        );
      } else {
        for (var i = 0; i < directories.length; i++) {
          results.add(
            DirectoryResult(
              label: 'External Storage Directories ${i + 1}',
              directory: directories[i],
            ),
          );
        }
      }
    } catch (e) {
      results.add(
        DirectoryResult(
          label: 'External Storage Directories',
          directory: null,
          error: 'Ошибка на Android: $e',
        ),
      );
    }

    // 9. Downloads
    await addDirectory(
      'Downloads',
      () => getDownloadsDirectory(),
    );

    return results;
  }

  // Запись JSON в изоляте.
  static Future<File> writeStudent({
    required Directory directory,
    required Student student,
    required String fileName,
  }) async {
    await directory.create(recursive: true);

    final fullPath = path.join(
      directory.path,
      fileName,
    );

    final jsonString = jsonEncode(student.toJson());

    await Isolate.run(() async {
      await File(fullPath).writeAsString(
        jsonString,
        flush: true,
      );
    });

    return File(fullPath);
  }

  // Чтение JSON в изоляте.
  static Future<Student> readStudent(File file) async {
    final fullPath = file.path;

    final jsonMap = await Isolate.run(() async {
      final content = await File(fullPath).readAsString();

      return jsonDecode(content) as Map<String, dynamic>;
    });

    return Student.fromJson(
      Map<String, dynamic>.from(jsonMap),
    );
  }

  // Получение списка файлов в директории.
  static Future<List<FileSystemEntity>> listFiles(
    Directory directory,
  ) async {
    try {
      if (!await directory.exists()) {
        return [];
      }

      return await directory
          .list(recursive: false, followLinks: false)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
