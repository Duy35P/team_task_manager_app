import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

/// Parse deadline string "dd/MM/yyyy" thành DateTime, null nếu lỗi
DateTime? parseDeadline(String s) {
  if (s.isEmpty) return null;
  try {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  } catch (_) {
    return null;
  }
}

// ── Timeline Task Row ──────────────────────────────────────────────────────────

class TimelineTaskRow extends StatelessWidget {
  final Task task;
  const TimelineTaskRow({super.key, required this.task});

  Color _statusColor() => switch (task.status) {
    'done'  => const Color(0xFF26A69A),
    'doing' => const Color(0xFFFFB74D),
    _       => kAccent,
  };

  String _statusLabel() => switch (task.status) {
    'done'  => 'Hoàn thành',
    'doing' => 'Đang làm',
    _       => 'Chờ làm',
  };

  IconData _statusIcon() => switch (task.status) {
    'done'  => Icons.check_circle_rounded,
    'doing' => Icons.timelapse_rounded,
    _       => Icons.radio_button_unchecked_rounded,
  };

  bool _isOverdue() {
    if (task.status == 'done') return false;
    final d = parseDeadline(task.deadline);
    if (d == null) return false;
    return d.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final overdue = _isOverdue();

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(_statusIcon(), color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(fontSize: 13, color: kTextMain, fontWeight: FontWeight.w500)),
                if (task.assignee.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.person_outline, size: 12, color: kTextMuted),
                    const SizedBox(width: 3),
                    Text(task.assignee,
                        style: const TextStyle(fontSize: 11, color: kTextMuted)),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Deadline badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: overdue ? const Color(0x22FF5252) : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.deadline.isEmpty ? 'Không hạn' : task.deadline,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: overdue ? const Color(0xFFFF5252) : color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusLabel(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ),
        ]),
      ),
    );
  }
}
