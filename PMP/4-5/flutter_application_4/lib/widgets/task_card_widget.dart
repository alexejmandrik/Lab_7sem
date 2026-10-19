import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/tag_widget.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = task.isDarkText ? Colors.black : Colors.white;
    final Color subTextColor = task.isDarkText ? Colors.grey.shade600 : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.more_horiz, color: textColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: task.tags
                  .map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TagWidget(
                        text: tag.label,
                        bgColor: tag.backgroundColor,
                        textColor: tag.textColor,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
                    const SizedBox(width: 4),
                    Text(task.date, style: TextStyle(color: subTextColor, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.link, size: 16, color: subTextColor),
                    const SizedBox(width: 2),
                    Text('${task.linksCount}', style: TextStyle(color: subTextColor, fontSize: 12)),
                    const SizedBox(width: 8),
                    Icon(Icons.chat_bubble_outline, size: 14, color: subTextColor),
                    const SizedBox(width: 2),
                    Text('${task.commentsCount}', style: TextStyle(color: subTextColor, fontSize: 12)),
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}