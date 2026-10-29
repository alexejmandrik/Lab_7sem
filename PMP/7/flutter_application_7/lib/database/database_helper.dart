
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/student.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'university_students.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(
      databasesPath,
      _databaseName,
    );

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            student_group TEXT NOT NULL,
            faculty TEXT NOT NULL,
            direction TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;

    final result = await db.query(
      'students',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return result.map(Student.fromMap).toList();
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;

    final data = student.toMap()
      ..remove('id');

    return db.insert('students', data);
  }

  Future<int> updateStudent(Student student) async {
    if (student.id == null) {
      throw ArgumentError(
        'У студента отсутствует идентификатор.',
      );
    }

    final db = await database;

    final data = student.toMap()
      ..remove('id');

    return db.update(
      'students',
      data,
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;

    return db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
