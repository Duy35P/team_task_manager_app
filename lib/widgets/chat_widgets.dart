import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

class ChatBubble extends StatelessWidget {
  final Message msg;
  const ChatBubble({super.key, required this.msg});

  static const _senderInfo = {
    'An Nhiên':   (initials: 'AN', colorIdx: 1),
    'Thu Linh':   (initials: 'TL', colorIdx: 2),
    'Minh Hoàng': (initials: 'MH', colorIdx: 0),
  };

  @override
  Widget build(BuildContext context) {
    final info = _senderInfo[msg.sender] ?? (initials: 'MH', colorIdx: 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMine) ...[
            AppAvatar(initials: info.initials, colorIndex: info.colorIdx, size: 30),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!msg.isMine)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 3),
                  child: Text(msg.sender, style: const TextStyle(fontSize: 11, color: kTextMuted)),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: msg.isMine ? kAppBg : kCardBg,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomRight: msg.isMine  ? const Radius.circular(2) : null,
                      bottomLeft:  !msg.isMine ? const Radius.circular(2) : null,
                    ),
                    border: Border.all(color: kBorder, width: 0.5),
                  ),
                  child: Text(msg.text,
                      style: const TextStyle(fontSize: 13, color: kTextMain, height: 1.45)),
                ),
              ),
            ],
          ),
          if (msg.isMine) ...[
            const SizedBox(width: 8),
            AppAvatar(initials: info.initials, colorIndex: info.colorIdx, size: 30),
          ],
        ],
      ),
    );
  }
}
