
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskTag {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int backgroundColorValue;

  @HiveField(2)
  final int textColorValue;

  Color get backgroundColor => Color(backgroundColorValue);
  Color get textColor => Color(textColorValue);

  TaskTag({
    required this.label,
    Color? backgroundColor,
    Color? textColor,
    int? backgroundColorValue,
    int? textColorValue,
  })  : backgroundColorValue =
            backgroundColorValue ??
            backgroundColor?.toARGB32() ??
            Colors.white.toARGB32(),
        textColorValue =
            textColorValue ??
            textColor?.toARGB32() ??
            Colors.black.toARGB32();
}

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final List<TaskTag> tags;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final int linksCount;

  @HiveField(4)
  final int commentsCount;

  @HiveField(5)
  final int backgroundColorValue;

  @HiveField(6)
  final bool isDarkText;

  Color get backgroundColor => Color(backgroundColorValue);

  Task({
    required this.title,
    required this.tags,
    required this.date,
    required this.linksCount,
    required this.commentsCount,
    Color backgroundColor = Colors.white,
    this.isDarkText = true,
  }) : backgroundColorValue = backgroundColor.toARGB32();
}
