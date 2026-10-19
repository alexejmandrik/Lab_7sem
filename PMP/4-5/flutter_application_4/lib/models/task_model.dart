import 'package:flutter/material.dart';

class TaskTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  TaskTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

class Task {
  final String title;
  final List<TaskTag> tags;
  final String date;
  final int linksCount;
  final int commentsCount;
  final Color backgroundColor;
  final bool isDarkText;

  Task({
    required this.title,
    required this.tags,
    required this.date,
    required this.linksCount,
    required this.commentsCount,
    this.backgroundColor = Colors.white,
    this.isDarkText = true,
  });
}