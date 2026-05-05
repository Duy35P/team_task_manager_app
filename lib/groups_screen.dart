import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'home_screen.dart';
import 'responsive.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Nhóm của tôi', actionLabel: '+ Tạo nhóm', onAction: () {}),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: mobile
            ? Column(children: [
          Expanded(
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(
                    child: Text('Team Flutter Dev',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
                  ),
                  AppBadge(label: 'Hoạt động', bg: kTealLight, fg: kTeal),
                ]),
                const SizedBox(height: 6),
                const Text('Nhóm phát triển app quản lý công việc · 3 thành viên',
                    style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 16),
                ...mockMembers.map((m) => _MemberRow(member: m)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder, width: 0.5),
                    ),
                    child: const Center(
                      child: Text('+ Mời thành viên',
                          style: TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Hoạt động nhóm',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMain)),
                const SizedBox(height: 14),
                ...mockActivities.map((a) => _ActivityRow(activity: a)),
              ]),
            ),
          ),
        ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(
                    child: Text('Team Flutter Dev',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
                  ),
                  AppBadge(label: 'Hoạt động', bg: kTealLight, fg: kTeal),
                ]),
                const SizedBox(height: 6),
                const Text('Nhóm phát triển app quản lý công việc · 3 thành viên',
                    style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 16),
                ...mockMembers.map((m) => _MemberRow(member: m)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder, width: 0.5),
                    ),
                    child: const Center(
                      child: Text('+ Mời thành viên',
                          style: TextStyle(fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 320,
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Hoạt động nhóm',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMain)),
                const SizedBox(height: 14),
                ...mockActivities.map((a) => _ActivityRow(activity: a)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final TeamMember member;
  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5))),
    child: Row(children: [
      AppAvatar(initials: member.initials, colorIndex: member.avatarColorIndex, size: 36),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
          Text('${member.role} · ${member.taskCount} task',
              style: const TextStyle(fontSize: 11, color: kTextMuted)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: member.role == 'Admin' ? kAccentLight : kAppBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: Text(
          member.role == 'Admin' ? 'Leader' : 'Member',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: member.role == 'Admin' ? kAccent : kTextMuted),
        ),
      ),
    ]),
  );
}

class _ActivityRow extends StatelessWidget {
  final GroupActivity activity;
  const _ActivityRow({required this.activity});

  static const _dotColors = [kAccent, kTeal, kCoral, kAmber];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dotColors[activity.colorIndex.clamp(0, 3)],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${activity.actor} ${activity.action}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMain)),
          Text(activity.detail,
              style: const TextStyle(fontSize: 11, color: kTextMuted)),
        ]),
      ),
      Text(activity.time, style: const TextStyle(fontSize: 11, color: kTextMuted)),
    ]),
  );
}