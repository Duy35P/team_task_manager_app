import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/kanban_widgets.dart';
import '../widgets/shared_widgets.dart';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GroupSelector(
              groups: widget.groups,
              selectedIndex: widget.selectedGroupIndex,
              onChanged: widget.onGroupChanged,
            ),
          ),
          const SizedBox(height: 12),

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
}