import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

/// Service để import mock data vào Firestore (chạy 1 lần khi DB rỗng)
class SeedService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Kiểm tra Firestore có dữ liệu chưa, nếu rỗng thì import mock data
  static Future<void> seedIfEmpty(String userId) async {
    try {
      final groupsSnap = await _db.collection('groups').limit(1).get();
      if (groupsSnap.docs.isNotEmpty) return; // Đã có dữ liệu, không seed
    } catch (e) {
      // Permission denied hoặc lỗi khác — bỏ qua seed
      return;
    }

    // Import từng group mock
    for (final group in mockGroups) {
      // 1. Tạo document group
      final groupRef = await _db.collection('groups').add({
        'name': group.name,
        'description': group.description,
        'isActive': group.isActive,
        'createdBy': userId,
        'channels': group.channels,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Import members
      for (final member in group.members) {
        await groupRef.collection('members').add(member.toMap());
      }

      // 3. Import tasks (type = 'task')
      for (final task in group.tasks) {
        await groupRef.collection('tasks').add({
          ...task.toMap(),
          'type': 'task',
        });
      }

      // 4. Import kanban tasks (type = 'kanban')
      for (final task in group.kanbanTasks) {
        await groupRef.collection('tasks').add({
          ...task.toMap(),
          'type': 'kanban',
        });
      }

      // 5. Import messages
      for (final msg in group.messages) {
        await groupRef.collection('messages').add({
          'sender': msg.sender,
          'text': msg.text,
          'userId': msg.isMine ? userId : '',
          'channel': 'chung',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Import activities
      for (final activity in group.activities) {
        await groupRef.collection('activities').add(activity.toMap());
      }
    }
  }
}
