//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userId;
//
//   ChatScreen({required this.userId});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late User _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentUser = _auth.currentUser!;
//   }
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.isEmpty) return;
//
//     String chatId = _currentUser.uid.compareTo(widget.userId) > 0
//         ? '${_currentUser.uid}-${widget.userId}'
//         : '${widget.userId}-${_currentUser.uid}';
//
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'sender_id': _currentUser.uid,
//       'receiver_id': widget.userId,
//       'message': _messageController.text,
//       'timestamp': FieldValue.serverTimestamp(),
//       'deleted_by_sender': false,
//       'deleted_by_receiver': false,
//     });
//
//
//     //1 Check if chatList entry exists
//     final chatListRef = FirebaseFirestore.instance.collection('chatLists');
//     final chatListDoc = await chatListRef.doc(chatId).get();
//
//     if (!chatListDoc.exists) {
//       // Add chat to chatLists if it doesn't exist
//       await chatListRef.doc(chatId).set({
//         'sender_id': _currentUser.uid,
//         'receiver_id': widget.userId,
//         'lastMessage': _messageController.text,
//         'timestamp': FieldValue.serverTimestamp(),
//         'senderEmail': _currentUser.email,
//         'receiverEmail': (await FirebaseFirestore.instance.collection('users').doc(widget.userId).get()).data()!['email'],
//       });
//     } else {
//       // Update the last message and timestamp
//       await chatListRef.doc(chatId).update({
//         'lastMessage': _messageController.text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }
//
//     //2 Check if chatList entry exists
//     String chatId2 = _currentUser.uid.compareTo(widget.userId) > 0
//         ? '${widget.userId}-${_currentUser.uid}' :
//     '${_currentUser.uid}-${widget.userId}';
//
//
//     final chatListRef2 = FirebaseFirestore.instance.collection('chatLists');
//     final chatListDoc2 = await chatListRef2.doc(chatId2).get();
//
//     if (!chatListDoc2.exists) {
//       // Add chat to chatLists if it doesn't exist
//       await chatListRef2.doc(chatId2).set({
//         'sender_id': widget.userId,
//         'receiver_id': _currentUser.uid,
//         'lastMessage': _messageController.text,
//         'timestamp': FieldValue.serverTimestamp(),
//         'senderEmail': (await FirebaseFirestore.instance.collection('users').doc(widget.userId).get()).data()!['email'],
//         'receiverEmail': _currentUser.email,
//       });
//     } else {
//       // Update the last message and timestamp
//       await chatListRef2.doc(chatId2).update({
//         'lastMessage': _messageController.text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }
//
//     _messageController.clear();
// }
//
//   @override
//   Widget build(BuildContext context) {
//     String chatId = _currentUser.uid.compareTo(widget.userId) > 0
//         ? '${_currentUser.uid}-${widget.userId}'
//         : '${widget.userId}-${_currentUser.uid}';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 List<DocumentSnapshot> docs = snapshot.data!.docs;
//
//                 List<Widget> messages = docs.map((doc) {
//                   bool isDeletedBySender = doc['deleted_by_sender'];
//                   bool isDeletedByReceiver = doc['deleted_by_receiver'];
//                   bool isCurrentUserSender = _currentUser.uid == doc['sender_id'];
//
//                   if ((isCurrentUserSender && isDeletedBySender) ||
//                       (!isCurrentUserSender && isDeletedByReceiver)) {
//                     return SizedBox.shrink();
//                   }
//
//                   return Message(
//                     from: doc['sender_id'],
//                     text: doc['message'],
//                     time: doc['timestamp'] != null
//                         ? (doc['timestamp'] as Timestamp).toDate()
//                         : DateTime.now(),
//                     me: _currentUser.uid == doc['sender_id'],
//                     messageId: doc.id,
//                     chatId: chatId,
//                   );
//                 }).toList();
//
//                 return ListView(
//                   reverse: true,
//                   children: messages,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     cursorColor: Theme.of(context).primaryColor,
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 2.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 2.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Message extends StatelessWidget {
//   final String from;
//   final String text;
//   final DateTime time;
//   final bool me;
//   final String messageId;
//   final String chatId;
//
//   const Message({required this.from, required this.text, required this.time, required this.me, required this.messageId, required this.chatId});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () => _showDeleteConfirmationDialog(context),
//       child: Container(
//         alignment: me ? Alignment.centerRight : Alignment.centerLeft,
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: Column(
//           crossAxisAlignment:
//           me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: me ? Theme.of(context).primaryColor : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                 me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     text,
//                     style: TextStyle(
//                       color: me ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     DateFormat('hh:mm a').format(time),
//                     style: TextStyle(
//                       color: me ? Colors.white70 : Colors.black54,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Message'),
//           content: Text('Are you sure you want to delete this message?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteMessage();
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _deleteMessage() async {
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .doc(messageId)
//         .update({'deleted_by_${me ? 'sender' : 'receiver'}': true});
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String userId;

  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;


    String chatId ='${_currentUser.uid}-${widget.userId}';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'sender_id': _currentUser.uid,
      'receiver_id': widget.userId,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final chatListRef = await FirebaseFirestore.instance.collection('chatLists');
    final chatListDoc = await chatListRef.doc(chatId).get();

    if (!chatListDoc.exists) {
      await chatListRef.doc(chatId).set({
        'sender_id': _currentUser.uid,
        'receiver_id': widget.userId,
        'lastMessage': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderEmail': _currentUser.email,
        'receiverEmail': (await FirebaseFirestore.instance.collection('users').doc(widget.userId).get()).data()!['email'],
      });
    } else {
      await chatListRef.doc(chatId).update({
        'lastMessage': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }


    String chatId2 = '${widget.userId}-${_currentUser.uid}';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId2)
        .collection('messages')
        .add({
      'sender_id': _currentUser.uid,
      'receiver_id': widget.userId,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final chatListRef2 = await FirebaseFirestore.instance.collection('chatLists');
    final chatListDoc2 = await chatListRef2.doc(chatId2).get();

    if (!chatListDoc2.exists) {
      await chatListRef2.doc(chatId2).set({
        'sender_id': widget.userId,
        'receiver_id': _currentUser.uid,
        'lastMessage': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'senderEmail': (await FirebaseFirestore.instance.collection('users').doc(widget.userId).get()).data()!['email'],
        'receiverEmail': _currentUser.email,
      });
    } else {
      await chatListRef2.doc(chatId2).update({
        'lastMessage': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    _sendNotification(widget.userId, _messageController.text);

    _messageController.clear();
  }

  Future<void> _sendNotification(String receiverId, String message) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(
        receiverId).get();
    if (userDoc.exists) {
      final token = userDoc.data()?['fcmToken'];
      if (token != null) {
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=AAAAHWjVjTk:APA91bGy59eZRzwSkRLnr_WcMnPdQ3N94ZsMwvqGTAPbk6sS4_YrucUqbABPM51IaZycIkZjCHroF5hZdKZkN4ts3lGLZkqN8YzXLzcPWSxBIDOCbeqw6KHqZsDOxyetiV3I-3c0ZwZz',
            // Replace with your FCM server key
          },
          body: jsonEncode({
            'to': token,
            'notification': {
              'title': 'New Message',
              'body': message,
            },
          }),
        );

        if (response.statusCode != 200) {
          print('Failed to send notification');
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String chatId = '${_currentUser.uid}-${widget.userId}';
print('chat screen chatid $chatId');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                List<Widget> messages = docs.map((doc) {
                  return Message(
                    from: doc['sender_id'],
                    text: doc['message'],
                    time: doc['timestamp'] != null
                        ? (doc['timestamp'] as Timestamp).toDate()
                        : DateTime.now(),
                    me: _currentUser.uid == doc['sender_id'],
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Theme.of(context).primaryColor,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
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

class Message extends StatelessWidget {
  final String from;
  final String text;
  final DateTime time;
  final bool me;

  const Message(
      {required this.from, required this.text, required this.time, required this.me});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.75,
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: me ? Theme
                  .of(context)
                  .primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment:
              me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: me ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('hh:mm a').format(time),
                  style: TextStyle(
                    color: me ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//
//   @override
//   Widget build(BuildContext context) {
//     // String chatId = _currentUser.uid.compareTo(widget.userId) > 0
//     //     ? '${_currentUser.uid}-${widget.userId}'
//     //     : '${widget.userId}-${_currentUser.uid}';
//     String chatId = '${_currentUser.uid}-${widget.userId}';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(chatId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 List<DocumentSnapshot> docs = snapshot.data!.docs;
//
//                 List<Widget> messages = docs.map((doc) {
//                   // bool isDeletedBySender = doc['deleted_by_sender'];
//                   // bool isDeletedByReceiver = doc['deleted_by_receiver'];
//                   // bool isCurrentUserSender = _currentUser.uid == doc['sender_id'];
//
//                   // if ((isCurrentUserSender && isDeletedBySender) ||
//                   //     (!isCurrentUserSender && isDeletedByReceiver)) {
//                   //   return SizedBox.shrink();
//                   // }
//
//                   return Message(
//                     from: doc['sender_id'],
//                     text: doc['message'],
//                     time: doc['timestamp'] != null
//                         ? (doc['timestamp'] as Timestamp).toDate()
//                         : DateTime.now(),
//                     me: _currentUser.uid == doc['sender_id'],
//                     messageId: doc.id,
//                     chatId: chatId,
//                   );
//                 }).toList();
//
//                 return ListView(
//                   reverse: true,
//                   children: messages,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     cursorColor: Theme.of(context).primaryColor,
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 2.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 2.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Message extends StatelessWidget {
//   final String from;
//   final String text;
//   final DateTime time;
//   final bool me;
//   final String messageId;
//   final String chatId;
//
//   const Message({required this.from, required this.text, required this.time, required this.me, required this.messageId, required this.chatId});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () => _showDeleteConfirmationDialog(context),
//       child: Container(
//         alignment: me ? Alignment.centerRight : Alignment.centerLeft,
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: Column(
//           crossAxisAlignment:
//           me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: me ? Theme.of(context).primaryColor : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                 me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     text,
//                     style: TextStyle(
//                       color: me ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     DateFormat('hh:mm a').format(time),
//                     style: TextStyle(
//                       color: me ? Colors.white70 : Colors.black54,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Message'),
//           content: Text('Are you sure you want to delete this message?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 _deleteMessage();
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _deleteMessage() async {
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .doc(messageId)
//         .update({'deleted_by_${me ? 'sender' : 'receiver'}': true});
//   }
// }
