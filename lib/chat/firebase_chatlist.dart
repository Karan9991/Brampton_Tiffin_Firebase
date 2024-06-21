//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:tiffin/chat/firebase_chatscreen.dart';
//
// class ChatListScreen extends StatefulWidget {
//   @override
//   _ChatListScreenState createState() => _ChatListScreenState();
// }
//
// class _ChatListScreenState extends State<ChatListScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late User _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentUser = _auth.currentUser!;
//     print('Chat Screen current user id ${_currentUser.uid}');
//   }
//
//   Future<List<Map<String, dynamic>>> _fetchChatUsers() async {
//     List<Map<String, dynamic>> chatUsers = [];
//
//     try {
//       QuerySnapshot chatListSnapshot = await FirebaseFirestore.instance
//           .collection('chatLists')
//           .where('receiver_id', isEqualTo: _currentUser.uid)
//           .get();
//
//       for (var doc in chatListSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         chatUsers.add(data);
//       }
//     } catch (e) {
//       print('Error fetching chat users: $e');
//     }
//
//     return chatUsers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchChatUsers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No chats found'));
//           }
//
//           List<Map<String, dynamic>> chatUsers = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: chatUsers.length,
//             itemBuilder: (context, index) {
//               String otherUserEmail = chatUsers[index]['sender_id'] == _currentUser.uid
//                   ? chatUsers[index]['receiverEmail']
//                   : chatUsers[index]['senderEmail'];
//               String receiverId = chatUsers[index]['sender_id'];
//               Timestamp lastMessageTime = chatUsers[index]['timestamp'];
//               String formattedTime = DateFormat('hh:mm a').format(lastMessageTime.toDate());
//
//               return Card(
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: ListTile(
//                   contentPadding: EdgeInsets.all(10),
//                   leading: CircleAvatar(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     child: Text(
//                       otherUserEmail[0].toUpperCase(),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   title: Text(
//                     otherUserEmail,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         chatUsers[index]['lastMessage'],
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         formattedTime,
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   trailing: Icon(Icons.chat, color: Theme.of(context).primaryColor),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(userId: receiverId),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tiffin/chat/firebase_chatscreen.dart';
import 'package:tiffin/helper/notification_helper.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;
  NotificationHelper notificationHelper = NotificationHelper();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    print('Chat Screen current user id ${_currentUser.uid}');
  }

  Future<List<Map<String, dynamic>>> _fetchChatUsers() async {
    List<Map<String, dynamic>> chatUsers = [];

    try {
      QuerySnapshot chatListSnapshot = await FirebaseFirestore.instance
          .collection('chatLists')
          .where('sender_id', isEqualTo: _currentUser.uid)
          .get();

      for (var doc in chatListSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        chatUsers.add(data);
      }
    } catch (e) {
      print('Error fetching chat users: $e');
    }
    return chatUsers;
  }

  // Future<void> _deleteChat(String chatId) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('chatLists').doc(chatId).delete();
  //     await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  //
  //     setState(() {}); // Refresh the chat list
  //   } catch (e) {
  //     print('Error deleting chat: $e');
  //   }
  // }
  Future<void> _deleteChat(String chatId) async {
    try {
      // Delete the chatList entry
      await FirebaseFirestore.instance.collection('chatLists').doc(chatId).delete();

      // Reference to the messages sub-collection
      CollectionReference messagesRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');

      // Fetch all messages in the sub-collection
      QuerySnapshot messagesSnapshot = await messagesRef.get();

      // Batch delete all messages
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Finally delete the chat documentpop
      await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();

      setState(() {}); // Refresh the chat list
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChatUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chats found'));
          }

          List<Map<String, dynamic>> chatUsers = snapshot.data!;

          return ListView.builder(
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              String otherUserEmail = chatUsers[index]['sender_id'] == _currentUser.uid
                  ? chatUsers[index]['receiverEmail']
                  : chatUsers[index]['senderEmail'];
              String receiverId = chatUsers[index]['receiver_id'];
              Timestamp lastMessageTime = chatUsers[index]['timestamp'];
              String formattedTime = DateFormat('hh:mm a').format(lastMessageTime.toDate());

              // String chatId = _currentUser.uid.compareTo(receiverId) > 0
              //     ? '${_currentUser.uid}-$receiverId'
              //     : '$receiverId-${_currentUser.uid}';

              String chatId = '${_currentUser.uid}-$receiverId';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      otherUserEmail[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    otherUserEmail,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatUsers[index]['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                        onPressed: () => _showDeleteConfirmationDialog(chatId),
                      ),
                      Icon(Icons.chat, color: Theme.of(context).primaryColor),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(userId: receiverId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(String chatId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Chat'),
          content: Text('Are you sure you want to delete this chat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteChat(chatId);
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
