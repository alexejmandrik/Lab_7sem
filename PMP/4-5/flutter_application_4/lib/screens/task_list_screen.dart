import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/task_card_widget.dart';
import 'task_details_screen.dart';
import 'navigation_lab_screen.dart';
import 'page_view_screen.dart';
import 'device_info_screen.dart';
import 'camera_screen.dart';
import 'map_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  void openNavigation(BuildContext context, int method) {
    final title = 'Навигация $method';
    final methodName = method == 1
        ? 'Navigator.push'
        : method == 2
            ? 'Navigator.pushReplacement'
            : 'Navigator.pushAndRemoveUntil';
    final description = method == 1
        ? 'Открывает новый экран поверх текущего. Предыдущая страница остаётся в стеке навигации.'
        : method == 2
            ? 'Открывает новый экран и заменяет им текущий.'
            : 'Открывает новый экран и удаляет предыдущие экраны из стека навигации.';

    final page = MaterialPageRoute(
      builder: (_) => NavigationLabScreen(
        title: title,
        method: methodName,
        description: description,
      ),
    );

    if (method == 1) {
      Navigator.push(context, page);
    } else if (method == 2) {
      Navigator.pushReplacement(context, page);
    } else {
      Navigator.pushAndRemoveUntil(context, page, (_) => false);
    }
  }

  Widget labButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(title),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.purple,
            side: const BorderSide(color: Color(0xFFE8D7FF)),
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D7FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.view_agenda_outlined,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      const Text(
                        'Task List',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.reply, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const _TaskFilters(),

                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _TaskItems(),
                          const SizedBox(height: 12),
                          const Text(
                            'Лабораторная работа № 6',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          labButton(context, 'Навигация 1 — push', Icons.looks_one,
                              () => openNavigation(context, 1)),
                          labButton(context, 'Навигация 2 — pushReplacement',
                              Icons.looks_two, () => openNavigation(context, 2)),
                          labButton(context, 'Навигация 3 — pushAndRemoveUntil',
                              Icons.looks_3, () => openNavigation(context, 3)),
                          labButton(context, 'PageView', Icons.view_carousel_outlined,
                              () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const PageViewScreen()));
                          }),
                          labButton(context, 'Информация об устройстве',
                              Icons.phone_android, () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const DeviceInfoScreen()));
                          }),
                          labButton(context, 'Открыть карту', Icons.map_outlined, () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const MapScreen()));
                          }),
                          labButton(context, 'Сделать фото', Icons.camera_alt_outlined,
                              () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CameraScreen()));
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 80,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: const Color(0xFFE8D7FF),
                elevation: 3,
                child: const Icon(Icons.add, color: Colors.purple, size: 30),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.grid_view_rounded, color: Colors.grey),
                    Text('Task', style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.bar_chart_rounded, color: Colors.grey),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: TaskState.filters.map((filter) {
              final selected = state.selectedFilter == filter;
              final badgeColor = filter == 'Complete'
                  ? Colors.green
                  : filter == 'To Do'
                      ? Colors.grey.shade600
                      : Colors.purple.shade200;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      context.read<TaskBloc>().add(TaskFilterSelected(filter)),
                  child: FilterChipWidget(
                    label: filter,
                    count: '${state.countFor(filter)}',
                    isSelected: selected,
                    badgeColor: badgeColor,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _TaskItems extends StatelessWidget {
  const _TaskItems();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final tasks = state.filteredTasks;

        if (tasks.isEmpty) {
          return const Center(child: Text('В этой категории пока нет задач'));
        }

        return Column(
          children: tasks.map((entry) {
            return TaskCardWidget(
              task: entry.value,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TaskDetailsScreen(),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
