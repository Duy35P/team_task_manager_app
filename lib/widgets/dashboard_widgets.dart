import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class StatCard extends StatelessWidget {
  final String num, label, badge;
  final Color badgeBg, badgeFg;
  const StatCard({super.key, required this.num, required this.label, required this.badge,
    required this.badgeBg, required this.badgeFg});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(num, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: kTextMain)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: kTextMuted)),
      const SizedBox(height: 8),
      AppBadge(label: badge, bg: badgeBg, fg: badgeFg),
    ]),
  );
}

class DashboardTaskRow extends StatelessWidget {
  final Task task;
  const DashboardTaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? kTeal : Colors.transparent,
            border: Border.all(color: isDone ? kTeal : kBorder, width: 1.5),
          ),
          child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title,
                style: TextStyle(
                    fontSize: 12,
                    color: isDone ? kTextMuted : kTextMain,
                    decoration: isDone ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 2),
            Text(
              '${isDone ? "Hôm qua" : task.deadline} · '
                  '${task.assignee == "MH" ? "Minh Hoàng" : task.assignee == "AN" ? "An Nhiên" : "Nhóm"}',
              style: const TextStyle(fontSize: 11, color: kTextMuted),
            ),
          ]),
        ),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? kTeal : task.status == 'doing' ? kAmber : kTextMuted,
          ),
        ),
      ]),
    );
  }
}

class ProgressRow extends StatelessWidget {
  final String label, pctStr;
  final double pct;
  final Color color;
  const ProgressRow({super.key, required this.label, required this.pct,
    required this.color, required this.pctStr});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: kTextMain))),
        Text(pctStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: kAppBg,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ],
  );
}
