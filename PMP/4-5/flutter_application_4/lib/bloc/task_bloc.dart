import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC, управляющий всем общим (разделяемым) состоянием приложения:
/// списком задач, фильтром, избранным и текущим пользователем.
///
/// Полностью заменяет собой `TaskProvider` из лабораторной работы №9.
/// Данные продолжают храниться в Hive (через [HiveService]) — меняется
/// только способ, которым UI подписывается на изменения и отправляет
/// команды: вместо `ChangeNotifier`/`Provider` используются
/// `Event` -> `Bloc` -> `State`.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  late final ValueListenable<Box<Task>> _tasksListenable;
  late final ValueListenable<Box<String>> _favoritesListenable;
  late final ValueListenable<Box<AppUser>> _usersListenable;
  late final ValueListenable<Box<String>> _settingsListenable;

  late final void Function() _hiveListener;

  TaskBloc() : super(const TaskState()) {
    on<TasksSubscriptionRequested>(_onSubscriptionRequested);
    on<TasksDataChanged>(_onDataChanged);
    on<TaskFilterSelected>(_onFilterSelected);
    on<TaskFavoriteToggled>(_onFavoriteToggled);
    on<TaskDeleted>(_onTaskDeleted);
    on<TaskSaved>(_onTaskSaved);
    on<UserSwitched>(_onUserSwitched);

    _tasksListenable = HiveService.tasks.listenable();
    _favoritesListenable = HiveService.favorites.listenable();
    _usersListenable = HiveService.users.listenable();
    _settingsListenable = HiveService.settings.listenable();

    // Любое изменение в Hive (в т.ч. из других частей приложения)
    // должно немедленно отразиться в состоянии BLoC.
    _hiveListener = () => add(const TasksDataChanged());

    _tasksListenable.addListener(_hiveListener);
    _favoritesListenable.addListener(_hiveListener);
    _usersListenable.addListener(_hiveListener);
    _settingsListenable.addListener(_hiveListener);
  }

  Future<void> _onSubscriptionRequested(
    TasksSubscriptionRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      // Имитация асинхронной загрузки (например, из БД/сети), чтобы
      // явно продемонстрировать состояния loading / success / error.
      await Future.delayed(const Duration(milliseconds: 300));

      emit(
        state.copyWith(
          status: TaskStatus.success,
          allTasks: _readAllTasks(),
          favoriteKeys: _readFavoriteKeys(),
          currentUser: HiveService.currentUser,
          clearUser: HiveService.currentUser == null,
          allUsers: _readAllUsers(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: 'Не удалось загрузить задачи: $e',
        ),
      );
    }
  }

  void _onDataChanged(TasksDataChanged event, Emitter<TaskState> emit) {
    emit(
      state.copyWith(
        status: TaskStatus.success,
        allTasks: _readAllTasks(),
        favoriteKeys: _readFavoriteKeys(),
        currentUser: HiveService.currentUser,
        clearUser: HiveService.currentUser == null,
        allUsers: _readAllUsers(),
      ),
    );
  }

  void _onFilterSelected(TaskFilterSelected event, Emitter<TaskState> emit) {
    if (!TaskState.filters.contains(event.filter) ||
        event.filter == state.selectedFilter) {
      return;
    }
    emit(state.copyWith(selectedFilter: event.filter));
  }

  Future<void> _onFavoriteToggled(
    TaskFavoriteToggled event,
    Emitter<TaskState> emit,
  ) async {
    final wasFavorite = HiveService.isFavorite(event.taskKey);

    emit(
      state.copyWith(
        actionStatus: TaskActionStatus.inProgress,
        actionKind: TaskActionKind.favoriteToggled,
      ),
    );

    try {
      await HiveService.toggleFavorite(event.taskKey);

      emit(
        state.copyWith(
          favoriteKeys: _readFavoriteKeys(),
          actionStatus: TaskActionStatus.success,
          actionKind: TaskActionKind.favoriteToggled,
          actionMessage: wasFavorite
              ? 'Убрано из избранного'
              : 'Добавлено в избранное',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: TaskActionStatus.failure,
          actionKind: TaskActionKind.favoriteToggled,
          actionMessage: 'Не удалось изменить избранное: $e',
        ),
      );
    }
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: TaskActionStatus.inProgress,
        actionKind: TaskActionKind.taskDeleted,
      ),
    );

    try {
      await HiveService.tasks.delete(event.taskKey);

      emit(
        state.copyWith(
          allTasks: _readAllTasks(),
          actionStatus: TaskActionStatus.success,
          actionKind: TaskActionKind.taskDeleted,
          actionMessage: 'Задача удалена',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: TaskActionStatus.failure,
          actionKind: TaskActionKind.taskDeleted,
          actionMessage: 'Не удалось удалить задачу: $e',
        ),
      );
    }
  }

  Future<void> _onTaskSaved(
    TaskSaved event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: TaskActionStatus.inProgress,
        actionKind: TaskActionKind.taskSaved,
      ),
    );

    try {
      await HiveService.tasks.put(event.taskKey, event.task);

      emit(
        state.copyWith(
          allTasks: _readAllTasks(),
          actionStatus: TaskActionStatus.success,
          actionKind: TaskActionKind.taskSaved,
          actionMessage: 'Задача сохранена',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: TaskActionStatus.failure,
          actionKind: TaskActionKind.taskSaved,
          actionMessage: 'Не удалось сохранить задачу: $e',
        ),
      );
    }
  }

  Future<void> _onUserSwitched(
    UserSwitched event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: TaskActionStatus.inProgress,
        actionKind: TaskActionKind.userSwitched,
      ),
    );

    try {
      await HiveService.switchUser(event.user);

      emit(
        state.copyWith(
          currentUser: HiveService.currentUser,
          actionStatus: TaskActionStatus.success,
          actionKind: TaskActionKind.userSwitched,
          actionMessage: 'Текущий пользователь: ${event.user.name}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: TaskActionStatus.failure,
          actionKind: TaskActionKind.userSwitched,
          actionMessage: 'Не удалось сменить пользователя: $e',
        ),
      );
    }
  }

  List<MapEntry<String, Task>> _readAllTasks() {
    return HiveService.tasks.toMap().entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value))
        .toList();
  }

  Set<String> _readFavoriteKeys() {
    return HiveService.favorites.keys.map((key) => key.toString()).toSet();
  }

  List<AppUser> _readAllUsers() {
    return HiveService.users.values.toList();
  }

  @override
  Future<void> close() {
    _tasksListenable.removeListener(_hiveListener);
    _favoritesListenable.removeListener(_hiveListener);
    _usersListenable.removeListener(_hiveListener);
    _settingsListenable.removeListener(_hiveListener);
    return super.close();
  }
}
