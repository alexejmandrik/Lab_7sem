import 'package:equatable/equatable.dart';

import '../models/app_user.dart';
import '../models/task_model.dart';

/// Статус загрузки списка задач: демонстрирует асинхронные
/// переходы loading -> success / error, как того требует задание.
enum TaskStatus { initial, loading, success, failure }

/// Статус последнего «действия» (сохранение/удаление задачи,
/// переключение избранного, смена пользователя). Отдельный статус
/// нужен, чтобы экраны могли реагировать на side-effects
/// (навигация, снекбары) через BlocListener, не путая их с
/// обновлением самого списка задач.
enum TaskActionStatus { idle, inProgress, success, failure }

/// Какое именно действие сейчас отражено в [TaskActionStatus].
enum TaskActionKind {
  none,
  favoriteToggled,
  taskDeleted,
  taskSaved,
  userSwitched,
}

/// Неизменяемое состояние экрана задач. Полностью заменяет собой
/// то, что раньше хранил `TaskProvider` (ChangeNotifier).
class TaskState extends Equatable {
  static const List<String> filters = ['Complete', 'To Do', 'In Review'];

  final TaskStatus status;
  final List<MapEntry<String, Task>> allTasks;
  final String selectedFilter;
  final Set<String> favoriteKeys;
  final AppUser? currentUser;
  final List<AppUser> allUsers;
  final String? errorMessage;

  final TaskActionStatus actionStatus;
  final TaskActionKind actionKind;
  final String? actionMessage;

  const TaskState({
    this.status = TaskStatus.initial,
    this.allTasks = const [],
    this.selectedFilter = 'Complete',
    this.favoriteKeys = const {},
    this.currentUser,
    this.allUsers = const [],
    this.errorMessage,
    this.actionStatus = TaskActionStatus.idle,
    this.actionKind = TaskActionKind.none,
    this.actionMessage,
  });

  static String statusFor(String key) {
    switch (key) {
      case 'task2':
        return 'To Do';
      case 'task3':
        return 'In Review';
      default:
        return 'Complete';
    }
  }

  List<MapEntry<String, Task>> get filteredTasks => allTasks
      .where((entry) => statusFor(entry.key) == selectedFilter)
      .toList();

  int countFor(String filter) =>
      allTasks.where((entry) => statusFor(entry.key) == filter).length;

  bool isFavorite(String key) => favoriteKeys.contains(key);

  List<MapEntry<String, Task>> get favoriteTasks =>
      allTasks.where((entry) => favoriteKeys.contains(entry.key)).toList();

  bool get canManage => currentUser?.canManageTasks ?? false;

  bool get isLoading => status == TaskStatus.loading;

  TaskState copyWith({
    TaskStatus? status,
    List<MapEntry<String, Task>>? allTasks,
    String? selectedFilter,
    Set<String>? favoriteKeys,
    AppUser? currentUser,
    bool clearUser = false,
    List<AppUser>? allUsers,
    String? errorMessage,
    bool clearError = false,
    TaskActionStatus? actionStatus,
    TaskActionKind? actionKind,
    String? actionMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      favoriteKeys: favoriteKeys ?? this.favoriteKeys,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      allUsers: allUsers ?? this.allUsers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionStatus: actionStatus ?? this.actionStatus,
      actionKind: actionKind ?? this.actionKind,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTasks,
        selectedFilter,
        favoriteKeys,
        currentUser,
        allUsers,
        errorMessage,
        actionStatus,
        actionKind,
        actionMessage,
      ];
}
