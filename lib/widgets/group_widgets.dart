import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class MemberRow extends StatelessWidget {
  final TeamMember member;
  const MemberRow({super.key, required this.member});

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
              fontSize: 11, fontWeight: FontWeight.w500,
              color: member.role == 'Admin' ? kAccent : kTextMuted),
        ),
      ),
      const SizedBox(width: 6),
      const Icon(Icons.chevron_right, size: 16, color: kTextMuted),
    ]),
  );
}

class ActivityRow extends StatelessWidget {
  final GroupActivity activity;
  const ActivityRow({super.key, required this.activity});

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
          Text(activity.detail, style: const TextStyle(fontSize: 11, color: kTextMuted)),
        ]),
      ),
      Text(activity.time, style: const TextStyle(fontSize: 11, color: kTextMuted)),
    ]),
  );
}
