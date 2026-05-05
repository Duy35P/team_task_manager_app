import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'home_screen.dart';
import 'responsive.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});
  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final List<Task> _tasks = List.from(mockKanbanTasks);

  List<Task> _col(String s) => _tasks.where((t) => t.status == s).toList();
  void _move(Task task, String newStatus) => setState(() => task.status = newStatus);

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Kanban Board', actionLabel: '+ Thêm task', onAction: () {}),
      body: mobile
          ? ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KanbanColumn(title: 'Chờ làm', status: 'todo', color: kTextMuted, tasks: _col('todo'), onMove: _move),
          const SizedBox(height: 12),
          _KanbanColumn(title: 'Đang làm', status: 'doing', color: kAmber, tasks: _col('doing'), onMove: _move),
          const SizedBox(height: 12),
          _KanbanColumn(title: 'Hoàn thành', status: 'done', color: kTeal, tasks: _col('done'), onMove: _move),
        ],
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KanbanColumn(title: 'Chờ làm', status: 'todo', color: kTextMuted, tasks: _col('todo'), onMove: _move),
            const SizedBox(width: 16),
            _KanbanColumn(title: 'Đang làm', status: 'doing', color: kAmber, tasks: _col('doing'), onMove: _move),
            const SizedBox(width: 16),
            _KanbanColumn(title: 'Hoàn thành', status: 'done', color: kTeal, tasks: _col('done'), onMove: _move),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title, status;
  final Color color;
  final List<Task> tasks;
  final void Function(Task, String) onMove;
  const _KanbanColumn({
    required this.title, required this.status, required this.color,
    required this.tasks, required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAcceptWithDetails: (d) => onMove(d.data, status),
      builder: (_, candidates, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
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
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: kAppBg, borderRadius: BorderRadius.circular(10)),
              child: Text('${tasks.length}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
            ),
          ]),
          const SizedBox(height: 12),
          ...tasks.map((t) => _KanbanCard(task: t)),
        ]),
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  const _KanbanCard({required this.task});

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
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
          top: const BorderSide(color: kBorder, width: 0.5),
          right: const BorderSide(color: kBorder, width: 0.5),
          bottom: const BorderSide(color: kBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMain)),
        const SizedBox(height: 8),
        Row(children: [
          if (task.tag.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: kAccentLight, borderRadius: BorderRadius.circular(4)),
              child: Text(task.tag, style: const TextStyle(fontSize: 10, color: kAccent)),
            ),
          const Spacer(),
          AppAvatar(initials: task.assignee, colorIndex: avatarIndex(task.assignee), size: 20),
        ]),
      ]),
    );
  }
}