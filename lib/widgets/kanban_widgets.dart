import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

// ── Kanban Column ──────────────────────────────────────────────────────────────

class KanbanColumn extends StatelessWidget {
  final String title, status;
  final Color color;
  final List<Task> tasks;
  final void Function(Task, String) onMove;
  final double? fixedWidth;
  const KanbanColumn({
    super.key,
    required this.title, required this.status, required this.color,
    required this.tasks, required this.onMove, this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAcceptWithDetails: (d) => onMove(d.data, status),
      builder: (_, candidates, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: fixedWidth ?? double.infinity,
        constraints: fixedWidth != null ? BoxConstraints(maxWidth: fixedWidth!) : null,
        decoration: BoxDecoration(
          color: candidates.isNotEmpty ? kAccentLight : kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: candidates.isNotEmpty ? kAccent : kBorder,
              width: candidates.isNotEmpty ? 1.5 : 0.5),
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
          ...tasks.map((t) => KanbanCard(key: ValueKey(t.id), task: t)),
        ]),
      ),
    );
  }
}

// ── Kanban Card ────────────────────────────────────────────────────────────────

class KanbanCard extends StatelessWidget {
  final Task task;
  const KanbanCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 280, child: _card(dragging: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: _card()),
      child: _card(),
    );
  }

  Widget _card({bool dragging = false}) {
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
