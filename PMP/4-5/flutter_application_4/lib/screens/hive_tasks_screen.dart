import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../models/task_model.dart';
import '../widgets/task_card_widget.dart';
import 'task_form_screen.dart';
import 'favorites_screen.dart';
import 'user_switch_screen.dart';
import 'hive_demo_screen.dart';
import 'task_list_screen.dart';

class HiveTasksScreen extends StatelessWidget {
  const HiveTasksScreen({super.key});

  Future<void> _open(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _edit(
    BuildContext context,
    String key,
    Task task,
  ) {
    final canManage = context.read<TaskBloc>().state.canManage;

    if (!canManage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('У вас нет прав на редактирование задач'),
        ),
      );
      return;
    }

    _open(context, TaskFormScreen(taskKey: key, task: task));
  }

  void _delete(BuildContext context, String key) {
    // Отправка события без ожидания результата и без перерисовки —
    // результат (успех/ошибка) обрабатывается в BlocListener ниже.
    context.read<TaskBloc>().add(TaskDeleted(key));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      // Реагируем только на завершение действий «удаление задачи» —
      // это side effect (снекбар), а не перерисовка списка.
      listenWhen: (previous, current) =>
          current.actionKind == TaskActionKind.taskDeleted &&
          current.actionStatus != TaskActionStatus.idle &&
          (previous.actionStatus != current.actionStatus ||
              previous.actionMessage != current.actionMessage),
      listener: (context, state) {
        if (state.actionStatus == TaskActionStatus.success ||
            state.actionStatus == TaskActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage ?? '')),
          );
        }
      },
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final user = state.currentUser;
          final canManage = state.canManage;
          final entries = state.allTasks;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Задачи'),
              actions: [
                IconButton(
                  tooltip: 'Пользователь',
                  onPressed: () => _open(context, const UserSwitchScreen()),
                  icon: const Icon(Icons.person),
                ),
                IconButton(
                  tooltip: 'Избранное',
                  onPressed: () => _open(context, const FavoritesScreen()),
                  icon: const Icon(Icons.favorite),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'demo') {
                      _open(context, const HiveDemoScreen());
                    } else if (value == 'old') {
                      _open(context, const TaskListScreen());
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'demo',
                      child: Text('Шифрование и сжатие'),
                    ),
                    PopupMenuItem(
                      value: 'old',
                      child: Text('Интерфейс лабораторной № 6'),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: canManage
                ? FloatingActionButton(
                    onPressed: () => _open(context, const TaskFormScreen()),
                    child: const Icon(Icons.add),
                  )
                : null,
            body: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.account_circle),
                  ),
                  title: Text(user?.name ?? 'Пользователь не выбран'),
                  subtitle: Text(user?.roleName ?? ''),
                  trailing: const Icon(Icons.storage),
                ),
                const Divider(height: 1),
                if (state.status == TaskStatus.loading && entries.isEmpty)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == TaskStatus.failure)
                  Expanded(
                    child: Center(
                      child: Text(state.errorMessage ?? 'Ошибка загрузки'),
                    ),
                  )
                else
                  Expanded(
                    child: entries.isEmpty
                        ? const Center(child: Text('Задач пока нет'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final key = entry.key;
                              final task = entry.value;
                              final isFavorite = state.isFavorite(key);

                              return Column(
                                children: [
                                  TaskCardWidget(
                                    task: task,
                                    onTap: () => _edit(context, key, task),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        tooltip: isFavorite
                                            ? 'Убрать из избранного'
                                            : 'В избранное',
                                        onPressed: () => context
                                            .read<TaskBloc>()
                                            .add(TaskFavoriteToggled(key)),
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      if (canManage)
                                        IconButton(
                                          tooltip: 'Редактировать',
                                          onPressed: () =>
                                              _edit(context, key, task),
                                          icon: const Icon(Icons.edit),
                                        ),
                                      if (canManage)
                                        IconButton(
                                          tooltip: 'Удалить',
                                          onPressed: () =>
                                              _delete(context, key),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
