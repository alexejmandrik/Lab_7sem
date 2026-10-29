
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({
    super.key,
    this.student,
  });

  @override
  State<StudentFormScreen> createState() =>
      _StudentFormScreenState();
}

class _StudentFormScreenState
    extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _groupController;
  late final TextEditingController _facultyController;
  late final TextEditingController _directionController;

  bool _saving = false;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();

    final student = widget.student;

    _nameController = TextEditingController(
      text: student?.name ?? '',
    );

    _ageController = TextEditingController(
      text: student?.age.toString() ?? '',
    );

    _groupController = TextEditingController(
      text: student?.group ?? '',
    );

    _facultyController = TextEditingController(
      text: student?.faculty ?? '',
    );

    _directionController = TextEditingController(
      text: student?.direction ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _groupController.dispose();
    _facultyController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполни это поле';
    }

    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введи возраст';
    }

    final age = int.tryParse(value.trim());

    if (age == null) {
      return 'Возраст должен быть целым числом';
    }

    if (age < 1 || age > 120) {
      return 'Возраст должен быть от 1 до 120';
    }

    return null;
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        group: _groupController.text.trim(),
        faculty: _facultyController.text.trim(),
        direction: _directionController.text.trim(),
      );

      if (_isEditing) {
        await DatabaseHelper.instance.updateStudent(
          student,
        );
      } else {
        await DatabaseHelper.instance.insertStudent(
          student,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Изменение студента'
              : 'Добавление студента',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ФИО студента',
                prefixIcon: Icon(Icons.person),
              ),
              validator: _validateRequired,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Возраст',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: _validateAge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _groupController,
              decoration: const InputDecoration(
                labelText: 'Учебная группа',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facultyController,
              decoration: const InputDecoration(
                labelText: 'Факультет',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _directionController,
              decoration: const InputDecoration(
                labelText: 'Направление обучения',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _saveStudent,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _saving ? 'Сохранение...' : 'Сохранить',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
