import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminChatPage extends StatefulWidget {
  final String sessionId;
  const AdminChatPage({super.key, required this.sessionId});

  @override
  // ignore: library_private_types_in_public_api
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String adminId =
      "admin"; // Example admin ID, replace with actual admin identification

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _firestore
          .collection('chat_sessions')
          .doc(widget.sessionId)
          .collection('messages')
          .add({
        'message': _messageController.text,
        'sender_id': adminId, // Admin ID
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    bool isMine = messageData['sender_id'] == adminId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          messageData['message'],
          style: TextStyle(color: isMine ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chat_sessions')
                  .doc(widget.sessionId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var messageData = snapshot.data!.docs[index].data();
                      return _buildMessageBubble(
                          messageData as Map<String, dynamic>);
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Type your message here...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
