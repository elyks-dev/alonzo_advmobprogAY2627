import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDummyJsonUser =
        context.watch<AuthProvider>().isDummyJsonUser;

    // DummyJSON users cannot use Firebase Chat.
    if (isDummyJsonUser) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Sign up to start messaging',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Create a Firebase account to use the chat feature and start messaging other users.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Firebase users get the normal chat interface.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchText = '';
                          });
                        },
                      ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load users.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Use the actual Firebase UID so the current
                // Firebase user is excluded from the chat list.
                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid;

                final searchText =
                    _searchText.trim().toLowerCase();

                final users = snapshot.data!.where((user) {
                  final uid =
                      (user['uid'] ?? '').toString();

                  final name =
                      (user['firstName'] ?? '').toString();

                  final email =
                      (user['email'] ?? '').toString();

                  return uid.isNotEmpty &&
                      uid != currentUserId &&
                      (searchText.isEmpty ||
                          name
                              .toLowerCase()
                              .contains(searchText) ||
                          email
                              .toLowerCase()
                              .contains(searchText));
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found.'),
                  );
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final name =
                        (user['firstName'] ?? 'Unknown')
                            .toString();

                    final email =
                        (user['email'] ?? 'No email')
                            .toString();

                    final initial = name.isEmpty
                        ? '?'
                        : name[0].toUpperCase();

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(initial),
                      ),
                      title: Text(name),
                      subtitle: Text(email),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              receiverId:
                                  user['uid'].toString(),
                              receiverName: name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}