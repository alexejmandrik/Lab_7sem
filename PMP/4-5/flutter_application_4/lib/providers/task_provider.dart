import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';

class TaskProvider extends ChangeNotifier {
  static const List<String> filters = ['Complete', 'To Do', 'In Review'];

  late final ValueListenable<Box<Task>> _tasksListenable;
  late final ValueListenable<Box<String>> _favoritesListenable;
  late final ValueListenable<Box<AppUser>> _usersListenable;
  late final ValueListenable<Box<String>> _settingsListenable;

  String _selectedFilter = 'Complete';

  TaskProvider() {
    _tasksListenable = HiveService.tasks.listenable();
    _favoritesListenable = HiveService.favorites.listenable();
    _usersListenable = HiveService.users.listenable();
    _settingsListenable = HiveService.settings.listenable();

    _tasksListenable.addListener(_onHiveChanged);
    _favoritesListenable.addListener(_onHiveChanged);
    _usersListenable.addListener(_onHiveChanged);
    _settingsListenable.addListener(_onHiveChanged);
  }

  void _onHiveChanged() => notifyListeners();

  String get selectedFilter => _selectedFilter;

  void selectFilter(String filter) {
    if (!filters.contains(filter) || filter == _selectedFilter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  List<MapEntry<String, Task>> get allTasks {
    return HiveService.tasks.toMap().entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList();
  }

  String statusFor(String key) {
    switch (key) {
      case 'task2':
        return 'To Do';
      case 'task3':
        return 'In Review';
      default:
        return 'Complete';
    }
  }

  List<MapEntry<String, Task>> get filteredTasks {
    return allTasks
        .where((entry) => statusFor(entry.key) == _selectedFilter)
        .toList();
  }

  int countFor(String filter) {
    return allTasks.where((entry) => statusFor(entry.key) == filter).length;
  }

  bool isFavorite(String key) => HiveService.isFavorite(key);

  List<MapEntry<String, Task>> get favoriteTasks =>
      HiveService.getFavoriteTasks();

  Future<void> toggleFavorite(String key) async {
    await HiveService.toggleFavorite(key);
  }

  Future<void> deleteTask(String key) async {
    await HiveService.tasks.delete(key);
  }

  Future<void> saveTask(String key, Task task) async {
    await HiveService.tasks.put(key, task);
  }

  AppUser? get currentUser => HiveService.currentUser;

  Future<void> switchUser(AppUser user) async {
    await HiveService.switchUser(user);
  }

  @override
  void dispose() {
    _tasksListenable.removeListener(_onHiveChanged);
    _favoritesListenable.removeListener(_onHiveChanged);
    _usersListenable.removeListener(_onHiveChanged);
    _settingsListenable.removeListener(_onHiveChanged);
    super.dispose();
  }
}
