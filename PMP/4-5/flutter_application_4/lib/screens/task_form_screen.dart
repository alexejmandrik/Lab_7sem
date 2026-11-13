import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final String? taskKey;
  final Task? task;

  const TaskFormScreen({
    super.key,
    this.taskKey,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _linksController;
  late final TextEditingController _commentsController;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    // Контроллеры текстовых полей — это чисто локальное UI-состояние
    // формы (черновик ввода), а не общие данные приложения, поэтому
    // они по-прежнему живут в State, а не в BLoC.
    _titleController = TextEditingController(
      text: task?.title ?? '',
    );
    _dateController = TextEditingController(
      text: task?.date ?? '',
    );
    _linksController = TextEditingController(
      text: '${task?.linksCount ?? 0}',
    );
    _commentsController = TextEditingController(
      text: '${task?.commentsCount ?? 0}',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _linksController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final oldTask = widget.task;

    final task = Task(
      title: _titleController.text.trim(),
      date: _dateController.text.trim(),
      linksCount: int.parse(_linksController.text),
      commentsCount: int.parse(_commentsController.text),
      tags: oldTask?.tags ??
          [
            TaskTag(
              label: 'New',
              backgroundColor: const Color(0xFFE8D7FF),
              textColor: Colors.purple,
            ),
          ],
      backgroundColor: oldTask?.backgroundColor ?? Colors.white,
      isDarkText: oldTask?.isDarkText ?? true,
    );

    final key = widget.taskKey ??
        'task_${DateTime.now().microsecondsSinceEpoch}';

    // Только отправка события — без ожидания и без setState.
    // Навигация назад выполняется в BlocListener, когда BLoC
    // сообщит об успешном сохранении (side effect).
    context.read<TaskBloc>().add(TaskSaved(key, task));
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType:
            numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Заполните поле';
          }

          if (numeric && int.tryParse(value) == null) {
            return 'Введите целое число';
          }

          if (numeric && int.parse(value) < 0) {
            return 'Число не может быть отрицательным';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return BlocListener<TaskBloc, TaskState>(
      // Реагируем только на завершение именно действия «сохранение
      // задачи» — это side effect (навигация/снекбар), не связанный
      // с перерисовкой самой формы.
      listenWhen: (previous, current) =>
          current.actionKind == TaskActionKind.taskSaved &&
          (previous.actionStatus != current.actionStatus ||
              previous.actionMessage != current.actionMessage),
      listener: (context, state) {
        if (state.actionStatus == TaskActionStatus.success) {
          Navigator.pop(context, true);
        } else if (state.actionStatus == TaskActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage ?? 'Ошибка сохранения')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'Редактирование задачи' : 'Новая задача',
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _field('Название', _titleController),
              _field('Дата', _dateController),
              _field('Количество ссылок', _linksController, numeric: true),
              _field(
                'Количество комментариев',
                _commentsController,
                numeric: true,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
