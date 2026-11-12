import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
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

  Future<void> _edit(
    BuildContext context,
    String key,
    Task task,
  ) async {
    final user = context.read<TaskProvider>().currentUser;

    if (user == null || !user.canManageTasks) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('У вас нет прав на редактирование задач'),
        ),
      );
      return;
    }

    await _open(context, TaskFormScreen(taskKey: key, task: task));
  }

  Future<void> _delete(BuildContext context, String key) async {
    await context.read<TaskProvider>().deleteTask(key);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Задача удалена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Подписка на общее состояние: экран обновится при изменениях в Hive.
    final provider = context.watch<TaskProvider>();
    final user = provider.currentUser;
    final canManage = user?.canManageTasks ?? false;
    final entries = provider.allTasks;

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
                      final isFavorite = provider.isFavorite(key);

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
                                    .read<TaskProvider>()
                                    .toggleFavorite(key),
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
                                  onPressed: () => _edit(context, key, task),
                                  icon: const Icon(Icons.edit),
                                ),
                              if (canManage)
                                IconButton(
                                  tooltip: 'Удалить',
                                  onPressed: () => _delete(context, key),
                                  icon: const Icon(Icons.delete_outline),
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
  }
}
