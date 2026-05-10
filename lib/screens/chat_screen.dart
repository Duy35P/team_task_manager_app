import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models.dart';
import '../services/firestore_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/chat_widgets.dart';
import '../responsive.dart';

class ChatScreen extends StatefulWidget {
  final List<Group> groups;
  final Group selectedGroup;
  final int selectedGroupIndex;
  final ValueChanged<int> onGroupChanged;

  const ChatScreen({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.selectedGroupIndex,
    required this.onGroupChanged,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestoreService = FirestoreService();
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final _focusNode = FocusNode();
  int _channelIndex = 0;
  int _lastMessageCount = 0; // Track message count for smart auto-scroll

  List<String> get _channels => widget.selectedGroup.channels;
  String get _currentChannel => _channels[_channelIndex.clamp(0, _channels.length - 1)];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final msg = Message(
      sender: user?.displayName ?? 'User',
      text: text,
      userId: user?.uid ?? '',
      channel: _currentChannel,
    );

    _firestoreService.sendMessage(widget.selectedGroup.id, msg);
    _ctrl.clear();
  }

  // ── Tạo kênh mới ──────────────────────────────────────────────────────────
  void _createChannel() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tạo kênh mới',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextMain)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Tên kênh sẽ được chuyển thành chữ thường, không dấu.',
              style: TextStyle(fontSize: 12, color: kTextMuted)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 13, color: kTextMain),
            onSubmitted: (_) => _submitNewChannel(ctx, ctrl),
            decoration: InputDecoration(
              prefixText: '# ',
              prefixStyle: const TextStyle(fontSize: 13, color: kAccent, fontWeight: FontWeight.w500),
              hintText: 'tên-kênh',
              hintStyle: const TextStyle(color: kTextMuted),
              isDense: true,
              filled: true,
              fillColor: kAppBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorder, width: 0.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kBorder, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: kAccent)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _submitNewChannel(ctx, ctrl),
            child: const Text('Tạo kênh'),
          ),
        ],
      ),
    );
  }

  void _submitNewChannel(BuildContext ctx, TextEditingController ctrl) {
    final name = ctrl.text.trim().toLowerCase().replaceAll(' ', '-');
    if (name.isEmpty) return;
    if (_channels.contains(name)) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kênh "#$name" đã tồn tại.'),
        backgroundColor: kCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }

    // Update channels on Firestore
    final newChannels = [..._channels, name];
    _firestoreService.updateGroup(widget.selectedGroup.id, {'channels': newChannels});

    setState(() {
      _channelIndex = newChannels.length - 1;
    });
    Navigator.pop(ctx);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã tạo kênh "#$name" thành công!'),
      backgroundColor: kTeal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ── Bottom sheet chọn kênh (mobile) ───────────────────────────────────────
  void _openChannels() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36, height: 4,
                decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(children: [
                  Text('Kênh — ${widget.selectedGroup.name}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextMain)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { Navigator.pop(ctx); _createChannel(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8)),
                      child: const Text('+ Kênh mới',
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ]),
              ),
              const Divider(height: 0, color: kBorder, thickness: 0.5),
              ...(_channels.asMap().entries.map((e) {
                final active = _channelIndex == e.key;
                return ListTile(
                  leading: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? kAccent : const Color(0xFFD3D1C7),
                    ),
                  ),
                  title: Text('# ${e.value}',
                      style: TextStyle(
                          fontSize: 13,
                          color: active ? kAccent : kTextMain,
                          fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
                  trailing: active ? const Icon(Icons.check, color: kAccent, size: 18) : null,
                  onTap: () {
                    setState(() => _channelIndex = e.key);
                    Navigator.pop(ctx);
                  },
                );
              })).toList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _channelList() => AppCard(
    padding: EdgeInsets.zero,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Row(children: [
          const Text('Kênh nhóm',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
          const Spacer(),
          GestureDetector(
            onTap: _createChannel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(6)),
              child: const Text('+ Kênh mới',
                  style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ]),
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
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]),
  );

  @override
  void dispose() {
    _focusNode.dispose();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _messagePane() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Channel header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            Text('# $_currentChannel',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextMain)),
            const SizedBox(width: 8),
            AppBadge(
              label: widget.selectedGroup.name,
              bg: kAccentLight,
              fg: kAccent,
            ),
            const Spacer(),
            StreamBuilder<List<TeamMember>>(
              stream: _firestoreService.watchMembers(widget.selectedGroup.id),
              builder: (context, snap) {
                final members = snap.data ?? [];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAppBg, borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kBorder, width: 0.5),
                  ),
                  child: Row(children: [
                    ...members.take(3).map((m) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: AppAvatar(initials: m.initials, colorIndex: m.avatarColorIndex, size: 16),
                    )),
                    Text('${members.length}',
                        style: const TextStyle(fontSize: 11, color: kTextMuted)),
                  ]),
                );
              },
            ),
          ]),
        ),
        const Divider(height: 0, color: kBorder, thickness: 0.5),
        // Message list — real-time from Firestore (isolated in its own StreamBuilder)
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: _firestoreService.watchMessages(widget.selectedGroup.id, _currentChannel),
            builder: (context, snapshot) {
              final msgs = snapshot.data ?? [];

              // Only auto-scroll when new messages actually arrive
              if (msgs.length != _lastMessageCount) {
                _lastMessageCount = msgs.length;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.animateTo(
                      _scroll.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }

              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final msg = msgs[i];
                  // Set isMine based on userId match
                  final displayMsg = Message(
                    id: msg.id,
                    sender: msg.sender,
                    text: msg.text,
                    isMine: msg.userId == currentUserId,
                    userId: msg.userId,
                    channel: msg.channel,
                    createdAt: msg.createdAt,
                  );
                  return ChatBubble(msg: displayMsg);
                },
              );
            },
          ),
        ),
        // Input row — OUTSIDE StreamBuilder to prevent keyboard dismissal on rebuild
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
                  focusNode: _focusNode,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(fontSize: 13, color: kTextMain),
                  decoration: InputDecoration(
                    hintText: 'Nhắn tin cho # $_currentChannel...',
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
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    // Reset channel index if it exceeds available channels
    // Use addPostFrameCallback to avoid mutating state during build
    if (_channelIndex >= _channels.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _channelIndex = 0);
      });
      // Use safe value for this frame
      _channelIndex = 0;
    }

    return Scaffold(
      backgroundColor: kAppBg,
      resizeToAvoidBottomInset: true,
      appBar: AppTopBar(
        title: 'Chat nhóm',
        actionLabel: mobile ? 'Kênh' : '+ Kênh mới',
        onAction: mobile ? _openChannels : _createChannel,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Group selector ──────────────────────────────────────────
              _buildGroupSelector(),
              const SizedBox(height: 12),

              // ── Chat content ────────────────────────────────────────────
              Expanded(
                child: mobile
                    ? _messagePane()
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 260, child: _channelList()),
                  const SizedBox(width: 16),
                  Expanded(child: _messagePane()),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          final active = i == widget.selectedGroupIndex;
          return GestureDetector(
            onTap: () {
              widget.onGroupChanged(i);
              setState(() => _channelIndex = 0);
            },
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
                  width: 8, height: 8,
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
                        color: active ? kAccent : kTextMuted)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}