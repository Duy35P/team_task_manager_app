import 'package:flutter/material.dart';
import '../theme.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem({required this.icon, required this.label});
}

class Sidebar extends StatelessWidget {
  final int index;
  final List<NavItem> mainItems;
  final List<NavItem> settingsItems;
  final void Function(int) onSelect;

  const Sidebar({
    super.key,
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
          ...mainItems.asMap().entries.map((e) => NavTile(
            item: e.value,
            active: index == e.key,
            onTap: () => onSelect(e.key),
          )),

          // Settings nav
          _sectionLabel('Cài đặt'),
          ...settingsItems.asMap().entries.map((e) => NavTile(
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

class NavTile extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;
  const NavTile({super.key, required this.item, required this.active, required this.onTap});

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
