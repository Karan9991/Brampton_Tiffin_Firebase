import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiffin/chat/chat.dart';
import 'package:intl/intl.dart'; // import the intl package
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';

class Chat {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String createdAt;

  Chat({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      senderId: int.parse(json['sender_id']),
      receiverId: int.parse(json['receiver_id']),
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _currentUserId = 0;
  // int _userIdforGetEmail = 0;
//  String email = '';
  List<int> userIds = [];
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    _getUserId();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final response = await http
        .get(Uri.parse(Constants.fetchchat)); // replace with your API URL
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final chatsData = List<Map<String, dynamic>>.from(jsonData['data']);
      final chats =
          chatsData.map((chatData) => Chat.fromJson(chatData)).toList();

      // Get the unique list of user IDs based on the chats
      List<int> uniqueUserIds = [];
      chats.forEach((chat) {
        int userId =
            chat.senderId == _currentUserId ? chat.receiverId : chat.senderId;
        if (!uniqueUserIds.contains(userId)) {
          uniqueUserIds.add(userId);
        }
      });

      setState(() {
        this.userIds = uniqueUserIds;
        this.chats = chats;
      });
    }
  }

  void navigateToChatScreen(int senderId, int receiverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          senderId: senderId,
          receiverId: receiverId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ListView.builder(
        itemCount: userIds.length,
        itemBuilder: (context, index) {
          final userId = userIds[index];
          // Find the latest chat with the user
          Chat? latestChat;
          if (chats.any((chat) =>
              (chat.senderId == _currentUserId && chat.receiverId == userId) ||
              (chat.senderId == userId && chat.receiverId == _currentUserId))) {
            latestChat = chats
                .where((chat) =>
                    (chat.senderId == _currentUserId &&
                        chat.receiverId == userId) ||
                    (chat.senderId == userId &&
                        chat.receiverId == _currentUserId))
                .toList()
                .reduce(
                    (a, b) => a.createdAt.compareTo(b.createdAt) > 0 ? a : b);
          }
        
          if (latestChat != null) {
            final recentTime = DateTime.parse(latestChat.createdAt)
                .toString(); // convert to local time zone
            final recentTime2 = DateFormat("yyyy-MM-dd HH:mm")
                .format(DateTime.parse(latestChat.createdAt));

            // return ListTile(
            //   onTap: () => navigateToChatScreen(_currentUserId, userId),
            //   leading: CircleAvatar(
            //     child: Text(userId.toString()),
            //   ),
            //   title: Text('User $userId'),
            //   subtitle: Text(latestChat.message),
            //   trailing: Text(recentTime2),
            // );
             return FutureBuilder(
            future: fetchUserEmailById(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                final email = snapshot.data;
                return ListTile(
                  onTap: () =>
                      navigateToChatScreen(_currentUserId, userId),
                  leading: CircleAvatar(
                    child: Text(email![0].toUpperCase()),
                  ),
                  title: Text(email!),
                  subtitle: Text(latestChat!.message),
                  trailing: Text(recentTime2),
                );
              }
              return SizedBox.shrink(); // Return an empty widget while fetching email
            },
          );
          }
        },
      ),
    );
  }

  Future<String> fetchUserEmailById(int id) async {
    final response = await http.get(
            Uri.parse(Constants.getUserById+ "/$id"),

    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body)['data'];
      return user['email'];
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  Future<void> _getUserId() async {
    final Map<String, dynamic> user = await getUser();
    setState(() {
      _currentUserId = user['id'];
    });
  }

  static Future<Map<String, dynamic>> getUser() async {
    await SharedPrefHelper.init();
    return {
      'id': SharedPrefHelper.getInt('id') ?? 0,
      'userType': SharedPrefHelper.getString('userType') ?? '',
      'token': SharedPrefHelper.getString('token') ?? '',
    };
  }
}

