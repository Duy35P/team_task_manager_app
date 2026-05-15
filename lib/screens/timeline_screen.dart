import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/timeline_widgets.dart';
import '../widgets/shared_widgets.dart';


class TimelineScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const TimelineScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.watchTasks(widget.selectedGroup.id),
      builder: (context, snapshot) {
        final allTasks = snapshot.data ?? [];

        // Sắp xếp theo deadline (gần nhất trước, không có deadline xuống cuối)
        allTasks.sort((a, b) {
          final da = parseDeadline(a.deadline);
          final db = parseDeadline(b.deadline);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });

        // Loại bỏ trùng title (vì task và kanban lưu 2 bản)
        final seen = <String>{};
        final tasks = allTasks.where((t) => seen.add(t.title)).toList();

        final content = AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: kAppBg,
                border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                const Icon(Icons.timeline_rounded, size: 16, color: kTextMuted),
                const SizedBox(width: 8),
                const Text('Công việc theo hạn',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
                const Spacer(),
                Text('${tasks.length} công việc',
                    style: const TextStyle(fontSize: 11, color: kTextMuted)),
              ]),
            ),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Thêm task ở màn Công việc để hiển thị tại đây.',
                      style: TextStyle(fontSize: 12, color: kTextMuted)),
                ),
              )
            else
              ...tasks.map((t) => TimelineTaskRow(task: t)),
          ]),
        );

        return Scaffold(
          backgroundColor: kAppBg,
          appBar: AppTopBar(title: 'Timeline'),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupSelector(
                  groups: widget.groups,
                  selectedIndex: widget.selectedGroupIndex,
                  onChanged: widget.onGroupChanged,
                ),
                const SizedBox(height: 12),
                Expanded(child: SingleChildScrollView(child: content)),
              ],
            ),
          ),
        );
      },
    );
  }
}