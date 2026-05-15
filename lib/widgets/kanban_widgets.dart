import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

// ── Kanban Column ──────────────────────────────────────────────────────────────

class KanbanColumn extends StatelessWidget {
  final String title, status;
  final Color color;
  final List<Task> tasks;
  final void Function(Task, String) onMove;
  final String currentUserInitials;
  const KanbanColumn({
    super.key,
    required this.title, required this.status, required this.color,
    required this.tasks, required this.onMove, required this.currentUserInitials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: Text(title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: kAppBg, borderRadius: BorderRadius.circular(10)),
            child: Text('${tasks.length}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ),
        ]),
        const SizedBox(height: 12),
        ...tasks.map((t) => KanbanCard(key: ValueKey(t.id), task: t, onMove: onMove, currentUserInitials: currentUserInitials)),
      ]),
    );
  }
}

// ── Kanban Card ────────────────────────────────────────────────────────────────

class KanbanCard extends StatelessWidget {
  final Task task;
  final void Function(Task, String) onMove;
  final String currentUserInitials;
  const KanbanCard({super.key, required this.task, required this.onMove, required this.currentUserInitials});

  // Các trạng thái có thể chuyển đến
  static const _statusOptions = [
    ('todo', 'Chờ làm'),
    ('doing', 'Đang làm'),
    ('done', 'Hoàn thành'),
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (task.status) {
      'doing' => kAmber,
      'done'  => kTeal,
      _       => kBorder,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 3, color: borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, children: [
                    Text(task.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMain),
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (task.assignee == currentUserInitials)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 18,
                          icon: const Icon(Icons.swap_horiz, size: 16, color: kTextMuted),
                          tooltip: 'Chuyển trạng thái',
                          onSelected: (s) => onMove(task, s),
                          itemBuilder: (_) => _statusOptions
                              .where((o) => o.$1 != task.status)
                              .map((o) => PopupMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13))))
                              .toList(),
                        ),
                      const Spacer(),
                      AppAvatar(initials: task.assignee,
                          colorIndex: avatarIndex(task.assignee), size: 20),
                    ]),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
