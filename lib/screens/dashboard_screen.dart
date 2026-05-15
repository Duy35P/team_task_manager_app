import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const DashboardScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();

  void _viewAllTasks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => StreamBuilder<List<Task>>(
          stream: _firestoreService.watchTasks(widget.selectedGroup.id, type: 'task'),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            return Column(
              children: [
                _sheetHeader(tasks.length),
                const Divider(height: 0, color: kBorder, thickness: 0.5),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const Divider(height: 0, color: kBorder, thickness: 0.5),
                    itemBuilder: (_, i) => _taskRow(tasks[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sheetHeader(int count) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: Row(children: [
      Text('Tất cả công việc — ${widget.selectedGroup.name}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextMain)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: kAccentLight, borderRadius: BorderRadius.circular(6)),
        child: Text('$count tasks',
            style: const TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
      ),
    ]),
  );

  Widget _taskRow(Task t) {
    final st = statusStyle(t.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: const TextStyle(fontSize: 13, color: kTextMain)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              AppBadge(label: st.label, bg: st.bg, fg: st.fg),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          AppAvatar(initials: t.assignee, colorIndex: avatarIndex(t.assignee), size: 24),
          const SizedBox(height: 4),
          Text(t.deadline,
              style: TextStyle(fontSize: 11,
                  color: t.deadline == 'Hôm nay' ? kCoral : kTextMuted)),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final group = widget.selectedGroup;

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Dashboard'),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.watchTasks(group.id, type: 'task'),
        builder: (context, taskSnap) {
          final tasks = taskSnap.data ?? [];
          final done  = tasks.where((t) => t.status == 'done').length;
          final doing = tasks.where((t) => t.status == 'doing').length;
          final overdue = tasks.where((t) => t.deadline == 'Hôm nay').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GroupSelector(
                groups: widget.groups,
                selectedIndex: widget.selectedGroupIndex,
                onChanged: widget.onGroupChanged,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12, runSpacing: 12,
                children: [
                  SizedBox(
                    width: width - 40,
                    child: StatCard(num: '${tasks.length}', label: 'Tổng công việc',
                        badge: group.name,
                        badgeBg: kAccentLight, badgeFg: kAccent),
                  ),
                  SizedBox(
                    width: width - 40,
                    child: StatCard(num: '$doing', label: 'Đang thực hiện',
                        badge: 'Cần chú ý', badgeBg: kAmberLight, badgeFg: kAmber),
                  ),
                  SizedBox(
                    width: width - 40,
                    child: StatCard(num: '$done', label: 'Hoàn thành',
                        badge: '${tasks.isEmpty ? 0 : (done * 100 ~/ tasks.length)}%', badgeBg: kTealLight, badgeFg: kTeal),
                  ),
                  SizedBox(
                    width: width - 40,
                    child: StatCard(num: '$overdue', label: 'Quá hạn',
                        badge: 'Cần xử lý', badgeBg: kCoralLight, badgeFg: kCoral),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('Việc gần đây',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _viewAllTasks,
                      child: Text('Xem tất cả (${tasks.length})',
                          style: const TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ...tasks.take(4).map((t) => DashboardTaskRow(task: t)),
                ]),
              ),
              const SizedBox(height: 16),
              AppCard(child: _progressPanel(tasks)),
              const SizedBox(height: 16),
              _groupOverviewSection(),
            ]),
          );
        },
      ),
    );
  }

  Widget _groupOverviewSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tổng quan các nhóm',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12, runSpacing: 12,
        children: widget.groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          final isSelected = i == widget.selectedGroupIndex;
          return GestureDetector(
            onTap: () => widget.onGroupChanged(i),
            child: _GroupOverviewCard(
              group: g,
              isSelected: isSelected,
              firestoreService: _firestoreService,
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _progressPanel(List<Task> tasks) {
    final group = widget.selectedGroup;
    final totalTasks = tasks.length;
    final doneTasks  = tasks.where((t) => t.status == 'done').length;
    final doingTasks = tasks.where((t) => t.status == 'doing').length;
    final todoTasks  = tasks.where((t) => t.status == 'todo').length;

    final donePct  = totalTasks > 0 ? doneTasks / totalTasks : 0.0;
    final doingPct = totalTasks > 0 ? doingTasks / totalTasks : 0.0;
    final todoPct  = totalTasks > 0 ? todoTasks / totalTasks : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tiến độ — ${group.name}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
      const SizedBox(height: 14),
      ProgressRow(label: 'Hoàn thành',    pct: donePct,  color: kTeal,   pctStr: '${(donePct * 100).toInt()}%'),
      const SizedBox(height: 12),
      ProgressRow(label: 'Đang thực hiện', pct: doingPct, color: kAmber,  pctStr: '${(doingPct * 100).toInt()}%'),
      const SizedBox(height: 12),
      ProgressRow(label: 'Chờ làm',        pct: todoPct,  color: kAccent, pctStr: '${(todoPct * 100).toInt()}%'),
      const SizedBox(height: 18),
      const Text('THÀNH VIÊN',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
              color: kTextMuted, letterSpacing: 0.08)),
      const SizedBox(height: 10),
      StreamBuilder<List<TeamMember>>(
        stream: _firestoreService.watchMembers(group.id),
        builder: (context, snap) {
          final members = snap.data ?? [];
          return Wrap(
            spacing: 10, runSpacing: 8,
            children: members.map((m) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppAvatar(initials: m.initials, colorIndex: m.avatarColorIndex),
                const SizedBox(width: 6),
                Text(m.name.split(' ').last, style: const TextStyle(fontSize: 12, color: kTextMain)),
              ],
            )).toList(),
          );
        },
      ),
    ]);
  }
}

class _GroupOverviewCard extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final FirestoreService firestoreService;

  const _GroupOverviewCard({
    required this.group,
    required this.isSelected,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kAccent : kBorder,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(group.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? kAccent : kTextMain)),
          ),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: group.isActive ? kTeal : kTextMuted,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(group.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: kTextMuted)),
        const SizedBox(height: 10),
        StreamBuilder<List<Task>>(
          stream: firestoreService.watchTasks(group.id, type: 'task'),
          builder: (context, taskSnap) {
            final taskCount = taskSnap.data?.length ?? 0;
            return StreamBuilder<List<TeamMember>>(
              stream: firestoreService.watchMembers(group.id),
              builder: (context, memberSnap) {
                final memberCount = memberSnap.data?.length ?? 0;
                return Row(children: [
                  _miniStat(Icons.task_alt_outlined, '$taskCount tasks'),
                  const SizedBox(width: 12),
                  _miniStat(Icons.group_outlined, '$memberCount TV'),
                ]);
              },
            );
          },
        ),
      ]),
    );
  }

  Widget _miniStat(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: kTextMuted),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, color: kTextMuted)),
    ],
  );
}