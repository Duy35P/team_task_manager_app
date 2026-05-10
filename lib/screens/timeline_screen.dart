import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/timeline_widgets.dart';
import '../responsive.dart';

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
  final List<String> _weeks = ['Tuần 17', 'Tuần 18', 'Tuần 19 ←', 'Tuần 20'];
  final _firestoreService = FirestoreService();

  // ── Thêm task đã có vào timeline ─────────────────────────────────────────
  void _addToTimeline(List<Task> tasks, List<TimelineItem> existing) {
    final existingIds = existing.map((e) => e.taskId).toSet();
    final available = tasks.where((t) => !existingIds.contains(t.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chưa có task nào để thêm vào timeline'),
        backgroundColor: kTeal,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    Task selectedTask = available.first;
    final labelCtrl = TextEditingController(text: _statusLabel(selectedTask.status));
    int selStart = 0;
    int selSpan = 1;
    Color selColor = _statusColor(selectedTask.status);

    final colorOptions = [
      (color: kAccent, label: 'Tím'),
      (color: kTeal,   label: 'Xanh'),
      (color: kAmber,  label: 'Vàng'),
      (color: kCoral,  label: 'Đỏ'),
      (color: const Color(0xFFD3D1C7), label: 'Xám'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Thêm task vào timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Chọn task
                    _dlgLabel('Chọn task'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedTask.id,
                          icon: const Icon(Icons.expand_more, color: kTextMuted, size: 18),
                          style: const TextStyle(fontSize: 13, color: kTextMain),
                          items: available.map((t) =>
                            DropdownMenuItem<String>(value: t.id, child: Text(t.title)),
                          ).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            setDlg(() {
                              selectedTask = available.firstWhere((t) => t.id == id);
                              labelCtrl.text = _statusLabel(selectedTask.status);
                              selColor = _statusColor(selectedTask.status);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _inputField(labelCtrl, 'Nhãn trạng thái', 'VD: Đang làm, Sắp tới...'),
                    const SizedBox(height: 14),

                    // Tuần bắt đầu
                    _dlgLabel('Bắt đầu từ tuần'),
                    Wrap(
                      spacing: 8,
                      children: List.generate(_weeks.length, (i) {
                        final active = selStart == i;
                        return GestureDetector(
                          onTap: () {
                            setDlg(() {
                              selStart = i;
                              if (selStart + selSpan > _weeks.length) {
                                selSpan = _weeks.length - selStart;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: active ? kAccentLight : kAppBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: active ? kAccent : kBorder,
                                  width: active ? 1.5 : 0.5),
                            ),
                            child: Text(_weeks[i].replaceAll(' ←', ''),
                                style: TextStyle(fontSize: 12,
                                    color: active ? kAccent : kTextMuted,
                                    fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Số tuần kéo dài
                    _dlgLabel('Kéo dài (số tuần)'),
                    Row(children: List.generate(
                        _weeks.length - selStart, (i) {
                      final span = i + 1;
                      final active = selSpan == span;
                      return GestureDetector(
                        onTap: () => setDlg(() => selSpan = span),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: active ? kAccentLight : kAppBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: active ? kAccent : kBorder,
                                width: active ? 1.5 : 0.5),
                          ),
                          child: Center(
                            child: Text('$span', style: TextStyle(fontSize: 13,
                                color: active ? kAccent : kTextMuted,
                                fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        ),
                      );
                    }),
                    ),
                    const SizedBox(height: 14),

                    // Màu sắc
                    _dlgLabel('Màu hiển thị'),
                    Row(children: colorOptions.map((c) {
                      final active = selColor == c.color;
                      return GestureDetector(
                        onTap: () => setDlg(() => selColor = c.color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                            border: active
                                ? Border.all(color: kTextMain, width: 2.5)
                                : Border.all(color: Colors.transparent, width: 2.5),
                            boxShadow: active
                                ? [BoxShadow(color: c.color.withOpacity(0.5), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      );
                    }).toList()),

                    const SizedBox(height: 16),
                    // Preview
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: Row(children: [
                        const Text('Xem trước: ',
                            style: TextStyle(fontSize: 11, color: kTextMuted)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: selColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                labelCtrl.text.isEmpty ? 'Nhãn' : labelCtrl.text,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selColor == const Color(0xFFD3D1C7)
                                      ? const Color(0xFF5F5E5A)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
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
                final label = labelCtrl.text.trim();
                final item = TimelineItem(
                  id: '',
                  taskId: selectedTask.id,
                  title: selectedTask.title,
                  label: label.isEmpty ? _statusLabel(selectedTask.status) : label,
                  colorValue: selColor.value,
                  startCol: selStart,
                  spanCols: selSpan,
                );
                _firestoreService.addTimelineItem(widget.selectedGroup.id, item);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Đã thêm "${selectedTask.title}" vào timeline'),
                  backgroundColor: kTeal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
              },
              child: const Text('Thêm vào timeline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13, color: kTextMain),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
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
        ),
      );

  Widget _dlgLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, color: kTextMuted)),
  );

  String _statusLabel(String status) => switch (status) {
    'done'  => 'Hoàn thành',
    'doing' => 'Đang làm',
    _       => 'Chờ làm',
  };

  Color _statusColor(String status) => switch (status) {
    'done'  => kTeal,
    'doing' => kAmber,
    _       => kAccent,
  };

  List<TLTask> _toTimelineTasks(List<TimelineItem> items) => items.map((i) =>
      TLTask(
        name: i.title,
        label: i.label,
        color: Color(i.colorValue),
        startCol: i.startCol,
        spanCols: i.spanCols,
      ),
  ).toList();

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return StreamBuilder<List<Task>>(
      stream: _firestoreService.watchTasks(widget.selectedGroup.id, type: 'task'),
      builder: (context, taskSnap) {
        final tasks = taskSnap.data ?? [];
        return StreamBuilder<List<TimelineItem>>(
          stream: _firestoreService.watchTimeline(widget.selectedGroup.id),
          builder: (context, tlSnap) {
            final items = tlSnap.data ?? [];
            final timelineTasks = _toTimelineTasks(items);

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
                if (timelineTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Chưa có mốc timeline. Nhấn "+ Thêm mốc" để thêm task.',
                          style: TextStyle(fontSize: 12, color: kTextMuted)),
                    ),
                  )
                else
                  ...timelineTasks.map((t) => TimelineRow(task: t)),
              ]),
            );

            return Scaffold(
              backgroundColor: kAppBg,
              appBar: AppTopBar(
                title: 'Timeline',
                actionLabel: '+ Thêm mốc',
                onAction: () => _addToTimeline(tasks, items),
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Group selector ──────────────────────────────────────────
                    _buildGroupSelector(),
                    const SizedBox(height: 12),

                    // ── Timeline content ────────────────────────────────────────
                    Expanded(
                      child: mobile
                          ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(width: 700, child: content),
                      )
                          : content,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
