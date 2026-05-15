import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/kanban_widgets.dart';
import '../widgets/shared_widgets.dart';


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

  String get _currentUserInitials {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  void _move(Task task, String newStatus) {
    _firestoreService.updateTaskStatus(widget.selectedGroup.id, task.id, newStatus);
  }

  @override
  Widget build(BuildContext context) {
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

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    KanbanColumn(title: 'Chờ làm',    status: 'todo',  color: kTextMuted, tasks: col('todo'),  onMove: _move, currentUserInitials: _currentUserInitials),
                    const SizedBox(height: 12),
                    KanbanColumn(title: 'Đang làm',   status: 'doing', color: kAmber,     tasks: col('doing'), onMove: _move, currentUserInitials: _currentUserInitials),
                    const SizedBox(height: 12),
                    KanbanColumn(title: 'Hoàn thành', status: 'done',  color: kTeal,      tasks: col('done'),  onMove: _move, currentUserInitials: _currentUserInitials),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}