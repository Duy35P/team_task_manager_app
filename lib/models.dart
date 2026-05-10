// ── Models ────────────────────────────────────────────────────────────────────
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

class Message {
  final String id;
  final String sender;
  final String text;
  final bool isMine;
  final String userId;
  final String channel;
  DateTime? createdAt;

  Message({
    this.id = '',
    required this.sender,
    required this.text,
    this.isMine = false,
    this.userId = '',
    this.channel = 'chung',
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'sender': sender,
    'text': text,
    'userId': userId,
    'channel': channel,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory Message.fromMap(String id, Map<String, dynamic> map) => Message(
    id: id,
    sender: map['sender'] ?? '',
    text: map['text'] ?? '',
    userId: map['userId'] ?? '',
    channel: map['channel'] ?? 'chung',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );
}

class TeamMember {
  final String id;
  final String name;
  final String initials;
  final String role;
  final int taskCount;
  final int avatarColorIndex; // 0=purple 1=teal 2=coral
  TeamMember({
    this.id = '',
    required this.name,
    required this.initials,
    required this.role,
    required this.taskCount,
    required this.avatarColorIndex,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'initials': initials,
    'role': role,
    'taskCount': taskCount,
    'avatarColorIndex': avatarColorIndex,
  };

  factory TeamMember.fromMap(String id, Map<String, dynamic> map) => TeamMember(
    id: id,
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

// ── Group model ───────────────────────────────────────────────────────────────

class Group {
  final String id;
  String name;
  String description;
  bool isActive;
  List<TeamMember> members;
  List<Task> tasks;
  List<Task> kanbanTasks;
  List<Message> messages;
  List<GroupActivity> activities;
  List<String> channels;
  String createdBy;

  Group({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
    required this.members,
    required this.tasks,
    required this.kanbanTasks,
    required this.messages,
    required this.activities,
    List<String>? channels,
    this.createdBy = '',
  }) : channels = channels ?? ['chung', 'dev', 'design'];

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'isActive': isActive,
    'createdBy': createdBy,
    'channels': channels,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Group.fromMap(String id, Map<String, dynamic> map) => Group(
    id: id,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
    createdBy: map['createdBy'] ?? '',
    channels: List<String>.from(map['channels'] ?? ['chung', 'dev', 'design']),
    members: [],
    tasks: [],
    kanbanTasks: [],
    messages: [],
    activities: [],
  );
}

// ── Mock data (giữ lại để seed vào Firestore) ────────────────────────────────

final List<Task> mockTasks = [
  Task(id: '1', title: 'Thiết kế màn hình Login',     status: 'done',  assignee: 'MH', deadline: '20/04'),
  Task(id: '2', title: 'Viết API xác thực người dùng', status: 'doing', assignee: 'AN', deadline: 'Hôm nay'),
  Task(id: '3', title: 'Kết nối Firestore với Tasks',  status: 'todo',  assignee: 'MH', deadline: '28/04'),
  Task(id: '4', title: 'Xây dựng Kanban Board UI',     status: 'doing', assignee: 'TL', deadline: '02/05'),
  Task(id: '5', title: 'Tích hợp Firebase Messaging',  status: 'todo',  assignee: 'AN', deadline: '10/05'),
];

final List<Task> mockKanbanTasks = [
  Task(id: 'k1', title: 'Tích hợp push notification',  status: 'todo',  assignee: 'AN', type: 'kanban'),
  Task(id: 'k2', title: 'Màn hình setting tài khoản',  status: 'todo',  assignee: 'TL', type: 'kanban'),
  Task(id: 'k3', title: 'Viết unit test auth module',  status: 'todo',  assignee: 'MH', type: 'kanban'),
  Task(id: 'k4', title: 'Viết API xác thực user',      status: 'doing', assignee: 'AN', type: 'kanban'),
  Task(id: 'k5', title: 'Xây dựng Kanban Board UI',    status: 'doing', assignee: 'TL', type: 'kanban'),
  Task(id: 'k6', title: 'Kết nối Firestore realtime',  status: 'doing', assignee: 'MH', type: 'kanban'),
  Task(id: 'k7', title: 'Setup project Flutter ban đầu', status: 'done', assignee: 'MH', type: 'kanban'),
  Task(id: 'k8', title: 'Thiết kế màn hình Login',     status: 'done',  assignee: 'TL', type: 'kanban'),
];

final List<Message> mockMessages = [
  Message(sender: 'An Nhiên',  text: 'Mình vừa push xong code auth lên nhánh feature/auth nhé mọi người!'),
  Message(sender: 'Thu Linh',  text: 'Oke mình sẽ review sau. Đang làm kanban UI, xong rồi merge cùng nhé'),
  Message(sender: 'Minh Hoàng', text: 'Tốt lắm! Nhớ viết test cho auth module nha An. Deadline sprint 1 cuối tuần này rồi', isMine: true),
];

final List<TeamMember> mockMembers = [
  TeamMember(name: 'Minh Hoàng', initials: 'MH', role: 'Admin',    taskCount: 8, avatarColorIndex: 0),
  TeamMember(name: 'An Nhiên',   initials: 'AN', role: 'Thành viên', taskCount: 5, avatarColorIndex: 1),
  TeamMember(name: 'Thu Linh',   initials: 'TL', role: 'Thành viên', taskCount: 4, avatarColorIndex: 2),
];

final List<GroupActivity> mockActivities = [
  GroupActivity(actor: 'An Nhiên',   action: 'hoàn thành task',  detail: 'Viết API xác thực người dùng', time: '10 phút',  colorIndex: 1),
  GroupActivity(actor: 'Minh Hoàng', action: 'tạo task mới',     detail: 'Kết nối Firestore với Groups',  time: '1 giờ',    colorIndex: 0),
  GroupActivity(actor: 'Thu Linh',   action: 'nhận task',        detail: 'Xây dựng Kanban Board UI',      time: '3 giờ',    colorIndex: 2),
  GroupActivity(actor: 'Nhóm',       action: 'được tạo',         detail: 'Bắt đầu sprint 1',              time: '2 ngày',   colorIndex: 3),
];

// ── Mock Groups ───────────────────────────────────────────────────────────────

final List<Group> mockGroups = [
  // Nhóm 1 — Team Flutter Dev (dùng lại data mock cũ)
  Group(
    id: 'g1',
    name: 'Team Flutter Dev',
    description: 'Nhóm phát triển app quản lý công việc',
    isActive: true,
    members: List.from(mockMembers),
    tasks: List.from(mockTasks),
    kanbanTasks: List.from(mockKanbanTasks),
    messages: List.from(mockMessages),
    activities: List.from(mockActivities),
    channels: ['chung', 'dev', 'design'],
  ),

  // Nhóm 2 — Team Backend API
  Group(
    id: 'g2',
    name: 'Team Backend API',
    description: 'Nhóm phát triển API và hệ thống backend',
    isActive: true,
    members: [
      TeamMember(name: 'Minh Hoàng', initials: 'MH', role: 'Admin',     taskCount: 4, avatarColorIndex: 0),
      TeamMember(name: 'Đức Anh',    initials: 'DA', role: 'Thành viên', taskCount: 6, avatarColorIndex: 1),
      TeamMember(name: 'Hải Nam',    initials: 'HN', role: 'Thành viên', taskCount: 3, avatarColorIndex: 2),
      TeamMember(name: 'Phương Mai', initials: 'PM', role: 'Thành viên', taskCount: 2, avatarColorIndex: 3),
    ],
    tasks: [
      Task(id: 'b1', title: 'Thiết kế Database Schema',     status: 'done',  assignee: 'DA', deadline: '18/04'),
      Task(id: 'b2', title: 'Xây dựng REST API User',       status: 'done',  assignee: 'MH', deadline: '22/04'),
      Task(id: 'b3', title: 'Viết API quản lý Tasks',       status: 'doing', assignee: 'DA', deadline: 'Hôm nay'),
      Task(id: 'b4', title: 'Tích hợp WebSocket cho Chat',  status: 'doing', assignee: 'HN', deadline: '05/05'),
      Task(id: 'b5', title: 'Cấu hình CI/CD Pipeline',      status: 'todo',  assignee: 'PM', deadline: '12/05'),
      Task(id: 'b6', title: 'Viết Unit Test cho API',        status: 'todo',  assignee: 'DA', deadline: '15/05'),
    ],
    kanbanTasks: [
      Task(id: 'bk1', title: 'API endpoint /groups',         status: 'todo',  assignee: 'DA', type: 'kanban'),
      Task(id: 'bk2', title: 'Middleware xác thực JWT',       status: 'todo',  assignee: 'HN', type: 'kanban'),
      Task(id: 'bk3', title: 'Rate limiting module',          status: 'todo',  assignee: 'PM', type: 'kanban'),
      Task(id: 'bk4', title: 'API quản lý Tasks',             status: 'doing', assignee: 'DA', type: 'kanban'),
      Task(id: 'bk5', title: 'WebSocket server setup',        status: 'doing', assignee: 'HN', type: 'kanban'),
      Task(id: 'bk6', title: 'Database Schema migration',     status: 'done',  assignee: 'DA', type: 'kanban'),
      Task(id: 'bk7', title: 'REST API User CRUD',            status: 'done',  assignee: 'MH', type: 'kanban'),
    ],
    messages: [
      Message(sender: 'Đức Anh',    text: 'Schema database đã xong, mọi người review PR #42 nhé!'),
      Message(sender: 'Hải Nam',    text: 'WebSocket đang có issue với reconnect, cần thêm thời gian'),
      Message(sender: 'Minh Hoàng', text: 'Ok, ưu tiên hoàn thành API Tasks trước nhé. Sprint review thứ 6 này', isMine: true),
      Message(sender: 'Phương Mai', text: 'Mình đã setup xong staging server, deploy lên test được rồi'),
    ],
    activities: [
      GroupActivity(actor: 'Đức Anh',    action: 'merge PR',       detail: 'Database Schema v2',          time: '30 phút', colorIndex: 1),
      GroupActivity(actor: 'Hải Nam',    action: 'tạo branch',     detail: 'feature/websocket',           time: '2 giờ',   colorIndex: 2),
      GroupActivity(actor: 'Phương Mai', action: 'deploy',         detail: 'Staging server v1.0.2',       time: '5 giờ',   colorIndex: 3),
      GroupActivity(actor: 'Minh Hoàng', action: 'review code',    detail: 'PR #38 — User API',           time: '1 ngày',  colorIndex: 0),
    ],
    channels: ['chung', 'backend', 'devops'],
  ),

  // Nhóm 3 — Team UI/UX Design
  Group(
    id: 'g3',
    name: 'Team UI/UX Design',
    description: 'Nhóm thiết kế giao diện và trải nghiệm người dùng',
    isActive: true,
    members: [
      TeamMember(name: 'Thu Linh',   initials: 'TL', role: 'Admin',     taskCount: 7, avatarColorIndex: 2),
      TeamMember(name: 'An Nhiên',   initials: 'AN', role: 'Thành viên', taskCount: 5, avatarColorIndex: 1),
      TeamMember(name: 'Quỳnh Anh',  initials: 'QA', role: 'Thành viên', taskCount: 3, avatarColorIndex: 0),
    ],
    tasks: [
      Task(id: 'u1', title: 'Wireframe màn hình Dashboard',   status: 'done',  assignee: 'TL', deadline: '15/04'),
      Task(id: 'u2', title: 'Design System — Color & Typography', status: 'done', assignee: 'AN', deadline: '18/04'),
      Task(id: 'u3', title: 'Prototype màn hình Kanban',      status: 'doing', assignee: 'TL', deadline: 'Hôm nay'),
      Task(id: 'u4', title: 'Icon set cho mobile app',         status: 'doing', assignee: 'QA', deadline: '06/05'),
      Task(id: 'u5', title: 'User testing round 1',           status: 'todo',  assignee: 'AN', deadline: '14/05'),
    ],
    kanbanTasks: [
      Task(id: 'uk1', title: 'Illustration cho onboarding',  status: 'todo',  assignee: 'QA', type: 'kanban'),
      Task(id: 'uk2', title: 'Responsive layout guide',       status: 'todo',  assignee: 'AN', type: 'kanban'),
      Task(id: 'uk3', title: 'Prototype Kanban flow',         status: 'doing', assignee: 'TL', type: 'kanban'),
      Task(id: 'uk4', title: 'Icon set — Line style',         status: 'doing', assignee: 'QA', type: 'kanban'),
      Task(id: 'uk5', title: 'Dashboard wireframe v2',        status: 'done',  assignee: 'TL', type: 'kanban'),
      Task(id: 'uk6', title: 'Design tokens document',        status: 'done',  assignee: 'AN', type: 'kanban'),
    ],
    messages: [
      Message(sender: 'Thu Linh',   text: 'Mình vừa update prototype Kanban trên Figma, mọi người xem feedback nhé!'),
      Message(sender: 'An Nhiên',   text: 'Design system đã finalize, export token cho dev rồi'),
      Message(sender: 'Quỳnh Anh',  text: 'Icon set đang làm, dự kiến xong cuối tuần này ạ'),
    ],
    activities: [
      GroupActivity(actor: 'Thu Linh',  action: 'update file',    detail: 'Kanban prototype v3',         time: '15 phút', colorIndex: 2),
      GroupActivity(actor: 'An Nhiên',  action: 'export token',   detail: 'Design System tokens',        time: '3 giờ',   colorIndex: 1),
      GroupActivity(actor: 'Quỳnh Anh', action: 'upload assets',  detail: 'Icon set — 24 icons',         time: '1 ngày',  colorIndex: 0),
      GroupActivity(actor: 'Nhóm',      action: 'họp review',     detail: 'Sprint Design Review #2',     time: '2 ngày',  colorIndex: 3),
    ],
    channels: ['chung', 'design', 'feedback'],
  ),
];
