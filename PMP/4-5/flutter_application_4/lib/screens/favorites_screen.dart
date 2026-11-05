import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import '../services/hive_service.dart';
import '../widgets/task_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ValueListenableBuilder<Box<String>>(
        valueListenable: HiveService.favorites.listenable(),
        builder: (context, favoritesBox, _) {
          final favoriteTasks = HiveService.getFavoriteTasks();

          if (favoriteTasks.isEmpty) {
            return const Center(
              child: Text('В избранном пока ничего нет'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteTasks.length,
            itemBuilder: (context, index) {
              final entry = favoriteTasks[index];
              final String key = entry.key;
              final Task task = entry.value;

              return Column(
                children: [
                  TaskCardWidget(
                    task: task,
                    onTap: () {},
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        await HiveService.toggleFavorite(key);
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                      ),
                      label: const Text('Убрать из избранного'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}