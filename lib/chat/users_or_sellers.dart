import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/chat/chat.dart';
import 'package:tiffin/util/shared_pref.dart';

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<dynamic> _customers = [];
  int _currentUserId = 0;
  String _userType = '';

  Future<void> _fetchCustomers() async {
        final Map<String, dynamic> user = await getUser();

      print('usertp $_userType');
    if (user['userType'] == 'Customer') {
      print(user['userType']);
      final response = await http.get(Uri.parse(Constants.getAllSellers));
      final responseData = json.decode(response.body);
      setState(() {
        _customers = responseData['data'];
      });
    } else if (user['userType'] == 'Seller') {
      final response = await http.get(Uri.parse(Constants.getAllCustomers));
      final responseData = json.decode(response.body);
      setState(() {
        _customers = responseData['data'];
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
  void initState() {
    super.initState();
   // _getUserType();
    _fetchCustomers();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final Map<String, dynamic> user = await getUser();
    setState(() {
      _currentUserId = user['id'];
    });
  }

  Future<void> _getUserType() async {
    final Map<String, dynamic> user = await getUser();
    setState(() {
      _userType = user['userType'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          if (customer['id'] == _currentUserId) {
            return SizedBox.shrink(); // skip displaying the current user
          }
          return GestureDetector(
            onTap: () => navigateToChatScreen(_currentUserId, customer['id']),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(customer['email'][0].toUpperCase()),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        customer['email'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

