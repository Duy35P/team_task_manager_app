import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/sidebar.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'kanban_screen.dart';
import 'groups_screen.dart';
import 'timeline_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // ── Auth Gate: lắng nghe trạng thái đăng nhập ──────────────────────────
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Đang kiểm tra trạng thái auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kAppBg,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kAccent),
                  SizedBox(height: 16),
                  Text('Đang tải...',
                      style: TextStyle(fontSize: 14, color: kTextMuted)),
                ],
              ),
            ),
          );
        }

        // Chưa đăng nhập → hiện trang Login
        if (snapshot.data == null) {
          return const AccountScreen();
        }

        // Đã đăng nhập → hiện app chính
        return _MainApp(userId: snapshot.data!.uid);
      },
    );
  }
}

// ── App chính (sau khi đã đăng nhập) ──────────────────────────────────────────
class _MainApp extends StatefulWidget {
  final String userId;
  const _MainApp({required this.userId});
  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  final _firestoreService = FirestoreService();
  int _index = 0;
  int _selectedGroupIndex = 0;

  static const _navItems = [
    NavItem(icon: Icons.grid_view_rounded,      label: 'Dashboard'),
    NavItem(icon: Icons.format_list_bulleted,   label: 'Công việc'),
    NavItem(icon: Icons.view_kanban_outlined,   label: 'Kanban'),
    NavItem(icon: Icons.group_outlined,         label: 'Nhóm'),
    NavItem(icon: Icons.calendar_today_outlined, label: 'Timeline'),
    NavItem(icon: Icons.person_outline,         label: 'Tài khoản'),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Group>>(
      stream: _firestoreService.watchGroups(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kAppBg,
            body: Center(child: CircularProgressIndicator(color: kAccent)),
          );
        }

        final groups = snapshot.data ?? [];

        // Clamp index
        final safeIndex = groups.isEmpty ? 0 : _selectedGroupIndex.clamp(0, groups.length - 1);
        if (safeIndex != _selectedGroupIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedGroupIndex = safeIndex);
          });
        }

        final selectedGroup = groups.isEmpty ? null : groups[safeIndex];

        // Nếu chưa có group, tạo group rỗng để các màn hình không lỗi
        final group = selectedGroup ?? Group(
          id: '', name: '', members: [], tasks: [], kanbanTasks: [], activities: [],
        );

        Widget currentPage() => switch (_index) {
          0 => DashboardScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
          1 => TasksScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
          2 => KanbanScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
          3 => GroupsScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
          4 => TimelineScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
          5 => const AccountScreen(),
          _ => DashboardScreen(
            groups: groups,
            selectedGroup: group,
            selectedGroupIndex: safeIndex,
            onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
          ),
        };

        return Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index.clamp(0, _navItems.length - 1),
            onTap: (i) => setState(() => _index = i),
            items: _navItems
                .map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label))
                .toList(),
            type: BottomNavigationBarType.fixed,
          ),
          body: currentPage(),
        );
      },
    );
  }
}