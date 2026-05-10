import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════════════════════════════
  // ── GROUPS ──────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream danh sách groups của user
  Stream<List<Group>> watchGroups(String userId) {
    return _db.collection('groups').snapshots().map((snap) =>
      snap.docs.map((doc) => Group.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Tạo group mới
  Future<String> createGroup(Group group, String userId) async {
    final ref = await _db.collection('groups').add(group.toMap());

    // Thêm creator vào subcollection members
    final userDoc = await _db.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final name = userData?['name'] ?? 'User';
    final initials = userData?['initials'] ?? 'U';

    await ref.collection('members').add(TeamMember(
      name: name,
      initials: initials,
      role: 'Admin',
      taskCount: 0,
      avatarColorIndex: 0,
    ).toMap());

    return ref.id;
  }

  /// Cập nhật group
  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    await _db.collection('groups').doc(groupId).update(data);
  }

  /// Xóa group
  Future<void> deleteGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).delete();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── TASKS ──────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream tasks của group (lọc theo type nếu cần)
  Stream<List<Task>> watchTasks(String groupId, {String? type}) {
    Query<Map<String, dynamic>> query = _db
        .collection('groups').doc(groupId)
        .collection('tasks');

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snap) =>
      snap.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Tạo task mới
  Future<void> createTask(String groupId, Task task) async {
    await _db.collection('groups').doc(groupId)
        .collection('tasks').add(task.toMap());
  }

  /// Cập nhật status task
  Future<void> updateTaskStatus(String groupId, String taskId, String status) async {
    await _db.collection('groups').doc(groupId)
        .collection('tasks').doc(taskId).update({'status': status});
  }

  /// Xóa task
  Future<void> deleteTask(String groupId, String taskId) async {
    await _db.collection('groups').doc(groupId)
        .collection('tasks').doc(taskId).delete();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── TIMELINE ────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  Stream<List<TimelineItem>> watchTimeline(String groupId) {
    return _db.collection('groups').doc(groupId)
        .collection('timeline')
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((doc) =>
          TimelineItem.fromMap(doc.id, doc.data())).toList();
      items.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(2000);
        final bTime = b.createdAt ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });
      return items;
    });
  }

  Future<void> addTimelineItem(String groupId, TimelineItem item) async {
    await _db.collection('groups').doc(groupId)
        .collection('timeline').add(item.toMap());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── MEMBERS ────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream thành viên nhóm
  Stream<List<TeamMember>> watchMembers(String groupId) {
    return _db.collection('groups').doc(groupId)
        .collection('members').snapshots().map((snap) =>
      snap.docs.map((doc) => TeamMember.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Thêm thành viên
  Future<void> addMember(String groupId, TeamMember member) async {
    await _db.collection('groups').doc(groupId)
        .collection('members').add(member.toMap());
  }

  /// Xóa thành viên
  Future<void> removeMember(String groupId, String memberId) async {
    await _db.collection('groups').doc(groupId)
        .collection('members').doc(memberId).delete();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── MESSAGES ───────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream tin nhắn (theo channel)
  Stream<List<Message>> watchMessages(String groupId, String channel) {
    return _db.collection('groups').doc(groupId)
        .collection('messages')
        .where('channel', isEqualTo: channel)
        .snapshots().map((snap) {
      final msgs = snap.docs.map((doc) => Message.fromMap(doc.id, doc.data())).toList();
      // Sort client-side để tránh cần composite index
      msgs.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(2000);
        final bTime = b.createdAt ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });
      return msgs;
    });
  }

  /// Gửi tin nhắn
  Future<void> sendMessage(String groupId, Message msg) async {
    await _db.collection('groups').doc(groupId)
        .collection('messages').add(msg.toMap());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── ACTIVITIES ─────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream hoạt động nhóm
  Stream<List<GroupActivity>> watchActivities(String groupId) {
    return _db.collection('groups').doc(groupId)
        .collection('activities')
        .snapshots().map((snap) {
      final activities = snap.docs.map((doc) => GroupActivity.fromMap(doc.id, doc.data())).toList();
      // Sort mới nhất trước
      activities.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(2000);
        final bTime = b.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return activities;
    });
  }

  /// Thêm hoạt động
  Future<void> addActivity(String groupId, GroupActivity activity) async {
    await _db.collection('groups').doc(groupId)
        .collection('activities').add(activity.toMap());
  }
}
