import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/seed_service.dart';
import '../widgets/sidebar.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'kanban_screen.dart';
import 'groups_screen.dart';
import 'timeline_screen.dart';
import 'chat_screen.dart';
import 'account_screen.dart';
import '../responsive.dart';

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
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedData();
  }

  Future<void> _seedData() async {
    await SeedService.seedIfEmpty(widget.userId);
    if (mounted) setState(() => _seeded = true);
  }

  static const _navMain = [
    NavItem(icon: Icons.grid_view_rounded,      label: 'Dashboard'),
    NavItem(icon: Icons.format_list_bulleted,   label: 'Công việc'),
    NavItem(icon: Icons.view_kanban_outlined,   label: 'Kanban'),
    NavItem(icon: Icons.group_outlined,         label: 'Nhóm'),
    NavItem(icon: Icons.calendar_today_outlined, label: 'Timeline'),
    NavItem(icon: Icons.chat_bubble_outline,    label: 'Chat nhóm'),
  ];

  static const _navSettings = [
    NavItem(icon: Icons.person_outline, label: 'Tài khoản'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return const Scaffold(
        backgroundColor: kAppBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kAccent),
              SizedBox(height: 16),
              Text('Đang đồng bộ dữ liệu...',
                  style: TextStyle(fontSize: 14, color: kTextMuted)),
            ],
          ),
        ),
      );
    }

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

        if (groups.isEmpty) {
          return Scaffold(
            backgroundColor: kAppBg,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_outlined, size: 48, color: kTextMuted),
                  const SizedBox(height: 12),
                  const Text('Chưa có nhóm nào',
                      style: TextStyle(fontSize: 16, color: kTextMain)),
                  const SizedBox(height: 8),
                  const Text('Đang tải dữ liệu...',
                      style: TextStyle(fontSize: 13, color: kTextMuted)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _seeded = false),
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // Clamp index
        final safeIndex = _selectedGroupIndex.clamp(0, groups.length - 1);
        if (safeIndex != _selectedGroupIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedGroupIndex = safeIndex);
          });
        }

        final selectedGroup = groups[safeIndex];

        return _buildMainScaffold(groups, selectedGroup, safeIndex);
      },
    );
  }

  Widget _buildMainScaffold(List<Group> groups, Group selectedGroup, int selectedIndex) {
    final mobile = isMobile(context);
    final navItems = [..._navMain, ..._navSettings];

    Widget currentPage() => switch (_index) {
      0 => DashboardScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      1 => TasksScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      2 => KanbanScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      3 => GroupsScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      4 => TimelineScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      5 => ChatScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
      6 => const AccountScreen(),
      _ => DashboardScreen(
        groups: groups,
        selectedGroup: selectedGroup,
        selectedGroupIndex: selectedIndex,
        onGroupChanged: (i) => setState(() => _selectedGroupIndex = i),
      ),
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: mobile
          ? BottomNavigationBar(
        currentIndex: _index.clamp(0, navItems.length - 1),
        onTap: (i) => setState(() => _index = i),
        items: navItems
            .map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label))
            .toList(),
        type: BottomNavigationBarType.fixed,
      )
          : null,
      body: Row(
        children: [
          if (!mobile)
            Sidebar(
              index: _index,
              mainItems: _navMain,
              settingsItems: _navSettings,
              onSelect: (i) => setState(() => _index = i),
            ),
          Expanded(child: currentPage()),
        ],
      ),
    );
  }
}