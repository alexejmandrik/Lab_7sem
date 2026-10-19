import 'package:flutter/material.dart';
import 'task_list_screen.dart';

class NavigationLabScreen extends StatelessWidget {
  final String title;
  final String method;
  final String description;

  const NavigationLabScreen({
    super.key,
    required this.title,
    required this.method,
    required this.description,
  });

  void returnToTasks(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const TaskListScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE8D7FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              returnToTasks(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Детальная информация',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.label_outline,
                  color: Colors.purple,
                ),
                title: const Text('Название'),
                subtitle: Text(title),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.code,
                  color: Colors.purple,
                ),
                title: const Text('Метод навигации'),
                subtitle: Text(method),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: Colors.purple,
                ),
                title: const Text('Описание'),
                subtitle: Text(description),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    returnToTasks(context);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Вернуться назад'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => returnToTasks(context),
                icon: const Icon(Icons.home_outlined),
                label: const Text('На главную'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}