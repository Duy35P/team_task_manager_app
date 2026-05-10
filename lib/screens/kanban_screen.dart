import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/kanban_widgets.dart';
import '../responsive.dart';

class KanbanScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const KanbanScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final _firestoreService = FirestoreService();

  void _move(Task task, String newStatus) {
    _firestoreService.updateTaskStatus(widget.selectedGroup.id, task.id, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Kanban Board'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group selector ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildGroupSelector(),
          ),
          const SizedBox(height: 12),

          // ── Kanban columns ──────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _firestoreService.watchTasks(widget.selectedGroup.id, type: 'kanban'),
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? [];
                List<Task> col(String s) => tasks.where((t) => t.status == s).toList();

                if (mobile) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      KanbanColumn(title: 'Chờ làm',    status: 'todo',  color: kTextMuted, tasks: col('todo'),  onMove: _move),
                      const SizedBox(height: 12),
                      KanbanColumn(title: 'Đang làm',   status: 'doing', color: kAmber,     tasks: col('doing'), onMove: _move),
                      const SizedBox(height: 12),
                      KanbanColumn(title: 'Hoàn thành', status: 'done',  color: kTeal,      tasks: col('done'),  onMove: _move),
                    ],
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KanbanColumn(title: 'Chờ làm',    status: 'todo',  color: kTextMuted, tasks: col('todo'),  onMove: _move, fixedWidth: 320),
                      const SizedBox(width: 16),
                      KanbanColumn(title: 'Đang làm',   status: 'doing', color: kAmber,     tasks: col('doing'), onMove: _move, fixedWidth: 320),
                      const SizedBox(width: 16),
                      KanbanColumn(title: 'Hoàn thành', status: 'done',  color: kTeal,      tasks: col('done'),  onMove: _move, fixedWidth: 320),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          final active = i == widget.selectedGroupIndex;
          return GestureDetector(
            onTap: () => widget.onGroupChanged(i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? kAccentLight : kCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? kAccent : kBorder,
                  width: active ? 1.5 : 0.5,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? kAccent : kTextMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(g.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        color: active ? kAccent : kTextMuted)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}