
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import 'student_form_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentDetailsScreen> createState() =>
      _StudentDetailsScreenState();
}

class _StudentDetailsScreenState
    extends State<StudentDetailsScreen> {
  late Student _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  Future<void> _editStudent() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(
          student: _student,
        ),
      ),
    );

    if (changed != true || !mounted) return;

    final students =
        await DatabaseHelper.instance.getAllStudents();

    final updated = students.where(
      (student) => student.id == _student.id,
    );

    if (updated.isNotEmpty && mounted) {
      setState(() => _student = updated.first);
    }
  }

  Future<void> _deleteStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: Text(
          'Удалить студента ${_student.name}?',
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

    if (confirmed != true || _student.id == null) {
      return;
    }

    await DatabaseHelper.instance.deleteStudent(
      _student.id!,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildInfo(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о студенте'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 42,
            child: Text(
              _student.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _student.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfo(
            'ID записи',
            _student.id.toString(),
            Icons.tag,
          ),
          _buildInfo(
            'Возраст',
            '${_student.age} лет',
            Icons.cake_outlined,
          ),
          _buildInfo(
            'Группа',
            _student.group,
            Icons.groups_outlined,
          ),
          _buildInfo(
            'Факультет',
            _student.faculty,
            Icons.school_outlined,
          ),
          _buildInfo(
            'Направление',
            _student.direction,
            Icons.menu_book_outlined,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _editStudent,
            icon: const Icon(Icons.edit),
            label: const Text('Изменить'),
          ),
          OutlinedButton.icon(
            onPressed: _deleteStudent,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
