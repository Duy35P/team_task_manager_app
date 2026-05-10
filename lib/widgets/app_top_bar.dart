import 'package:flutter/material.dart';
import '../theme.dart';
import '../responsive.dart';

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
