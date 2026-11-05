import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import '../services/hive_service.dart';
import '../widgets/task_card_widget.dart';
import 'task_form_screen.dart';
import 'favorites_screen.dart';
import 'user_switch_screen.dart';
import 'hive_demo_screen.dart';
import 'task_list_screen.dart';

class HiveTasksScreen extends StatefulWidget {
  const HiveTasksScreen({super.key});

  @override
  State<HiveTasksScreen> createState() => _HiveTasksScreenState();
}

class _HiveTasksScreenState extends State<HiveTasksScreen> {
  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (mounted) setState(() {});
  }

  Future<void> _edit(String key, Task task) async {
  final user = HiveService.currentUser;

  if (user == null || !user.canManageTasks) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('У вас нет прав на редактирование задач'),
      ),
    );
    return;
  }

  await _open(TaskFormScreen(taskKey: key, task: task));
}
  Future<void> _add() async {
    await _open(const TaskFormScreen());
  }

  Future<void> _delete(String key) async {
    await HiveService.tasks.delete(key);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задача удалена')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = HiveService.currentUser;
    final canManage = user?.canManageTasks ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            tooltip: 'Пользователь',
            onPressed: () => _open(const UserSwitchScreen()),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: 'Избранное',
            onPressed: () => _open(const FavoritesScreen()),
            icon: const Icon(Icons.favorite),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'demo') {
                _open(const HiveDemoScreen());
              } else if (value == 'old') {
                _open(const TaskListScreen());
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
              onPressed: _add,
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
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: HiveService.tasks.listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text('Задач пока нет'),
                  );
                }

                final entries = box.toMap().entries.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final key = entry.key.toString();
                    final task = entry.value;
                    final isFavorite =
                        HiveService.isFavorite(key);

                    return Column(
                      children: [
                        TaskCardWidget(
                          task: task,
                          onTap: () => _edit(key, task),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Убрать из избранного'
                                  : 'В избранное',
                              onPressed: () async {
                                await HiveService.toggleFavorite(key);
                                if (mounted) setState(() {});
                              },
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
                                onPressed: () => _edit(key, task),
                                icon: const Icon(Icons.edit),
                              ),
                            if (canManage)
                              IconButton(
                                tooltip: 'Удалить',
                                onPressed: () => _delete(key),
                                icon: const Icon(Icons.delete_outline),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}