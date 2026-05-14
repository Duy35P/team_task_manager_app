import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class GroupSelector extends StatelessWidget {
  final List<Group> groups;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  final bool showAllOption;
  final bool allSelected;
  final VoidCallback? onSelectAll;

  const GroupSelector({
    super.key,
    required this.groups,
    required this.selectedIndex,
    required this.onChanged,
    this.showAllOption = false,
    this.allSelected = false,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (showAllOption)
            GestureDetector(
              onTap: onSelectAll,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: allSelected ? kAccentLight : kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: allSelected ? kAccent : kBorder,
                    width: allSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.groups_outlined, size: 16, color: allSelected ? kAccent : kTextMuted),
                  const SizedBox(width: 6),
                  Text('Tất cả nhóm',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: allSelected ? FontWeight.w600 : FontWeight.normal,
                        color: allSelected ? kAccent : kTextMuted,
                      )),
                ]),
              ),
            ),
          ...groups.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            final active = !allSelected && i == selectedIndex;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kAccentLight : kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? kAccent : kBorder,
                    width: active ? 1.5 : 0.5,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? kAccent : kTextMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(g.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        color: active ? kAccent : kTextMuted,
                      )),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

InputDecoration appInputDecoration({
  String? hintText,
  String? labelText,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
    hintText: hintText,
    hintStyle: const TextStyle(color: kTextMuted),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    isDense: true,
    filled: true,
    fillColor: kAppBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kAccent),
    ),
  );
}

Widget appDialogLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(text, style: const TextStyle(fontSize: 12, color: kTextMuted)),
);

void showAppSnackBar(BuildContext context, String message,
    {Color backgroundColor = kTeal}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 13)),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 3),
  ));
}

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = 'OK',
    this.cancelText = 'Huỷ',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
      content: Text(content, style: const TextStyle(fontSize: 13, color: kTextMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText, style: const TextStyle(color: kTextMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kCoral, foregroundColor: Colors.white,
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}