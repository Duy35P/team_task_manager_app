import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'home_screen.dart';
import 'responsive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  late final List<Message> _msgs;
  int _channelIndex = 0;

  static const _channels = ['chung', 'dev', 'design'];

  @override
  void initState() {
    super.initState();
    _msgs = List.from(mockMessages);
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _msgs.add(Message(sender: 'Minh Hoàng', text: text, isMine: true)));
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 80),
            () => _scroll.jumpTo(_scroll.position.maxScrollExtent));
  }

  void _openChannels() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: _channels.asMap().entries.map((e) {
            final active = _channelIndex == e.key;
            return ListTile(
              title: Text('# ${e.value}'),
              trailing: active ? const Icon(Icons.check, color: kAccent) : null,
              onTap: () {
                setState(() => _channelIndex = e.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _channelList() => AppCard(
    padding: EdgeInsets.zero,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Text('Kênh nhóm',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
      ),
      const Divider(height: 0, color: kBorder, thickness: 0.5),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: _channels.asMap().entries.map((e) {
            final active = _channelIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _channelIndex = e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? kAccentLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? kAccent : const Color(0xFFD3D1C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('# ${e.value}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w500 : FontWeight.normal,
                          color: active ? kAccent : kTextMuted)),
                  if (active) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                          color: kAccent, borderRadius: BorderRadius.circular(10)),
                      child: const Text('3',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]),
  );

  Widget _messagePane() => AppCard(
    padding: EdgeInsets.zero,
    child: Column(children: [
      // Channel header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(children: [
          Text('# ${_channels[_channelIndex]}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
        ]),
      ),
      const Divider(height: 0, color: kBorder, thickness: 0.5),
      // Message list
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: _msgs.length,
          itemBuilder: (_, i) => _Bubble(msg: _msgs[i]),
        ),
      ),
      // Input row
      Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorder, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: kAppBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder, width: 0.5),
              ),
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Nhắn tin cho # ${_channels[_channelIndex]}...',
                  hintStyle: const TextStyle(fontSize: 13, color: kTextMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppTopBar(
        title: 'Chat nhóm',
        actionLabel: mobile ? 'Kênh' : '+ Kênh mới',
        onAction: mobile ? _openChannels : () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: mobile
            ? _messagePane()
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 260, child: _channelList()),
          const SizedBox(width: 16),
          Expanded(child: _messagePane()),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message msg;
  const _Bubble({required this.msg});

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
                  child: Text(msg.sender,
                      style: const TextStyle(fontSize: 11, color: kTextMuted)),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70),
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