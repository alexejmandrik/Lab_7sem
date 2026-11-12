import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteTasks = context.watch<TaskProvider>().favoriteTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favoriteTasks.isEmpty
          ? const Center(child: Text('В избранном пока ничего нет'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteTasks.length,
              itemBuilder: (context, index) {
                final entry = favoriteTasks[index];
                return Column(
                  children: [
                    TaskCardWidget(task: entry.value, onTap: () {}),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context
                            .read<TaskProvider>()
                            .toggleFavorite(entry.key),
                        icon: const Icon(Icons.favorite, color: Colors.pink),
                        label: const Text('Убрать из избранного'),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
