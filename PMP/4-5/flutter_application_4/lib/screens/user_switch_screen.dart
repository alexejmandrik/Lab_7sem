import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../models/app_user.dart';

class UserSwitchScreen extends StatelessWidget {
  const UserSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      // Side effect: как только смена пользователя завершилась
      // успешно, закрываем экран выбора — это и есть навигация,
      // вызванная изменением состояния, а не прямым действием UI.
      listenWhen: (previous, current) =>
          current.actionKind == TaskActionKind.userSwitched &&
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TaskActionStatus.success) {
          Navigator.pop(context);
        } else if (state.actionStatus == TaskActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage ?? 'Ошибка')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Выбор пользователя')),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final users = state.allUsers;
            final currentId = state.currentUser?.id;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final selected = user.id == currentId;

                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      user.role == UserRole.admin
                          ? Icons.admin_panel_settings
                          : user.role == UserRole.manager
                              ? Icons.manage_accounts
                              : Icons.person,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.roleName),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () =>
                      context.read<TaskBloc>().add(UserSwitched(user)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
