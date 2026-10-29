
import 'package:flutter/material.dart';
import 'screens/student_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniversityStudentsApp());
}

class UniversityStudentsApp extends StatelessWidget {
  const UniversityStudentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Студенты университета',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const StudentListScreen(),
    );
  }
}
