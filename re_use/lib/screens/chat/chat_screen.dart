import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_use/services/chat_service.dart';
import 'package:re_use/types/chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversation});
  final ChatConversation conversation;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _muted = Color(0xFF6D7D74);
  static const Color _pageBackground = Color(0xFFF3FAF7);
  static const Color _border = Color(0xFFD7E6DE);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _send() async {
    final String text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _inputController.clear();
    try {
      await ChatService().sendMessage(
        conversation: widget.conversation,
        senderId: _uid,
        text: text,
      );
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuyer = widget.conversation.buyerId == _uid;
    final String otherName = isBuyer
        ? widget.conversation.sellerName
        : widget.conversation.buyerName;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _teal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.conversation.itemTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              otherName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            if (widget.conversation.price > 0) ...<Widget>[
              const SizedBox(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '€ ${widget.conversation.price % 1 == 0 ? widget.conversation.price.toInt() : widget.conversation.price.toStringAsFixed(2)} / ${widget.conversation.typePayment}',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService().watchMessages(widget.conversation.id),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ChatMessage>> snap,
              ) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<ChatMessage> messages =
                    snap.data ?? <ChatMessage>[];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Stuur een bericht om het gesprek te starten.',
                      style: TextStyle(color: _muted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int i) {
                    final ChatMessage msg = messages[i];
                    final bool isMe = msg.senderId == _uid;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _inputController,
            sending: _sending,
            onSend: _send,
            teal: _teal,
            border: _border,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  static const Color _teal = Color(0xFF6F9476);
  static const Color _dark = Color(0xFF2F3E36);
  static const Color _bubbleOther = Color(0xFFE8F0EC);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? _teal : _bubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : _dark,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.teal,
    required this.border,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final Color teal;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FCFA),
          border: Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Typ een bericht...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AADA4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3FAF7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: teal),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: sending ? const Color(0xFFB5CAB9) : teal,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
