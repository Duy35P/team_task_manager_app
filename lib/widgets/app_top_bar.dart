import 'package:flutter/material.dart';
import '../theme.dart';

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
        if (actionLabel != null)
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
      ]),
    );
  }
}
