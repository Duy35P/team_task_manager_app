import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  String title;
  String status;   // todo | doing | done
  String assignee;
  String deadline;
  String type;     // 'task' | 'kanban'
  DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    this.status = 'todo',
    this.assignee = '',
    this.deadline = '',
    this.type = 'task',
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'status': status,
    'assignee': assignee,
    'deadline': deadline,
    'type': type,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory Task.fromMap(String id, Map<String, dynamic> map) => Task(
    id: id,
    title: map['title'] ?? '',
    status: map['status'] ?? 'todo',
    assignee: map['assignee'] ?? '',
    deadline: map['deadline'] ?? '',
    type: map['type'] ?? 'task',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );
}

class TimelineItem {
  final String id;
  final String taskId;
  final String title;
  final String label;
  final int colorValue;
  final int startCol;
  final int spanCols;
  DateTime? createdAt;

  TimelineItem({
    required this.id,
    required this.taskId,
    required this.title,
    required this.label,
    required this.colorValue,
    required this.startCol,
    required this.spanCols,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'taskId': taskId,
    'title': title,
    'label': label,
    'colorValue': colorValue,
    'startCol': startCol,
    'spanCols': spanCols,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory TimelineItem.fromMap(String id, Map<String, dynamic> map) => TimelineItem(
    id: id,
    taskId: map['taskId'] ?? '',
    title: map['title'] ?? '',
    label: map['label'] ?? '',
    colorValue: map['colorValue'] ?? 0xFF7B61FF,
    startCol: map['startCol'] ?? 0,
    spanCols: map['spanCols'] ?? 1,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );
}

class TeamMember {
  final String id;
  final String userId; // Firebase Auth UID của thành viên
  final String name;
  final String initials;
  final String role;
  final int taskCount;
  final int avatarColorIndex; // 0=purple 1=teal 2=coral
  TeamMember({
    this.id = '',
    this.userId = '',
    required this.name,
    required this.initials,
    required this.role,
    required this.taskCount,
    required this.avatarColorIndex,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'initials': initials,
    'role': role,
    'taskCount': taskCount,
    'avatarColorIndex': avatarColorIndex,
  };

  factory TeamMember.fromMap(String id, Map<String, dynamic> map) => TeamMember(
    id: id,
    userId: map['userId'] ?? '',
    name: map['name'] ?? '',
    initials: map['initials'] ?? '',
    role: map['role'] ?? 'Thành viên',
    taskCount: map['taskCount'] ?? 0,
    avatarColorIndex: map['avatarColorIndex'] ?? 3,
  );
}

class GroupActivity {
  final String id;
  final String actor;
  final String action;
  final String detail;
  final String time;
  final int colorIndex;
  DateTime? createdAt;

  GroupActivity({
    this.id = '',
    required this.actor,
    required this.action,
    required this.detail,
    required this.time,
    required this.colorIndex,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'actor': actor,
    'action': action,
    'detail': detail,
    'time': time,
    'colorIndex': colorIndex,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory GroupActivity.fromMap(String id, Map<String, dynamic> map) => GroupActivity(
    id: id,
    actor: map['actor'] ?? '',
    action: map['action'] ?? '',
    detail: map['detail'] ?? '',
    time: map['time'] ?? '',
    colorIndex: map['colorIndex'] ?? 3,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );
}

class Group {
  final String id;
  String name;
  String description;
  bool isActive;
  List<TeamMember> members;
  List<Task> tasks;
  List<Task> kanbanTasks;
  List<GroupActivity> activities;
  String createdBy;
  List<String> memberIds;

  Group({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
    required this.members,
    required this.tasks,
    required this.kanbanTasks,
    required this.activities,
    this.createdBy = '',
    List<String>? memberIds,
  }) : memberIds = memberIds ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'isActive': isActive,
    'createdBy': createdBy,
    'memberIds': memberIds,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Group.fromMap(String id, Map<String, dynamic> map) => Group(
    id: id,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
    createdBy: map['createdBy'] ?? '',
    memberIds: List<String>.from(map['memberIds'] ?? []),
    members: [],
    tasks: [],
    kanbanTasks: [],
    activities: [],
  );
}