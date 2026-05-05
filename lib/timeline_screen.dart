import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';
import 'responsive.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  static const _weeks = ['Tuần 17', 'Tuần 18', 'Tuần 19 ←', 'Tuần 20'];
  static const _tasks = [
    _TLTask(name: 'Auth module', label: 'Hoàn thành', color: kTeal,      startCol: 0, spanCols: 2),
    _TLTask(name: 'Task CRUD',   label: 'Đang làm',   color: kAccent,    startCol: 1, spanCols: 2),
    _TLTask(name: 'Kanban UI',   label: 'Bắt đầu',    color: kAmber,     startCol: 2, spanCols: 2),
    _TLTask(name: 'Chat module', label: 'Sắp tới',    color: Color(0xFFD3D1C7), startCol: 3, spanCols: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final content = AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Header row
        Container(
          decoration: const BoxDecoration(
            color: kAppBg,
            border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            const SizedBox(
              width: 160,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Công việc',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kTextMuted)),
              ),
            ),
            ..._weeks.map((w) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(w,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: w.contains('←') ? kAccent : kTextMuted)),
              ),
            )),
          ]),
        ),
        // Task rows
        ..._tasks.map((t) => _TimelineRow(task: t)),
      ]),
    );

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Timeline', actionLabel: '+ Thêm mốc', onAction: () {}),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: mobile
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 520),
            child: content,
          ),
        )
            : content,
      ),
    );
  }
}

class _TLTask {
  final String name, label;
  final Color color;
  final int startCol, spanCols;
  const _TLTask({
    required this.name,
    required this.label,
    required this.color,
    required this.startCol,
    required this.spanCols,
  });
}

class _TimelineRow extends StatelessWidget {
  final _TLTask task;
  const _TimelineRow({required this.task});

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
        // 4 week cells
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