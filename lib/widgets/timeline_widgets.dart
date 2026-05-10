import 'package:flutter/material.dart';
import '../theme.dart';

class TLTask {
  String name, label;
  Color color;
  int startCol, spanCols;
  TLTask({
    required this.name,
    required this.label,
    required this.color,
    required this.startCol,
    required this.spanCols,
  });
}

// ── Timeline Row ───────────────────────────────────────────────────────────────

class TimelineRow extends StatelessWidget {
  final TLTask task;
  const TimelineRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(task.name, style: const TextStyle(fontSize: 12, color: kTextMain)),
          ),
        ),
        ...List.generate(4, (i) {
          final isStart = i == task.startCol;
          final inRange = i >= task.startCol && i < task.startCol + task.spanCols;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: inRange
                  ? Container(
                height: 28,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.horizontal(
                    left: isStart ? const Radius.circular(6) : Radius.zero,
                    right: i == task.startCol + task.spanCols - 1
                        ? const Radius.circular(6)
                        : Radius.zero,
                  ),
                ),
                alignment: isStart ? Alignment.centerLeft : Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: isStart
                    ? Text(task.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: task.color == const Color(0xFFD3D1C7)
                            ? const Color(0xFF5F5E5A)
                            : Colors.white))
                    : null,
              )
                  : const SizedBox(height: 28),
            ),
          );
        }),
      ]),
    );
  }
}
