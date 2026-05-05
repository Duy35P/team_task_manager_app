import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'kanban_screen.dart';
import 'groups_screen.dart';
import 'timeline_screen.dart';
import 'chat_screen.dart';
import 'account_screen.dart';
import 'responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _navMain = [
    _NavItem(icon: Icons.grid_view_rounded,      label: 'Dashboard'),
    _NavItem(icon: Icons.format_list_bulleted,   label: 'Công việc'),
    _NavItem(icon: Icons.view_kanban_outlined,   label: 'Kanban'),
    _NavItem(icon: Icons.group_outlined,         label: 'Nhóm'),
    _NavItem(icon: Icons.calendar_today_outlined, label: 'Timeline'),
    _NavItem(icon: Icons.chat_bubble_outline,    label: 'Chat nhóm'),
  ];

  static const _navSettings = [
    _NavItem(icon: Icons.person_outline, label: 'Tài khoản'),
  ];

  Widget _currentPage() => switch (_index) {
    0 => const DashboardScreen(),
    1 => const TasksScreen(),
    2 => const KanbanScreen(),
    3 => const GroupsScreen(),
    4 => const TimelineScreen(),
    5 => const ChatScreen(),
    6 => const AccountScreen(),
    _ => const DashboardScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final navItems = [..._navMain, ..._navSettings];

    return Scaffold(
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
            _Sidebar(
              index: _index,
              mainItems: _navMain,
              settingsItems: _navSettings,
              onSelect: (i) => setState(() => _index = i),
            ),
          Expanded(child: _currentPage()),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int index;
  final List<_NavItem> mainItems;
  final List<_NavItem> settingsItems;
  final void Function(int) onSelect;

  const _Sidebar({
    required this.index,
    required this.mainItems,
    required this.settingsItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.format_list_bulleted, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('TeamTask',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
          ),
          Container(height: 0.5, color: Colors.white.withOpacity(0.07)),

          // Main nav
          _sectionLabel('Menu chính'),
          ...mainItems.asMap().entries.map((e) => _NavTile(
            item: e.value,
            active: index == e.key,
            onTap: () => onSelect(e.key),
          )),

          // Settings nav
          _sectionLabel('Cài đặt'),
          ...settingsItems.asMap().entries.map((e) => _NavTile(
            item: e.value,
            active: index == mainItems.length + e.key,
            onTap: () => onSelect(mainItems.length + e.key),
          )),

          const Spacer(),
          Container(height: 0.5, color: Colors.white.withOpacity(0.07)),
          // User row
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              const AppAvatar(initials: 'MH', colorIndex: 0, size: 32),
              const SizedBox(width: 9),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Minh Hoàng',
                    style: TextStyle(color: Color(0xFFD8D8E8), fontSize: 12, fontWeight: FontWeight.w500)),
                Text('Admin', style: TextStyle(color: kSidebarText.withOpacity(0.45), fontSize: 11)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Text(text.toUpperCase(),
        style: TextStyle(
            fontSize: 10, letterSpacing: 0.08, color: kSidebarText.withOpacity(0.4))),
  );
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kAccent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(item.icon,
              size: 16,
              color: active ? const Color(0xFFA8A3F0) : kSidebarText.withOpacity(0.7)),
          const SizedBox(width: 9),
          Text(item.label,
              style: TextStyle(
                  fontSize: 13,
                  color: active ? const Color(0xFFA8A3F0) : kSidebarText)),
        ]),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Top bar (reused by each screen) ──────────────────────────────────────────

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppTopBar({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final compact = isCompactBar(context);

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kTextMain)),
        const Spacer(),
        if (!compact)
          Container(
            width: 160, height: 30,
            decoration: BoxDecoration(
              color: kAppBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Row(children: [
              Icon(Icons.search, size: 14, color: kTextMuted),
              SizedBox(width: 6),
              Text('Tìm kiếm...', style: TextStyle(fontSize: 12, color: kTextMuted)),
            ]),
          ),
        if (actionLabel != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAction,
            child: Container(
              height: 30, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(actionLabel!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}