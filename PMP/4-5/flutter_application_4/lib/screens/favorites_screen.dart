import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final favoriteTasks = state.favoriteTasks;

          if (favoriteTasks.isEmpty) {
            return const Center(child: Text('В избранном пока ничего нет'));
          }

          return ListView.builder(
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
                          .read<TaskBloc>()
                          .add(TaskFavoriteToggled(entry.key)),
                      icon: const Icon(Icons.favorite, color: Colors.pink),
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
