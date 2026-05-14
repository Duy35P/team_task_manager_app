import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/task_widgets.dart';
import '../responsive.dart';

class TasksScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const TasksScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _firestoreService = FirestoreService();
  int _filter = 0; // 0=Tất cả, 1=Của tôi, 2=Đang làm, 3=Quá hạn
  bool _showAllGroups = false;

  String get _currentUserInitials {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  List<_TaskWithGroup> _applyFilter(List<_TaskWithGroup> tasks) => switch (_filter) {
    1 => tasks.where((tw) => tw.task.assignee == _currentUserInitials).toList(),
    2 => tasks.where((tw) => tw.task.status == 'doing').toList(),
    3 => tasks.where((tw) => tw.task.deadline == 'Hôm nay').toList(),
    _ => tasks,
  };

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Công việc', actionLabel: '+ Thêm task', onAction: _addTask),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Group selector ────────────────────────────────────────────
          _buildGroupSelector(),
          const SizedBox(height: 12),

          // ── Task table ────────────────────────────────────────────────
          Expanded(
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
                        .map((e) => FilterTab(
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
                    child: Row(children: [
                      const Expanded(flex: 5, child: TaskHeaderCell('Tên công việc')),
                      const Expanded(flex: 2, child: TaskHeaderCell('Trạng thái')),
                      const Expanded(flex: 2, child: TaskHeaderCell('Deadline')),
                      const Expanded(flex: 2, child: TaskHeaderCell('Thực hiện')),
                      if (_showAllGroups)
                        const Expanded(flex: 2, child: TaskHeaderCell('Nhóm')),
                    ]),
                  ),
                Expanded(
                  child: _showAllGroups
                      ? _buildAllGroupsTasks(mobile)
                      : _buildSingleGroupTasks(mobile),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSingleGroupTasks(bool mobile) {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.watchTasks(widget.selectedGroup.id, type: 'task'),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final tasksWithGroup = tasks
            .map((t) => _TaskWithGroup(task: t, groupName: widget.selectedGroup.name, groupId: widget.selectedGroup.id))
            .toList();
        final filtered = _applyFilter(tasksWithGroup);
        return _buildTaskList(filtered, mobile);
      },
    );
  }

  Widget _buildAllGroupsTasks(bool mobile) {
    // For "all groups", we show tasks from all groups
    // Simple approach: use the groups list and build streams for each
    return StreamBuilder<List<_TaskWithGroup>>(
      stream: _watchAllGroupsTasks(),
      builder: (context, snapshot) {
        final filtered = _applyFilter(snapshot.data ?? []);
        return _buildTaskList(filtered, mobile);
      },
    );
  }

  Stream<List<_TaskWithGroup>> _watchAllGroupsTasks() {
    final streams = widget.groups.map((g) =>
      _firestoreService.watchTasks(g.id, type: 'task').map((tasks) =>
        tasks.map((t) => _TaskWithGroup(task: t, groupName: g.name, groupId: g.id)).toList()
      )
    ).toList();

    if (streams.isEmpty) return Stream.value([]);

    return streams.first.asyncExpand((first) {
      if (streams.length == 1) return Stream.value(first);
      // Combine all streams
      return _combineStreams(streams);
    });
  }

  Stream<List<_TaskWithGroup>> _combineStreams(List<Stream<List<_TaskWithGroup>>> streams) {
    final latest = List<List<_TaskWithGroup>>.filled(streams.length, []);
    return Stream.multi((controller) {
      for (var i = 0; i < streams.length; i++) {
        final idx = i;
        streams[idx].listen((data) {
          latest[idx] = data;
          controller.add(latest.expand((e) => e).toList());
        });
      }
    });
  }

  Widget _buildTaskList(List<_TaskWithGroup> filtered, bool mobile) {
    if (filtered.isEmpty) {
      return const Center(
        child: Text('Không có công việc nào',
            style: TextStyle(fontSize: 13, color: kTextMuted)),
      );
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 0, color: kBorder, thickness: 0.5),
      itemBuilder: (_, i) {
        final tw = filtered[i];
        if (mobile) {
          return _MobileTaskCard(
            tw: tw,
            showGroupBadge: _showAllGroups,
            onToggle: () => _toggle(tw),
            onEdit: () => _editTask(tw),
            onDelete: () => _deleteTask(tw),
          );
        }
        return _DesktopTaskRow(
          tw: tw,
          showGroupBadge: _showAllGroups,
          onToggle: () => _toggle(tw),
          onEdit: () => _editTask(tw),
          onDelete: () => _deleteTask(tw),
        );
      },
    );
  }

  // ── Group selector with "Tất cả nhóm" ────────────────────────────────────
  Widget _buildGroupSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "Tất cả nhóm" chip
          GestureDetector(
            onTap: () => setState(() => _showAllGroups = true),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _showAllGroups ? kAccentLight : kCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showAllGroups ? kAccent : kBorder,
                  width: _showAllGroups ? 1.5 : 0.5,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.groups_outlined, size: 16,
                    color: _showAllGroups ? kAccent : kTextMuted),
                const SizedBox(width: 6),
                Text('Tất cả nhóm',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: _showAllGroups ? FontWeight.w600 : FontWeight.normal,
                        color: _showAllGroups ? kAccent : kTextMuted)),
              ]),
            ),
          ),
          // Individual group chips
          ...widget.groups.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            final active = !_showAllGroups && i == widget.selectedGroupIndex;
            return GestureDetector(
              onTap: () {
                setState(() => _showAllGroups = false);
                widget.onGroupChanged(i);
              },
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
          }),
        ],
      ),
    );
  }

  void _toggle(_TaskWithGroup tw) {
    final newStatus = tw.task.status == 'done' ? 'todo' : 'done';
    _firestoreService.updateTaskStatus(tw.groupId, tw.task.id, newStatus);
  }

  // ── Sửa task ──────────────────────────────────────────────────────────────
  void _editTask(_TaskWithGroup tw) {
    final titleCtrl = TextEditingController(text: tw.task.title);
    String selStatus = tw.task.status;
    String selAssignee = tw.task.assignee;
    DateTime? selDeadline;

    final statuses = [
      ('todo',  'Chờ làm',    kTextMuted),
      ('doing', 'Đang làm',   kAmber),
      ('done',  'Hoàn thành', kTeal),
    ];

    String formatDate(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final group = widget.groups.firstWhere((g) => g.id == tw.groupId, orElse: () => widget.selectedGroup);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Sửa task',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
            content: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Tên task
                  TextField(
                    controller: titleCtrl,
                    autofocus: true,
                    style: const TextStyle(fontSize: 13, color: kTextMain),
                    decoration: _inputDeco('Tên công việc...'),
                  ),
                  const SizedBox(height: 14),

                  // Thời hạn
                  _label('Thời hạn'),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selDeadline ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDlg(() => selDeadline = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: kTextMuted),
                        const SizedBox(width: 8),
                        Text(
                          selDeadline != null ? formatDate(selDeadline!) : tw.task.deadline.isNotEmpty ? tw.task.deadline : 'Chọn ngày...',
                          style: TextStyle(fontSize: 13,
                              color: selDeadline != null || tw.task.deadline.isNotEmpty ? kTextMain : kTextMuted),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cột (Status)
                  _label('Trạng thái'),
                  Row(children: statuses.map((s) {
                    final active = selStatus == s.$1;
                    return GestureDetector(
                      onTap: () => setDlg(() => selStatus = s.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? _statusBg(s.$1) : kAppBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? s.$3 : kBorder,
                              width: active ? 1.5 : 0.5),
                        ),
                        child: Text(s.$2,
                            style: TextStyle(fontSize: 12, color: active ? s.$3 : kTextMuted,
                                fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 14),

                  // Giao cho
                  _label('Giao cho'),
                  StreamBuilder<List<TeamMember>>(
                    stream: _firestoreService.watchMembers(group.id),
                    builder: (context, snap) {
                      final members = snap.data ?? [];
                      return Wrap(
                        spacing: 10, runSpacing: 8,
                        children: members.map((m) {
                          final active = selAssignee == m.initials;
                          return GestureDetector(
                            onTap: () => setDlg(() => selAssignee = m.initials),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: active ? Border.all(color: kAccent, width: 2) : null,
                                ),
                                child: AppAvatar(initials: m.initials,
                                    colorIndex: m.avatarColorIndex, size: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(m.name.split(' ').last,
                                  style: TextStyle(fontSize: 11,
                                      color: active ? kAccent : kTextMuted,
                                      fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                            ]),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final deadlineStr = selDeadline != null ? formatDate(selDeadline!) : null;
                  _firestoreService.updateTask(
                    tw.groupId, tw.task.id,
                    title: title != tw.task.title ? title : null,
                    status: selStatus != tw.task.status ? selStatus : null,
                    assignee: selAssignee != tw.task.assignee ? selAssignee : null,
                    deadline: deadlineStr,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã cập nhật task "$title"'),
                    backgroundColor: kTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Xoá task ──────────────────────────────────────────────────────────────
  void _deleteTask(_TaskWithGroup tw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xoá task?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
        content: Text('Bạn có chắc muốn xoá "${tw.task.title}"?\nTask sẽ bị xoá khỏi tất cả các màn hình.',
            style: const TextStyle(fontSize: 13, color: kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kCoral, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _firestoreService.deleteTaskEverywhere(tw.groupId, tw.task.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã xoá task "${tw.task.title}"'),
                backgroundColor: kCoral,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ));
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  // ── Thêm task mới ─────────────────────────────────────────────────────────
  void _addTask() {
    final titleCtrl  = TextEditingController();
    String selStatus = 'todo';
    String selAssignee = '';
    int selGroupIndex = widget.selectedGroupIndex;
    DateTime? selDeadline;

    final statuses = [
      ('todo',  'Chờ làm',    kTextMuted),
      ('doing', 'Đang làm',   kAmber),
      ('done',  'Hoàn thành', kTeal),
    ];

    String _formatDate(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final selectedGroup = widget.groups[selGroupIndex];

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Thêm task mới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
            content: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Chọn nhóm
                  _label('Nhóm'),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selGroupIndex,
                          icon: const Icon(Icons.expand_more, color: kTextMuted, size: 18),
                          style: const TextStyle(fontSize: 13, color: kTextMain),
                          items: widget.groups.asMap().entries.map((e) =>
                            DropdownMenuItem<int>(value: e.key, child: Text(e.value.name)),
                          ).toList(),
                          onChanged: (i) {
                            if (i != null) {
                              setDlg(() {
                                selGroupIndex = i;
                                selAssignee = '';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tên task
                  TextField(
                    controller: titleCtrl,
                    autofocus: true,
                    style: const TextStyle(fontSize: 13, color: kTextMain),
                    decoration: _inputDeco('Tên công việc...'),
                  ),
                  const SizedBox(height: 14),

                  // Thời hạn (Deadline)
                  _label('Thời hạn'),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selDeadline ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDlg(() => selDeadline = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: kTextMuted),
                        const SizedBox(width: 8),
                        Text(
                          selDeadline != null ? _formatDate(selDeadline!) : 'Chọn ngày...',
                          style: TextStyle(fontSize: 13,
                              color: selDeadline != null ? kTextMain : kTextMuted),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cột (Status)
                  _label('Cột'),
                  Row(children: statuses.map((s) {
                    final active = selStatus == s.$1;
                    return GestureDetector(
                      onTap: () => setDlg(() => selStatus = s.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? _statusBg(s.$1) : kAppBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? s.$3 : kBorder,
                              width: active ? 1.5 : 0.5),
                        ),
                        child: Text(s.$2,
                            style: TextStyle(fontSize: 12, color: active ? s.$3 : kTextMuted,
                                fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 14),

                  // Giao cho — load from Firestore
                  _label('Giao cho'),
                  StreamBuilder<List<TeamMember>>(
                    stream: _firestoreService.watchMembers(selectedGroup.id),
                    builder: (context, snap) {
                      final members = snap.data ?? [];
                      if (selAssignee.isEmpty && members.isNotEmpty) {
                        selAssignee = members.first.initials;
                      }
                      return Wrap(
                        spacing: 10, runSpacing: 8,
                        children: members.map((m) {
                          final active = selAssignee == m.initials;
                          return GestureDetector(
                            onTap: () => setDlg(() => selAssignee = m.initials),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: active ? Border.all(color: kAccent, width: 2) : null,
                                ),
                                child: AppAvatar(initials: m.initials,
                                    colorIndex: m.avatarColorIndex, size: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(m.name.split(' ').last,
                                  style: TextStyle(fontSize: 11,
                                      color: active ? kAccent : kTextMuted,
                                      fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                            ]),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  if (selDeadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Vui lòng chọn thời hạn'),
                      backgroundColor: kCoral,
                      behavior: SnackBarBehavior.floating,
                    ));
                    return;
                  }
                  final group = widget.groups[selGroupIndex];
                  final deadlineStr = _formatDate(selDeadline!);
                  _firestoreService.createTaskEverywhere(
                    groupId: group.id,
                    title: title,
                    status: selStatus,
                    assignee: selAssignee,
                    deadline: deadlineStr,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã thêm task "$title" vào ${group.name}'),
                    backgroundColor: kTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                },
                child: const Text('Thêm task'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _statusBg(String s) => switch (s) {
    'done'  => kTealLight,
    'doing' => kAmberLight,
    _       => kAccentLight,
  };

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, color: kTextMuted)),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: kTextMuted),
    isDense: true, filled: true, fillColor: kAppBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorder, width: 0.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorder, width: 0.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAccent)),
  );
}

// ── Helper class for task + group name pairing ──────────────────────────────
class _TaskWithGroup {
  final Task task;
  final String groupName;
  final String groupId;
  const _TaskWithGroup({required this.task, required this.groupName, required this.groupId});
}

// ── Desktop task row with optional group badge ──────────────────────────────
class _DesktopTaskRow extends StatelessWidget {
  final _TaskWithGroup tw;
  final bool showGroupBadge;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DesktopTaskRow({required this.tw, required this.showGroupBadge, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t  = tw.task;
    final st = statusStyle(t.status);
    final isDone = t.status == 'done';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        // Toggle checkbox
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? kTeal : Colors.transparent,
              border: Border.all(color: isDone ? kTeal : kBorder, width: 1.5),
            ),
            child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: Text(t.title,
              style: TextStyle(
                fontSize: 13,
                color: isDone ? kTextMuted : kTextMain,
                decoration: isDone ? TextDecoration.lineThrough : null,
              )),
        ),
        Expanded(
          flex: 2,
          child: AppBadge(label: st.label, bg: st.bg, fg: st.fg),
        ),
        Expanded(
          flex: 2,
          child: Text(t.deadline.isEmpty ? '--' : t.deadline,
              style: TextStyle(fontSize: 12,
                  color: t.deadline == 'Hôm nay' ? kCoral : kTextMuted)),
        ),
        Expanded(
          flex: 2,
          child: AppAvatar(initials: t.assignee, colorIndex: avatarIndex(t.assignee), size: 26),
        ),
        if (showGroupBadge)
          Expanded(
            flex: 2,
            child: AppBadge(label: tw.groupName, bg: kAccentLight, fg: kAccent),
          ),
        // Edit & Delete
        SizedBox(
          width: 60,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit_outlined, size: 16, color: kTextMuted),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline, size: 16, color: kCoral),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Mobile task card with optional group badge ──────────────────────────────
class _MobileTaskCard extends StatelessWidget {
  final _TaskWithGroup tw;
  final bool showGroupBadge;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MobileTaskCard({required this.tw, required this.showGroupBadge, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t  = tw.task;
    final st = statusStyle(t.status);
    final isDone = t.status == 'done';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? kTeal : Colors.transparent,
              border: Border.all(color: isDone ? kTeal : kBorder, width: 1.5),
            ),
            child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title,
                style: TextStyle(
                  fontSize: 13,
                  color: isDone ? kTextMuted : kTextMain,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                )),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              AppBadge(label: st.label, bg: st.bg, fg: st.fg),
              if (showGroupBadge)
                AppBadge(label: tw.groupName, bg: kAccentLight, fg: kAccent),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          AppAvatar(initials: t.assignee, colorIndex: avatarIndex(t.assignee), size: 24),
          const SizedBox(height: 4),
          Text(t.deadline.isEmpty ? '--' : t.deadline,
              style: TextStyle(fontSize: 11,
                  color: t.deadline == 'Hôm nay' ? kCoral : kTextMuted)),
        ]),
        const SizedBox(width: 8),
        // Edit & Delete
        Column(mainAxisSize: MainAxisSize.min, children: [
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.edit_outlined, size: 16, color: kTextMuted),
            ),
          ),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.delete_outline, size: 16, color: kCoral),
            ),
          ),
        ]),
      ]),
    );
  }
}