
import 'dart:io';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import '../services/file_service.dart';

class FileSystemScreen extends StatefulWidget {
  const FileSystemScreen({super.key});

  @override
  State<FileSystemScreen> createState() =>
      _FileSystemScreenState();
}

class _FileSystemScreenState
    extends State<FileSystemScreen> {
  List<DirectoryResult> _directories = [];

  final Map<String, File> _createdFiles = {};

  bool _loading = true;
  bool _writing = false;
  String _status = 'Нажми «Записать примеры».';

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    setState(() => _loading = true);

    final directories = await FileService.getDirectories();

    if (!mounted) return;

    setState(() {
      _directories = directories;
      _loading = false;
    });
  }

  Future<void> _writeExamples() async {
    setState(() {
      _writing = true;
      _status = 'Выполняется запись файлов...';
      _createdFiles.clear();
    });

    try {
      final students =
          await DatabaseHelper.instance.getAllStudents();

      final examples = <Student>[
        ...students.take(3),
      ];

      const samples = [
        Student(
          name: 'Алексей Мандрик',
          age: 20,
          group: 'ПО-21',
          faculty: 'ИТ',
          direction: 'Программная инженерия',
        ),
        Student(
          name: 'Мария Иванова',
          age: 23,
          group: 'КН-23',
          faculty: 'ИТ',
          direction: 'Компьютерные науки',
        ),
        Student(
          name: 'Иван Петров',
          age: 19,
          group: 'ЭК-22',
          faculty: 'Экономический',
          direction: 'Экономика',
        ),
      ];

      for (final sample in samples) {
        if (examples.length >= 3) break;
        examples.add(sample);
      }

      final availableDirectories = _directories
          .where((item) => item.directory != null)
          .toList();

      if (availableDirectories.isEmpty) {
        setState(() {
          _status = 'Нет доступных директорий для записи.';
        });
        return;
      }

      var written = 0;
      final errors = <String>[];

      for (var i = 0;
          i < examples.length && i < availableDirectories.length;
          i++) {
        final directoryResult = availableDirectories[i];

        try {
          final file = await FileService.writeStudent(
            directory: directoryResult.directory!,
            student: examples[i],
            fileName: 'student_${i + 1}.json',
          );

          _createdFiles[directoryResult.label] = file;
          written++;
        } catch (e) {
          errors.add('${directoryResult.label}: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _status = 'Успешно записано файлов: $written.'
            '${errors.isEmpty ? '' : '\nОшибки:\n${errors.join('\n')}'}';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Ошибка записи: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _writing = false);
      }
    }
  }

  Future<void> _readFile(File file) async {
    try {
      final student = await FileService.readStudent(file);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Данные из файла'),
          content: SingleChildScrollView(
            child: SelectableText(
              'Путь:\n${file.path}\n\n'
              'ID: ${student.id ?? "не задан"}\n'
              'ФИО: ${student.name}\n'
              'Возраст: ${student.age}\n'
              'Группа: ${student.group}\n'
              'Факультет: ${student.faculty}\n'
              'Направление: ${student.direction}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка чтения файла: $e'),
        ),
      );
    }
  }

  Future<void> _showDirectoryFiles(
    DirectoryResult result,
  ) async {
    final directory = result.directory;

    if (directory == null) return;

    final files = await FileService.listFiles(directory);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.label),
        content: SizedBox(
          width: double.maxFinite,
          child: files.isEmpty
              ? const Text(
                  'В этой директории пока нет файлов.',
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final entry = files[index];

                    return ListTile(
                      leading: Icon(
                        entry is Directory
                            ? Icons.folder
                            : Icons.insert_drive_file,
                      ),
                      title: Text(
                        entry.uri.pathSegments.isEmpty
                            ? entry.path
                            : entry.uri.pathSegments.last,
                      ),
                      subtitle: SelectableText(entry.path),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Файловая система Android'),
        actions: [
          IconButton(
            tooltip: 'Обновить директории',
            onPressed: _loadDirectories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Работа с файлами и изолятами',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Будут созданы JSON-файлы с данными '
                          'разных студентов в доступных '
                          'директориях Android. Запись и чтение '
                          'выполняются через Isolate.run.',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed:
                              _writing ? null : _writeExamples,
                          icon: const Icon(Icons.save_alt),
                          label: Text(
                            _writing
                                ? 'Запись...'
                                : 'Записать примеры',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(_status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Системные директории',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._directories.map((item) {
                  final unavailable = item.directory == null;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        unavailable
                            ? Icons.warning_amber
                            : Icons.folder_outlined,
                        color: unavailable
                            ? Colors.deepOrange
                            : null,
                      ),
                      title: Text(item.label),
                      subtitle: SelectableText(
                        item.directory?.path ??
                            item.error ??
                            'Недоступно',
                      ),
                      trailing: unavailable
                          ? null
                          : IconButton(
                              tooltip: 'Показать файлы',
                              onPressed: () =>
                                  _showDirectoryFiles(item),
                              icon: const Icon(Icons.visibility),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  'Файлы, созданные приложением',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_createdFiles.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'После записи здесь появятся пути '
                        'к созданным файлам.',
                      ),
                    ),
                  ),
                ..._createdFiles.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                      ),
                      title: Text(entry.key),
                      subtitle: SelectableText(
                        entry.value.path,
                      ),
                      trailing: IconButton(
                        tooltip: 'Прочитать файл',
                        onPressed: () =>
                            _readFile(entry.value),
                        icon: const Icon(Icons.read_more),
                      ),
                      onTap: () => _readFile(entry.value),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
