
// Model for chat history and message
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistory {
  final String title;
  final String lastMessage;

  ChatHistory({required this.title, required this.lastMessage});
}

class ChatMessage {
  final String message;
  final bool isUserMessage;

  ChatMessage({required this.message, required this.isUserMessage});
}

// Firestore functions
Future<List<ChatHistory>> fetchChatHistoriesFromFirestore() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chats')
      .orderBy('timestamp', descending: true)
      .get();

  return querySnapshot.docs
      .map((doc) => ChatHistory(
            title: doc['title'],
            lastMessage: doc['lastMessage'],
          ))
      .toList();
}

Future<void> saveCurrentChatToFirestore() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final chatCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chats');

  final currentChat = {
    'title': 'Chat ${DateTime.now().toIso8601String()}',
    'lastMessage': 'Your last message', // Update this with the actual last message
    'timestamp': FieldValue.serverTimestamp(),
  };

  await chatCollection.add(currentChat);
}