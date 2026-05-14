import 'package:flutter/material.dart';
import '../theme.dart';

class FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const FilterTab({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? kAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? null : Border.all(color: kBorder, width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : kTextMain)),
    ),
  );
}

class TaskHeaderCell extends StatelessWidget {
  final String text;
  const TaskHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMuted));
}