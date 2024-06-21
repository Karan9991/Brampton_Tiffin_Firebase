import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiffin/util/app_constants.dart';

class Message {
  final String message;
  final int senderId;
  final int? receiverId;
  final bool isSent;
  final String? createdAt;

  Message({
    required this.message,
    required this.senderId,
    required this.isSent,
    this.receiverId,
    this.createdAt,
  });
}

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;

  ChatScreen({required this.senderId, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  late Timer _timer;
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch messages every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchMessages(widget.senderId, widget.receiverId);
print('fetch messages ${widget.senderId} ${widget.receiverId}');
    });
  }

  @override
  void dispose() {
    // Cancel the timer to prevent setState calls after the widget is disposed
    _timer.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


Future<void> fetchMessages(int senderId, int receiverId) async {
  String sender = senderId.toString();
  String receiver = receiverId.toString();

  final receiverResponse = await http.get(Uri.parse('${Constants.fetchchat}'));
  final senderResponse = await http.get(Uri.parse('${Constants.fetchchat}'));

  if (receiverResponse.statusCode == 200 &&
      senderResponse.statusCode == 200) {
    final receiverData = jsonDecode(receiverResponse.body);
    final senderData = jsonDecode(senderResponse.body);

    final receiverMessagesList =
        List<Map<String, dynamic>>.from(receiverData['data']);
    final senderMessagesList =
        List<Map<String, dynamic>>.from(senderData['data']);

    final receiverMessages = receiverMessagesList
        .where((message) =>
            message['sender_id'] == receiver && // Update the condition here
            message['receiver_id'] == sender) // Update the condition here
        .map((message) => Message(
              message: message['message'],
              senderId: int.parse(receiver),
              isSent: false,
              createdAt: message['created_at'],
            ))
        .toList();

    final senderMessages = senderMessagesList
        .where((message) =>
            message['sender_id'] == sender && // Update the condition here
            message['receiver_id'] == receiver) // Update the condition here
        .map((message) => Message(
              message: message['message'],
              senderId: int.parse(sender),
              isSent: true,
              createdAt: message['created_at'],
            ))
        .toList();

    final sortedMessages = [...receiverMessages, ...senderMessages]
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    setState(() {
      messages = sortedMessages;
    });
  }

  if (messages.isNotEmpty) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
}
  Future<void> sendMessage(
      String messageText, int senderId, int receiverId) async {
    String sender = senderId.toString();
    String receiver = receiverId.toString();

    final response = await http.post(
      Uri.parse(Constants.storechat),
      body: {
        'sender_id': sender,
        'receiver_id': receiver,
        'message': messageText
      },
    );
    if (response.statusCode == 200) {
      final message = Message(
          message: messageText,
          senderId: int.parse(sender),
          receiverId: int.parse(receiver),
          isSent: true);
      setState(() {
        messages.add(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final alignment = message.isSent
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start;
                final backgroundColor = message.isSent
                    ? Theme.of(context).primaryColor
                    : Color.fromARGB(255, 237, 255, 241);
                final textColor = message.isSent ? Colors.white : Colors.black;
                return Align(
                  alignment:
                      message.isSent ? Alignment.topRight : Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_textController.text, widget.senderId,
                        widget.receiverId);
                    _textController.clear();
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

