import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../services/hive_service.dart';

class UserSwitchScreen extends StatelessWidget {
  const UserSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: ValueListenableBuilder<Box<AppUser>>(
        valueListenable: HiveService.users.listenable(),
        builder: (context, box, _) {
          final users = box.values.toList();
          final currentId = HiveService.currentUser?.id;

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
                onTap: () async {
                  await HiveService.switchUser(user);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}