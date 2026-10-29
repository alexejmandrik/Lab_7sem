
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import 'file_system_screen.dart';
import 'student_details_screen.dart';
import 'student_form_screen.dart';

enum SortField {
  name,
  age,
  group,
  faculty,
  direction,
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}

class _StudentListScreenState
    extends State<StudentListScreen> {
  List<Student> _students = [];

  bool _loading = true;
  String _search = '';
  SortField _sortField = SortField.name;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students =
          await DatabaseHelper.instance.getAllStudents();

      if (!mounted) return;

      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки студентов: $e'),
        ),
      );
    }
  }

  List<Student> get _filteredStudents {
    final query = _search.trim().toLowerCase();

    final result = _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.age.toString().contains(query) ||
          student.group.toLowerCase().contains(query) ||
          student.faculty.toLowerCase().contains(query) ||
          student.direction.toLowerCase().contains(query);
    }).toList();

    int compareText(String a, String b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    }

    result.sort((a, b) {
      int comparison;

      switch (_sortField) {
        case SortField.name:
          comparison = compareText(a.name, b.name);
          break;
        case SortField.age:
          comparison = a.age.compareTo(b.age);
          break;
        case SortField.group:
          comparison = compareText(a.group, b.group);
          break;
        case SortField.faculty:
          comparison = compareText(a.faculty, b.faculty);
          break;
        case SortField.direction:
          comparison =
              compareText(a.direction, b.direction);
          break;
      }

      return _ascending ? comparison : -comparison;
    });

    return result;
  }

  Future<void> _openForm([Student? student]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(
          student: student,
        ),
      ),
    );

    if (changed == true) {
      await _loadStudents();
    }
  }

  Future<void> _openDetails(Student student) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailsScreen(
          student: student,
        ),
      ),
    );

    if (changed == true) {
      await _loadStudents();
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить студента?'),
        content: Text(
          'Удалить запись «${student.name}»?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || student.id == null) {
      return;
    }

    await DatabaseHelper.instance.deleteStudent(
      student.id!,
    );

    await _loadStudents();
  }

  String get _sortLabel {
    switch (_sortField) {
      case SortField.name:
        return 'Имя';
      case SortField.age:
        return 'Возраст';
      case SortField.group:
        return 'Группа';
      case SortField.faculty:
        return 'Факультет';
      case SortField.direction:
        return 'Направление';
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Студенты университета'),
        actions: [
          IconButton(
            tooltip: 'Файловая система',
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FileSystemScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск студентов...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          setState(() => _search = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (value) {
                setState(() => _search = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              children: [
                const Text('Сортировать:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<SortField>(
                    value: _sortField,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: SortField.values.map((field) {
                      String label;

                      switch (field) {
                        case SortField.name:
                          label = 'Имя';
                          break;
                        case SortField.age:
                          label = 'Возраст';
                          break;
                        case SortField.group:
                          label = 'Группа';
                          break;
                        case SortField.faculty:
                          label = 'Факультет';
                          break;
                        case SortField.direction:
                          label = 'Направление';
                          break;
                      }

                      return DropdownMenuItem(
                        value: field,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortField = value);
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: _ascending
                      ? 'По возрастанию'
                      : 'По убыванию',
                  onPressed: () {
                    setState(() => _ascending = !_ascending);
                  },
                  icon: Icon(
                    _ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Сортировка: $_sortLabel, '
                '${_ascending ? "по возрастанию" : "по убыванию"}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : students.isEmpty
                    ? Center(
                        child: Text(
                          _search.isEmpty
                              ? 'Студентов пока нет.\n'
                                  'Нажми «Добавить».'
                              : 'Ничего не найдено.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          itemExtent: 94,
                          padding: const EdgeInsets.fromLTRB(
                            12, 8, 12, 88,
                          ),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    student.name[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${student.group} • '
                                  '${student.faculty}\n'
                                  '${student.age} лет',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _openDetails(student),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openForm(student);
                                    } else if (value == 'delete') {
                                      _deleteStudent(student);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Изменить'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Удалить'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
