import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'home_screen.dart';
import 'responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Dashboard', actionLabel: '+ Tạo mới', onAction: () {}),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: mobile ? width - 40 : 200,
                child: _StatCard(num: '24', label: 'Tổng công việc', badge: '+3 hôm nay', badgeBg: kAccentLight, badgeFg: kAccent),
              ),
              SizedBox(
                width: mobile ? width - 40 : 200,
                child: _StatCard(num: '9', label: 'Đang thực hiện', badge: 'Cần chú ý', badgeBg: kAmberLight, badgeFg: kAmber),
              ),
              SizedBox(
                width: mobile ? width - 40 : 200,
                child: _StatCard(num: '12', label: 'Hoàn thành', badge: '+2 hôm nay', badgeBg: kTealLight, badgeFg: kTeal),
              ),
              SizedBox(
                width: mobile ? width - 40 : 200,
                child: _StatCard(num: '3', label: 'Quá hạn', badge: 'Cần xử lý', badgeBg: kCoralLight, badgeFg: kCoral),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (mobile)
            Column(
              children: [
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('Việc gần đây',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
                      const Spacer(),
                      Text('Xem tất cả',
                          style: TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 12),
                    ...mockTasks.take(4).map((t) => _TaskRow(task: t)),
                  ]),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tiến độ nhóm',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
                    const SizedBox(height: 14),
                    _ProgressRow(label: 'Sprint 1 — Auth Module', pct: 0.80, color: kAccent, pctStr: '80%'),
                    const SizedBox(height: 12),
                    _ProgressRow(label: 'Sprint 2 — Task CRUD', pct: 0.45, color: kTeal, pctStr: '45%'),
                    const SizedBox(height: 12),
                    _ProgressRow(label: 'Sprint 3 — Kanban Board', pct: 0.20, color: kAmber, pctStr: '20%'),
                    const SizedBox(height: 18),
                    const Text('THÀNH VIÊN',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                            color: kTextMuted, letterSpacing: 0.08)),
                    const SizedBox(height: 10),
                    Row(children: [
                      const AppAvatar(initials: 'MH', colorIndex: 0),
                      const SizedBox(width: 8),
                      const Text('Minh', style: TextStyle(fontSize: 12, color: kTextMain)),
                      const SizedBox(width: 14),
                      const AppAvatar(initials: 'AN', colorIndex: 1),
                      const SizedBox(width: 8),
                      const Text('An', style: TextStyle(fontSize: 12, color: kTextMain)),
                      const SizedBox(width: 14),
                      const AppAvatar(initials: 'TL', colorIndex: 2),
                      const SizedBox(width: 8),
                      const Text('Linh', style: TextStyle(fontSize: 12, color: kTextMain)),
                    ]),
                  ]),
                ),
              ],
            )
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('Việc gần đây',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
                      const Spacer(),
                      Text('Xem tất cả',
                          style: TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 12),
                    ...mockTasks.take(4).map((t) => _TaskRow(task: t)),
                  ]),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 320,
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tiến độ nhóm',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
                    const SizedBox(height: 14),
                    _ProgressRow(label: 'Sprint 1 — Auth Module', pct: 0.80, color: kAccent, pctStr: '80%'),
                    const SizedBox(height: 12),
                    _ProgressRow(label: 'Sprint 2 — Task CRUD', pct: 0.45, color: kTeal, pctStr: '45%'),
                    const SizedBox(height: 12),
                    _ProgressRow(label: 'Sprint 3 — Kanban Board', pct: 0.20, color: kAmber, pctStr: '20%'),
                    const SizedBox(height: 18),
                    const Text('THÀNH VIÊN',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                            color: kTextMuted, letterSpacing: 0.08)),
                    const SizedBox(height: 10),
                    Row(children: [
                      const AppAvatar(initials: 'MH', colorIndex: 0),
                      const SizedBox(width: 8),
                      const Text('Minh', style: TextStyle(fontSize: 12, color: kTextMain)),
                      const SizedBox(width: 14),
                      const AppAvatar(initials: 'AN', colorIndex: 1),
                      const SizedBox(width: 8),
                      const Text('An', style: TextStyle(fontSize: 12, color: kTextMain)),
                      const SizedBox(width: 14),
                      const AppAvatar(initials: 'TL', colorIndex: 2),
                      const SizedBox(width: 8),
                      const Text('Linh', style: TextStyle(fontSize: 12, color: kTextMain)),
                    ]),
                  ]),
                ),
              ),
            ]),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num, label, badge;
  final Color badgeBg, badgeFg;
  const _StatCard({required this.num, required this.label, required this.badge,
    required this.badgeBg, required this.badgeFg});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(num, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: kTextMain)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: kTextMuted)),
      const SizedBox(height: 8),
      AppBadge(label: badge, bg: badgeBg, fg: badgeFg),
    ]),
  );
}

class _TaskRow extends StatelessWidget {
  final Task task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        // Check circle
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? kTeal : Colors.transparent,
            border: Border.all(color: isDone ? kTeal : kBorder, width: 1.5),
          ),
          child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title,
                style: TextStyle(
                    fontSize: 12,
                    color: isDone ? kTextMuted : kTextMain,
                    decoration: isDone ? TextDecoration.lineThrough : null)),
            const SizedBox(height: 2),
            Text('${isDone ? "Hôm qua" : task.deadline} · ${task.assignee == "MH" ? "Minh Hoàng" : task.assignee == "AN" ? "An Nhiên" : "Nhóm"}',
                style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ]),
        ),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? kTeal : task.priority == 'Cao' ? kCoral : kAmber,
          ),
        ),
      ]),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label, pctStr;
  final double pct;
  final Color color;
  const _ProgressRow({required this.label, required this.pct, required this.color, required this.pctStr});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: kTextMain))),
        Text(pctStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          backgroundColor: kAppBg,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ],
  );
}