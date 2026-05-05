import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'home_screen.dart';
import 'responsive.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = List.from(mockTasks);
  int _filter = 0; // 0=Tất cả, 1=Của tôi, 2=Đang làm, 3=Quá hạn

  List<Task> get _filtered => switch (_filter) {
    1 => _tasks.where((t) => t.assignee == 'MH').toList(),
    2 => _tasks.where((t) => t.status == 'doing').toList(),
    3 => _tasks.where((t) => t.deadline == 'Hôm nay').toList(),
    _ => _tasks,
  };

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Công việc', actionLabel: '+ Tạo task', onAction: _addTask),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppCard(
          padding: EdgeInsets.zero,
          radius: 12,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                ...[('Tất cả', 0), ('Của tôi', 1), ('Đang làm', 2), ('Quá hạn', 3)]
                    .map((e) => _FilterTab(
                  label: e.$1,
                  active: _filter == e.$2,
                  onTap: () => setState(() => _filter = e.$2),
                )),
              ]),
            ),
            if (!mobile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  color: kAppBg,
                  border: Border(
                    top: BorderSide(color: kBorder, width: 0.5),
                    bottom: BorderSide(color: kBorder, width: 0.5),
                  ),
                ),
                child: const Row(children: [
                  Expanded(flex: 5, child: _HeaderCell('Tên công việc')),
                  Expanded(flex: 2, child: _HeaderCell('Trạng thái')),
                  Expanded(flex: 2, child: _HeaderCell('Ưu tiên')),
                  Expanded(flex: 2, child: _HeaderCell('Deadline')),
                  Expanded(flex: 2, child: _HeaderCell('Thực hiện')),
                ]),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 0, color: kBorder, thickness: 0.5),
                itemBuilder: (_, i) => mobile
                    ? _TaskCard(task: _filtered[i], onToggle: () => _toggle(i))
                    : _TaskRow(task: _filtered[i], onToggle: () => _toggle(i)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _toggle(int i) => setState(() {
    _filtered[i].status = _filtered[i].status == 'done' ? 'todo' : 'done';
  });

  void _addTask() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tạo task mới'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên công việc'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              setState(() => _tasks.add(Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: ctrl.text.trim(),
                assignee: 'MH',
                deadline: '--',
              )));
              Navigator.pop(context);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterTab({required this.label, required this.active, required this.onTap});

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

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMuted));
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const _TaskRow({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final st  = statusStyle(task.status);
    final pri = priorityStyle(task.priority);
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
        Expanded(flex: 2, child: AppBadge(label: task.priority, bg: pri.bg, fg: pri.fg)),
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

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const _TaskCard({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final st  = statusStyle(task.status);
    final pri = priorityStyle(task.priority);
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
          AppBadge(label: task.priority, bg: pri.bg, fg: pri.fg),
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