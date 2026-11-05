
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/task_model.dart';
import 'models/app_user.dart';
import 'services/hive_service.dart';
import 'screens/hive_tasks_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    // Регистрация адаптеров Hive
    Hive.registerAdapter(TaskTagAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(UserRoleAdapter());
    Hive.registerAdapter(AppUserAdapter());

    await HiveService.init();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('STARTUP ERROR: $e');
    debugPrint('$stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ошибка запуска приложения:\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
      ),
      home: const HiveTasksScreen(),
    );
  }
}
