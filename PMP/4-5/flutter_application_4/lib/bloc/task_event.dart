import 'package:equatable/equatable.dart';

import '../models/app_user.dart';
import '../models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TasksSubscriptionRequested extends TaskEvent {
  const TasksSubscriptionRequested();
}

class TasksDataChanged extends TaskEvent {
  const TasksDataChanged();
}

class TaskFilterSelected extends TaskEvent {
  final String filter;

  const TaskFilterSelected(this.filter);

  @override
  List<Object?> get props => [filter];
}

class TaskFavoriteToggled extends TaskEvent {
  final String taskKey;

  const TaskFavoriteToggled(this.taskKey);

  @override
  List<Object?> get props => [taskKey];
}

class TaskDeleted extends TaskEvent {
  final String taskKey;

  const TaskDeleted(this.taskKey);

  @override
  List<Object?> get props => [taskKey];
}

class TaskSaved extends TaskEvent {
  final String taskKey;
  final Task task;

  const TaskSaved(this.taskKey, this.task);

  @override
  List<Object?> get props => [taskKey, task];
}

class UserSwitched extends TaskEvent {
  final AppUser user;

  const UserSwitched(this.user);

  @override
  List<Object?> get props => [user];
}
