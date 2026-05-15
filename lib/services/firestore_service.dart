import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════════════════════════════
  // ── GROUPS ──────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream danh sách groups mà user là thành viên
  Stream<List<Group>> watchGroups(String userId) {
    return _db.collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots().map((snap) =>
      snap.docs.map((doc) => Group.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Tạo group mới
  Future<String> createGroup(Group group, String userId) async {
    // Đảm bảo creator nằm trong memberIds
    if (!group.memberIds.contains(userId)) {
      group.memberIds.add(userId);
    }
    final ref = await _db.collection('groups').add(group.toMap());

    // Thêm creator vào subcollection members
    final userDoc = await _db.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final name = userData?['name'] ?? 'User';
    final initials = userData?['initials'] ?? 'U';

    await ref.collection('members').add(TeamMember(
      userId: userId,
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
    if (groupId.isEmpty) return Stream.value([]);
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

  /// Tạo task ở tất cả nơi: task list, kanban, và timeline
  Future<void> createTaskEverywhere({
    required String groupId,
    required String title,
    required String status,
    required String assignee,
    required String deadline,
  }) async {
    // 1. Tạo task cho Tasks screen
    final taskDoc = await _db.collection('groups').doc(groupId)
        .collection('tasks').add(Task(
      id: '',
      title: title,
      status: status,
      assignee: assignee,
      deadline: deadline,
      type: 'task',
    ).toMap());

    // 2. Tạo task cho Kanban screen
    await _db.collection('groups').doc(groupId)
        .collection('tasks').add(Task(
      id: '',
      title: title,
      status: status,
      assignee: assignee,
      deadline: deadline,
      type: 'kanban',
    ).toMap());

    // 3. Tạo timeline item
    final statusLabel = switch (status) {
      'done'  => 'Hoàn thành',
      'doing' => 'Đang làm',
      _       => 'Chờ làm',
    };
    final statusColor = switch (status) {
      'done'  => 0xFF26A69A,  // kTeal
      'doing' => 0xFFFFB74D,  // kAmber
      _       => 0xFF7B61FF,  // kAccent
    };
    await _db.collection('groups').doc(groupId)
        .collection('timeline').add(TimelineItem(
      id: '',
      taskId: taskDoc.id,
      title: title,
      label: statusLabel,
      colorValue: statusColor,
      startCol: 0,
      spanCols: 1,
    ).toMap());
  }

  /// Cập nhật status task + đồng bộ sang type kia (task↔kanban) và timeline
  Future<void> updateTaskStatus(String groupId, String taskId, String status) async {
    final tasksCol = _db.collection('groups').doc(groupId).collection('tasks');

    // 1. Cập nhật task hiện tại
    final doc = await tasksCol.doc(taskId).get();
    if (!doc.exists) return;
    await tasksCol.doc(taskId).update({'status': status});

    final data = doc.data()!;
    final title = data['title'] as String? ?? '';
    final currentType = data['type'] as String? ?? 'task';
    final otherType = currentType == 'task' ? 'kanban' : 'task';

    // 2. Đồng bộ sang type kia (tìm theo title)
    final otherSnap = await tasksCol
        .where('type', isEqualTo: otherType)
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    for (final d in otherSnap.docs) {
      await d.reference.update({'status': status});
    }

    // 3. Cập nhật timeline item (tìm theo taskId hoặc title)
    final statusLabel = switch (status) {
      'done'  => 'Hoàn thành',
      'doing' => 'Đang làm',
      _       => 'Chờ làm',
    };
    final statusColor = switch (status) {
      'done'  => 0xFF26A69A,
      'doing' => 0xFFFFB74D,
      _       => 0xFF7B61FF,
    };
    final tlCol = _db.collection('groups').doc(groupId).collection('timeline');
    var tlSnap = await tlCol.where('taskId', isEqualTo: taskId).get();
    // Fallback: tìm theo title nếu taskId không khớp (VD: kanban task ID khác task ID)
    if (tlSnap.docs.isEmpty && title.isNotEmpty) {
      tlSnap = await tlCol.where('title', isEqualTo: title).get();
    }
    for (final d in tlSnap.docs) {
      await d.reference.update({'label': statusLabel, 'colorValue': statusColor});
    }
  }

  /// Cập nhật thông tin task (title, assignee, deadline, status)
  Future<void> updateTask(String groupId, String taskId, {
    String? title,
    String? status,
    String? assignee,
    String? deadline,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (status != null) updates['status'] = status;
    if (assignee != null) updates['assignee'] = assignee;
    if (deadline != null) updates['deadline'] = deadline;
    if (updates.isEmpty) return;

    final tasksCol = _db.collection('groups').doc(groupId).collection('tasks');
    final doc = await tasksCol.doc(taskId).get();
    if (!doc.exists) return;

    final oldTitle = doc.data()?['title'] as String? ?? '';
    final currentType = doc.data()?['type'] as String? ?? 'task';
    final otherType = currentType == 'task' ? 'kanban' : 'task';

    await tasksCol.doc(taskId).update(updates);

    // Đồng bộ sang type kia
    final otherSnap = await tasksCol
        .where('type', isEqualTo: otherType)
        .where('title', isEqualTo: oldTitle)
        .limit(1)
        .get();
    for (final d in otherSnap.docs) {
      await d.reference.update(updates);
    }

    // Cập nhật timeline nếu title thay đổi hoặc status thay đổi
    final tlCol = _db.collection('groups').doc(groupId).collection('timeline');
    var tlSnap = await tlCol.where('taskId', isEqualTo: taskId).get();
    if (tlSnap.docs.isEmpty && oldTitle.isNotEmpty) {
      tlSnap = await tlCol.where('title', isEqualTo: oldTitle).get();
    }
    if (tlSnap.docs.isNotEmpty) {
      final tlUpdates = <String, dynamic>{};
      if (title != null) tlUpdates['title'] = title;
      if (status != null) {
        tlUpdates['label'] = switch (status) {
          'done'  => 'Hoàn thành',
          'doing' => 'Đang làm',
          _       => 'Chờ làm',
        };
        tlUpdates['colorValue'] = switch (status) {
          'done'  => 0xFF26A69A,
          'doing' => 0xFFFFB74D,
          _       => 0xFF7B61FF,
        };
      }
      if (tlUpdates.isNotEmpty) {
        for (final d in tlSnap.docs) {
          await d.reference.update(tlUpdates);
        }
      }
    }
  }

  /// Xóa task
  Future<void> deleteTask(String groupId, String taskId) async {
    await _db.collection('groups').doc(groupId)
        .collection('tasks').doc(taskId).delete();
  }

  /// Xóa task ở tất cả nơi (task, kanban, timeline)
  Future<void> deleteTaskEverywhere(String groupId, String taskId) async {
    final tasksCol = _db.collection('groups').doc(groupId).collection('tasks');
    final doc = await tasksCol.doc(taskId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final title = data['title'] as String? ?? '';
    final currentType = data['type'] as String? ?? 'task';
    final otherType = currentType == 'task' ? 'kanban' : 'task';

    // Xóa task hiện tại
    await tasksCol.doc(taskId).delete();

    // Xóa task type kia
    final otherSnap = await tasksCol
        .where('type', isEqualTo: otherType)
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    for (final d in otherSnap.docs) {
      await d.reference.delete();
    }

    // Xóa timeline item
    final tlCol = _db.collection('groups').doc(groupId).collection('timeline');
    var tlSnap = await tlCol.where('taskId', isEqualTo: taskId).get();
    if (tlSnap.docs.isEmpty && title.isNotEmpty) {
      tlSnap = await tlCol.where('title', isEqualTo: title).get();
    }
    for (final d in tlSnap.docs) {
      await d.reference.delete();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── TIMELINE ────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════
  Stream<List<TimelineItem>> watchTimeline(String groupId) {
    if (groupId.isEmpty) return Stream.value([]);
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
    if (groupId.isEmpty) return Stream.value([]);
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

  /// Xóa thành viên (xóa khỏi subcollection members VÀ khỏi memberIds)
  Future<void> removeMember(String groupId, String memberId) async {
    // Đọc member doc để lấy userId trước khi xóa
    final memberDoc = await _db.collection('groups').doc(groupId)
        .collection('members').doc(memberId).get();
    final memberUserId = memberDoc.data()?['userId'] as String? ?? '';

    // Xóa khỏi subcollection members
    await _db.collection('groups').doc(groupId)
        .collection('members').doc(memberId).delete();

    // Xóa userId khỏi memberIds array để user không còn thấy group
    if (memberUserId.isNotEmpty) {
      await _db.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([memberUserId]),
      });
    }
  }

  /// Thêm userId vào memberIds của group (để user thấy group)
  Future<void> addMemberById(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Tìm userId bằng email từ collection users
  Future<String?> findUserIdByEmail(String email) async {
    final snap = await _db.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }



  // ══════════════════════════════════════════════════════════════════════════
  // ── ACTIVITIES ─────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy stream hoạt động nhóm
  Stream<List<GroupActivity>> watchActivities(String groupId) {
    if (groupId.isEmpty) return Stream.value([]);
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
