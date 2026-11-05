import 'package:hive/hive.dart';

part 'app_user.g.dart';

@HiveType(typeId: 2)
enum UserRole {
  @HiveField(0)
  admin,

  @HiveField(1)
  manager,

  @HiveField(2)
  user,
}

@HiveType(typeId: 3)
class AppUser {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
  });

  String get roleName {
    switch (role) {
      case UserRole.admin:
        return 'Администратор';
      case UserRole.manager:
        return 'Менеджер';
      case UserRole.user:
        return 'Пользователь';
    }
  }

  bool get canManageTasks =>
      role == UserRole.admin || role == UserRole.manager;
}