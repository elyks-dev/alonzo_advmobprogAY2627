import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

// Enhancement 3: Chat Detail Screen - Redesign

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  final String receiverId;
  final String receiverName;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController =
      TextEditingController();

  bool _isSending = false;
  String? _sendingMessage;
  Timestamp? _sendingStartedAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsSeen();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsSeen() async {
    try {
      await _chatService.markMessagesAsSeen(widget.receiverId);
    } catch (_) {
      // Do not interrupt the chat if marking messages as seen fails.
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _sendingMessage = message;
      _sendingStartedAt = Timestamp.now();
    });

    try {
      await _chatService.sendMessage(
        widget.receiverId,
        message,
      );

      _messageController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingMessage = null;
          _sendingStartedAt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No signed-in user.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(
                currentUserId,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load messages.',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs
                    .reversed
                    .where((document) {
                  if (_sendingStartedAt == null) {
                    return true;
                  }

                  final data = document.data();

                  final senderId =
                      (data['senderId'] ?? '').toString();

                  final timestamp = data['timestamp'];

                  return senderId != currentUserId ||
                      timestamp is! Timestamp ||
                      timestamp.compareTo(
                            _sendingStartedAt!,
                          ) <
                          0;
                }).toList();

                if (messages.isEmpty &&
                    _sendingMessage == null) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  itemCount: messages.length +
                      (_sendingMessage == null ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _MessageBubble(
                        message: _sendingMessage!,
                        isMine: true,
                        timestamp: _sendingStartedAt,
                        status: 'Sending…',
                        isSending: true,
                      );
                    }

                    final data =
                        messages[index].data();

                    final senderId =
                        (data['senderId'] ?? '')
                            .toString();

                    final isMine =
                        senderId == currentUserId;

                    final wasSeen =
                        isMine && data['seen'] == true;

                    return _AnimatedMessageBubble(
                      isMine: isMine,
                      child: _MessageBubble(
                        message:
                            (data['message'] ?? '')
                                .toString(),
                        isMine: isMine,
                        timestamp:
                            data['timestamp'] is Timestamp
                                ? data['timestamp']
                                    as Timestamp
                                : null,
                        status: isMine
                            ? (wasSeen
                                ? 'Seen'
                                : 'Delivered')
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) =>
                          _sendMessage(),
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    onPressed:
                        _isSending ? null : _sendMessage,
                    tooltip: 'Send message',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhancement 3: Chat Detail Screen - Redesign

class _AnimatedMessageBubble extends StatelessWidget {
  const _AnimatedMessageBubble({
    required this.child,
    required this.isMine,
  });

  final Widget child;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(
        milliseconds: 260,
      ),
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              (isMine ? 24 : -24) *
                  (1 - value),
              0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// Enhancement 3: Chat Detail Screen - Redesign

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.status,
    this.isSending = false,
    this.timestamp,
  });

  final String message;
  final bool isMine;
  final String? status;
  final bool isSending;
  final Timestamp? timestamp;

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();

    final hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    final bubbleColor = isMine
        ? scheme.primary
        : scheme.surfaceContainerHighest;

    final textColor = isMine
        ? scheme.onPrimary
        : scheme.onSurface;

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(context).width *
                  .76,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          8,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft:
                const Radius.circular(18),
            topRight:
                const Radius.circular(18),
            bottomLeft: Radius.circular(
              isMine ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isMine ? 4 : 18,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timestamp != null)
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: textColor.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 10,
                    ),
                  ),
                if (status != null) ...[
                  const SizedBox(width: 7),
                  if (isSending)
                    SizedBox(
                      height: 11,
                      width: 11,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: textColor,
                      ),
                    )
                  else
                    Icon(
                      status == 'Seen'
                          ? Icons.done_all
                          : Icons.done,
                      size: 15,
                      color: status == 'Seen'
                          ? scheme.tertiary
                          : textColor,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    status!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}