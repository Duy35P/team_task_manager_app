import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/group_widgets.dart';
import '../responsive.dart';

class GroupsScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const GroupsScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _firestoreService = FirestoreService();

  // ── Tạo nhóm mới ──────────────────────────────────────────────────────────
  void _createGroup() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tạo nhóm mới',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
        content: SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _inputField(nameCtrl, 'Tên nhóm', 'VD: Team Backend Dev'),
            const SizedBox(height: 10),
            _inputField(descCtrl, 'Mô tả (tuỳ chọn)', 'Mô tả ngắn về nhóm...', maxLines: 2),
          ]),
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
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              final newGroup = Group(
                id: '',
                name: name,
                description: descCtrl.text.trim(),
                isActive: true,
                createdBy: userId,
                members: [],
                tasks: [],
                kanbanTasks: [],
                activities: [],
              );

              await _firestoreService.createGroup(newGroup, userId);

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Đã tạo nhóm "$name" thành công! 🎉'),
                  backgroundColor: kTeal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
              }
            },
            child: const Text('Tạo nhóm'),
          ),
        ],
      ),
    );
  }

  // ── Mời thành viên ────────────────────────────────────────────────────────
  void _inviteMember() {
    final emailCtrl = TextEditingController();
    String selRole  = 'Thành viên';
    final roles     = ['Thành viên', 'Admin'];
    final group     = widget.selectedGroup;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Mời thành viên',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
                const SizedBox(height: 4),
                Text('Nhập email để gửi lời mời tham gia ${group.name}.',
                    style: const TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 16),

                // Danh sách thành viên hiện tại
                StreamBuilder<List<TeamMember>>(
                  stream: _firestoreService.watchMembers(group.id),
                  builder: (context, snap) {
                    final members = snap.data ?? [];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kAppBg, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorder, width: 0.5),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Thành viên hiện tại',
                            style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        ...members.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            AppAvatar(initials: m.initials, colorIndex: m.avatarColorIndex, size: 24),
                            const SizedBox(width: 8),
                            Text(m.name, style: const TextStyle(fontSize: 12, color: kTextMain)),
                            const Spacer(),
                            Text(m.role == 'Admin' ? 'Leader' : 'Member',
                                style: TextStyle(fontSize: 11, color: m.role == 'Admin' ? kAccent : kTextMuted)),
                          ]),
                        )),
                      ]),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Email input
                const Text('Email thành viên mới',
                    style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 6),
                _inputField(emailCtrl, '', 'name@example.com', autofocus: true),
                const SizedBox(height: 12),

                // Vai trò
                const Text('Vai trò', style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 6),
                Row(children: roles.map((r) {
                  final active = selRole == r;
                  return GestureDetector(
                    onTap: () => setSheet(() => selRole = r),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? kAccentLight : kAppBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: active ? kAccent : kBorder,
                            width: active ? 1.5 : 0.5),
                      ),
                      child: Text(r, style: TextStyle(fontSize: 13,
                          color: active ? kAccent : kTextMuted,
                          fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent, foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) return;

                      // Tìm userId của người được mời
                      final invitedUserId = await _firestoreService.findUserIdByEmail(email);

                      if (invitedUserId == null) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Không tìm thấy tài khoản với email "$email"'),
                            backgroundColor: kCoral,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ));
                        }
                        return;
                      }

                      // Lấy thông tin user được mời
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users').doc(invitedUserId).get();
                      final userData = userDoc.data();
                      final memberName = userData?['name'] ?? email.split('@').first;
                      final initials = userData?['initials'] ?? email.substring(0, 2).toUpperCase();

                      // Thêm vào subcollection members
                      final newMember = TeamMember(
                        name: memberName,
                        initials: initials,
                        role: selRole,
                        taskCount: 0,
                        avatarColorIndex: 3,
                      );
                      await _firestoreService.addMember(group.id, newMember);

                      // Thêm userId vào memberIds để user thấy group
                      await _firestoreService.addMemberById(group.id, invitedUserId);

                      // Add activity
                      final currentUser = FirebaseAuth.instance.currentUser;
                      await _firestoreService.addActivity(group.id, GroupActivity(
                        actor: currentUser?.displayName ?? 'User',
                        action: 'đã mời',
                        detail: memberName,
                        time: 'Vừa xong',
                        colorIndex: 0,
                      ));

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Đã thêm $memberName vào nhóm! ✅'),
                          backgroundColor: kTeal,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ));
                      }
                    },
                    child: const Text('Gửi lời mời', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Xem chi tiết thành viên ───────────────────────────────────────────────
  void _viewMember(TeamMember member) {
    final group = widget.selectedGroup;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          AppAvatar(initials: member.initials, colorIndex: member.avatarColorIndex, size: 56),
          const SizedBox(height: 12),
          Text(member.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
          const SizedBox(height: 4),
          Text(member.role == 'Admin' ? 'Leader' : 'Thành viên',
              style: TextStyle(fontSize: 12, color: member.role == 'Admin' ? kAccent : kTextMuted)),
          const SizedBox(height: 16),
          _infoRow(Icons.task_alt_outlined, '${member.taskCount} task đang thực hiện'),
          const SizedBox(height: 8),
          _infoRow(Icons.group_outlined, group.name),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: kTextMuted)),
          ),
          if (member.role != 'Admin')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kCoralLight, foregroundColor: kCoral,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _firestoreService.removeMember(group.id, member.id);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã xoá ${member.name} khỏi nhóm'),
                    backgroundColor: kCoral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                }
              },
              child: const Text('Xoá khỏi nhóm'),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 16, color: kTextMuted),
    const SizedBox(width: 6),
    Text(text, style: const TextStyle(fontSize: 13, color: kTextMuted)),
  ]);

  Widget _inputField(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1, bool autofocus = false}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        autofocus: autofocus,
        style: const TextStyle(fontSize: 13, color: kTextMain),
        decoration: InputDecoration(
          labelText: label.isNotEmpty ? label : null,
          labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted),
          isDense: true,
          filled: true,
          fillColor: kAppBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder, width: 0.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kAccent)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final group  = widget.selectedGroup;

    Widget groupListSidebar() => AppCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            const Text('Nhóm của tôi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMain)),
            const Spacer(),
            GestureDetector(
              onTap: _createGroup,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(6)),
                child: const Text('+ Tạo',
                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
        ),
        const Divider(height: 0, color: kBorder, thickness: 0.5),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: widget.groups.asMap().entries.map((entry) {
              final i = entry.key;
              final g = entry.value;
              final active = i == widget.selectedGroupIndex;
              return GestureDetector(
                onTap: () => widget.onGroupChanged(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? kAccentLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: active ? kAccent : kAppBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          g.name.split(' ').last.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : kTextMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(g.name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                                color: active ? kAccent : kTextMain)),
                        Text(g.description.isNotEmpty ? g.description : 'Nhóm',
                            style: const TextStyle(fontSize: 11, color: kTextMuted)),
                      ]),
                    ),
                    if (active)
                      const Icon(Icons.check_circle, color: kAccent, size: 16),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );

    Widget membersCard() => AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(group.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
          ),
          AppBadge(
            label: group.isActive ? 'Hoạt động' : 'Tạm dừng',
            bg: group.isActive ? kTealLight : kAppBg,
            fg: group.isActive ? kTeal : kTextMuted,
          ),
        ]),
        const SizedBox(height: 6),
        Text('${group.description}',
            style: const TextStyle(fontSize: 12, color: kTextMuted)),
        const SizedBox(height: 16),
        // Members from Firestore
        StreamBuilder<List<TeamMember>>(
          stream: _firestoreService.watchMembers(group.id),
          builder: (context, snap) {
            final members = snap.data ?? [];
            return Column(children: [
              ...members.map((m) => GestureDetector(
                onTap: () => _viewMember(m),
                child: MemberRow(member: m),
              )),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _inviteMember,
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
            ]);
          },
        ),
      ]),
    );

    Widget activityCard() => AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Hoạt động nhóm',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMain)),
        const SizedBox(height: 14),
        StreamBuilder<List<GroupActivity>>(
          stream: _firestoreService.watchActivities(group.id),
          builder: (context, snap) {
            final activities = snap.data ?? [];
            if (activities.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('Chưa có hoạt động',
                      style: TextStyle(fontSize: 12, color: kTextMuted)),
                ),
              );
            }
            return Column(children: activities.map((a) => ActivityRow(activity: a)).toList());
          },
        ),
      ]),
    );

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(title: 'Nhóm của tôi', actionLabel: '+ Tạo nhóm', onAction: _createGroup),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: mobile
            ? ListView(children: [
                // Mobile: dropdown chọn nhóm ở trên
                _mobileGroupDropdown(),
                const SizedBox(height: 16),
                membersCard(),
                const SizedBox(height: 16),
                activityCard(),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Desktop: sidebar danh sách nhóm bên trái
                SizedBox(width: 260, child: groupListSidebar()),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    membersCard(),
                    const SizedBox(height: 16),
                    activityCard(),
                  ]),
                ),
              ]),
      ),
    );
  }

  // ── Mobile group dropdown ─────────────────────────────────────────────────
  Widget _mobileGroupDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorder, width: 0.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value: widget.selectedGroupIndex,
        icon: const Icon(Icons.expand_more, color: kTextMuted, size: 20),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kTextMain),
        items: widget.groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          return DropdownMenuItem<int>(
            value: i,
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: g.isActive ? kTeal : kTextMuted,
                ),
              ),
              const SizedBox(width: 10),
              Text(g.name),
            ]),
          );
        }).toList(),
        onChanged: (i) {
          if (i != null) widget.onGroupChanged(i);
        },
      ),
    ),
  );
}