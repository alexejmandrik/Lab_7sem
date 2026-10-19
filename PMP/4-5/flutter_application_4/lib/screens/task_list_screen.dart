import 'package:flutter/material.dart';
import '../models/task_model.dart';
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
    final String title;
    final String methodName;
    final String description;

    if (method == 1) {
      title = 'Навигация 1';
      methodName = 'Navigator.push';
      description =
          'Открывает новый экран поверх текущего. '
          'Предыдущая страница остаётся в стеке навигации, '
          'поэтому можно вернуться назад.';
    } else if (method == 2) {
      title = 'Навигация 2';
      methodName = 'Navigator.pushReplacement';
      description =
          'Открывает новый экран и заменяет им текущий. '
          'Предыдущий экран удаляется из стека навигации.';
    } else {
      title = 'Навигация 3';
      methodName = 'Navigator.pushAndRemoveUntil';
      description =
          'Открывает новый экран и удаляет предыдущие '
          'экраны из стека навигации.';
    }

    final page = MaterialPageRoute(
      builder: (context) => NavigationLabScreen(
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
      Navigator.pushAndRemoveUntil(
        context,
        page,
        (route) => false,
      );
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
    final List<Task> tasks = [
      Task(
        title: 'Dashboard design for admin',
        tags: [
          TaskTag(
            label: 'High',
            backgroundColor: Color(0xFFFFD2D2),
            textColor: Colors.red,
          ),
          TaskTag(
            label: 'On Track',
            backgroundColor: Color(0xFFF3D2FF),
            textColor: Colors.purple,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 5,
        commentsCount: 5,
      ),
      Task(
        title: 'Konom web application',
        tags: [
          TaskTag(
            label: 'Low',
            backgroundColor: Color(0xFFD2FFD2),
            textColor: Colors.green,
          ),
          TaskTag(
            label: 'Meeting',
            backgroundColor: Color(0xFFD2DCFF),
            textColor: Colors.indigo,
          ),
        ],
        date: '14 Nov 2022',
        linksCount: 2,
        commentsCount: 4,
      ),
      Task(
        title: 'Research and developement',
        tags: [
          TaskTag(
            label: 'Medium',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
          TaskTag(
            label: 'At Risk',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 6,
        commentsCount: 2,
        backgroundColor: Color(0xFF4CAF50),
        isDarkText: false,
      ),
      Task(
        title: 'Event booking application',
        tags: [
          TaskTag(
            label: 'Medium',
            backgroundColor: Color(0xFFFFE0B2),
            textColor: Colors.orange,
          ),
          TaskTag(
            label: 'Meeting',
            backgroundColor: Color(0xFFD2DCFF),
            textColor: Colors.indigo,
          ),
        ],
        date: '14 oct 2022',
        linksCount: 5,
        commentsCount: 5,
      ),
    ];

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
                          color: Color(0xFFE8D7FF),
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.reply,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.black87,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipWidget(
                          label: 'Complete',
                          count: '65',
                          isSelected: true,
                          badgeColor: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        FilterChipWidget(
                          label: 'To Do',
                          count: '45',
                          isSelected: false,
                          badgeColor: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        FilterChipWidget(
                          label: 'In Review',
                          count: '3',
                          isSelected: false,
                          badgeColor: Colors.purple.shade200,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ...tasks.map(
                          (task) => TaskCardWidget(
                            task: task,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TaskDetailsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Лабораторная работа № 6',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        labButton(
                          context,
                          'Навигация 1 — push',
                          Icons.looks_one,
                          () => openNavigation(context, 1),
                        ),
                        labButton(
                          context,
                          'Навигация 2 — pushReplacement',
                          Icons.looks_two,
                          () => openNavigation(context, 2),
                        ),
                        labButton(
                          context,
                          'Навигация 3 — pushAndRemoveUntil',
                          Icons.looks_3,
                          () => openNavigation(context, 3),
                        ),
                        labButton(
                          context,
                          'PageView',
                          Icons.view_carousel_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PageViewScreen(),
                              ),
                            );
                          },
                        ),
                        labButton(
                          context,
                          'Информация об устройстве',
                          Icons.phone_android,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeviceInfoScreen(),
                              ),
                            );
                          },
                        ),
                        labButton(
                          context,
                          'Открыть карту',
                          Icons.map_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MapScreen(),
                              ),
                            );
                          },
                        ),
                        labButton(
                          context,
                          'Сделать фото',
                          Icons.camera_alt_outlined,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CameraScreen(),
                              ),
                            );
                          },
                        ),
                      ],
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
                backgroundColor: Color(0xFFE8D7FF),
                elevation: 3,
                child: const Icon(
                  Icons.add,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.grey,
                      ),
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
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