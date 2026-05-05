// ── Models ────────────────────────────────────────────────────────────────────

class Task {
  final String id;
  String title;
  String status;   // todo | doing | done
  String priority; // Cao | Trung bình | Thấp
  String assignee;
  String deadline;
  String tag;

  Task({
    required this.id,
    required this.title,
    this.status = 'todo',
    this.priority = 'Trung bình',
    this.assignee = '',
    this.deadline = '',
    this.tag = '',
  });
}

class Message {
  final String sender;
  final String text;
  final bool isMine;
  Message({required this.sender, required this.text, this.isMine = false});
}

class TeamMember {
  final String name;
  final String initials;
  final String role;
  final int taskCount;
  final int avatarColorIndex; // 0=purple 1=teal 2=coral
  TeamMember({
    required this.name,
    required this.initials,
    required this.role,
    required this.taskCount,
    required this.avatarColorIndex,
  });
}

class GroupActivity {
  final String actor;
  final String action;
  final String detail;
  final String time;
  final int colorIndex;
  GroupActivity({
    required this.actor,
    required this.action,
    required this.detail,
    required this.time,
    required this.colorIndex,
  });
}

// ── Mock data ─────────────────────────────────────────────────────────────────

final List<Task> mockTasks = [
  Task(id: '1', title: 'Thiết kế màn hình Login',     status: 'done',  priority: 'Cao',       assignee: 'MH', deadline: '20/04', tag: 'UI'),
  Task(id: '2', title: 'Viết API xác thực người dùng', status: 'doing', priority: 'Cao',       assignee: 'AN', deadline: 'Hôm nay', tag: 'Backend'),
  Task(id: '3', title: 'Kết nối Firestore với Tasks',  status: 'todo',  priority: 'Trung bình', assignee: 'MH', deadline: '28/04', tag: 'Firebase'),
  Task(id: '4', title: 'Xây dựng Kanban Board UI',     status: 'doing', priority: 'Trung bình', assignee: 'TL', deadline: '02/05', tag: 'UI'),
  Task(id: '5', title: 'Tích hợp Firebase Messaging',  status: 'todo',  priority: 'Thấp',      assignee: 'AN', deadline: '10/05', tag: 'Firebase'),
];

final List<Task> mockKanbanTasks = [
  Task(id: 'k1', title: 'Tích hợp push notification',  status: 'todo',  assignee: 'AN', tag: 'Firebase'),
  Task(id: 'k2', title: 'Màn hình setting tài khoản',  status: 'todo',  assignee: 'TL', tag: 'UI'),
  Task(id: 'k3', title: 'Viết unit test auth module',  status: 'todo',  assignee: 'MH', tag: 'Test'),
  Task(id: 'k4', title: 'Viết API xác thực user',      status: 'doing', assignee: 'AN', tag: 'Backend'),
  Task(id: 'k5', title: 'Xây dựng Kanban Board UI',    status: 'doing', assignee: 'TL', tag: 'UI'),
  Task(id: 'k6', title: 'Kết nối Firestore realtime',  status: 'doing', assignee: 'MH', tag: 'Firebase'),
  Task(id: 'k7', title: 'Setup project Flutter ban đầu', status: 'done', assignee: 'MH', tag: 'Setup'),
  Task(id: 'k8', title: 'Thiết kế màn hình Login',     status: 'done',  assignee: 'TL', tag: 'UI'),
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
