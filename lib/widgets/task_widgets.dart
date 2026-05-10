import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const FilterTab({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? kAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? null : Border.all(color: kBorder, width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : kTextMain)),
    ),
  );
}

class TaskHeaderCell extends StatelessWidget {
  final String text;
  const TaskHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMuted));
}

class TaskRow extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const TaskRow({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final st  = statusStyle(task.status);
    final isOverdue = task.deadline == 'Hôm nay';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Expanded(
          flex: 5,
          child: Row(children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.status == 'done' ? kTeal : Colors.transparent,
                  border: Border.all(
                      color: task.status == 'done' ? kTeal : const Color(0xFFCCCBC6), width: 1.5),
                ),
                child: task.status == 'done'
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(task.title, style: const TextStyle(fontSize: 13, color: kTextMain)),
          ]),
        ),
        Expanded(flex: 2, child: AppBadge(label: st.label, bg: st.bg, fg: st.fg)),
        Expanded(
          flex: 2,
          child: Text(task.deadline,
              style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? kCoral : kTextMain,
                  fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal)),
        ),
        Expanded(
          flex: 2,
          child: AppAvatar(initials: task.assignee, colorIndex: avatarIndex(task.assignee)),
        ),
      ]),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final st  = statusStyle(task.status);
    final isOverdue = task.deadline == 'Hôm nay';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.status == 'done' ? kTeal : Colors.transparent,
                border: Border.all(
                    color: task.status == 'done' ? kTeal : const Color(0xFFCCCBC6), width: 1.5),
              ),
              child: task.status == 'done'
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(task.title, style: const TextStyle(fontSize: 13, color: kTextMain))),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          AppBadge(label: st.label, bg: st.bg, fg: st.fg),
          Text(task.deadline,
              style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? kCoral : kTextMain,
                  fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal)),
          AppAvatar(initials: task.assignee, colorIndex: avatarIndex(task.assignee), size: 20),
        ]),
      ]),
    );
  }
}
