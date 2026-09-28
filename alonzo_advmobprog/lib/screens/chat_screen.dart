import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Column(
        children: [
          // Enhancement 2: Chat List - Search Functionality
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      ),
              ),
            ),
          ),
          // Enhancement 1: Chat List - User Display
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load users.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final searchText = _searchText.trim().toLowerCase();
                final users = snapshot.data!.where((user) {
                  final uid = (user['uid'] ?? '').toString();
                  final name = (user['firstName'] ?? '').toString();
                  final email = (user['email'] ?? '').toString();
                  return uid.isNotEmpty &&
                      uid != currentUserId &&
                      (searchText.isEmpty ||
                          name.toLowerCase().contains(searchText) ||
                          email.toLowerCase().contains(searchText));
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final name = (user['firstName'] ?? 'Unknown').toString();
                    final email = (user['email'] ?? 'No email').toString();
                    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

                    return ListTile(
                      leading: CircleAvatar(child: Text(initial)),
                      title: Text(name),
                      subtitle: Text(email),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            receiverId: user['uid'].toString(),
                            receiverName: name,
                          ),
                        ),
                      ),
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
