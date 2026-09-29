import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

// Enhancement 1: Chat List - User Display

class ChatService {
  ChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore
        .collection('Users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((document) => document.data()).toList(),
        );
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw StateError('No signed-in user');
    }

    final userIds = [currentUser.uid, receiverId]..sort();
    final chatRoomId = userIds.join('_');

    final newMessage = MessageModel(
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? '',
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
      seen: false,
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String userId,
    String otherUserId,
  ) {
    final userIds = [userId, otherUserId]..sort();
    final chatRoomId = userIds.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsSeen(String otherUserId) async {
  final currentUser = _firebaseAuth.currentUser;

  if (currentUser == null) {
    return;
  }

  final userIds = [currentUser.uid, otherUserId]..sort();
  final chatRoomId = userIds.join('_');

  final messagesSnapshot = await _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .where(
        'receiverId',
        isEqualTo: currentUser.uid,
      )
      .get();

  if (messagesSnapshot.docs.isEmpty) {
    return;
  }

  final batch = _firestore.batch();
  bool hasChanges = false;

  for (final document in messagesSnapshot.docs) {
    final data = document.data();

    if (data['seen'] != true) {
      batch.update(
        document.reference,
        {'seen': true},
      );

      hasChanges = true;
    }
  }

  if (hasChanges) {
    await batch.commit();
  }
}
}