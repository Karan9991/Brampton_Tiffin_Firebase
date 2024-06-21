import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:tiffin/addkitchen/createkitchen.dart';
import 'package:tiffin/addkitchen/createtiffin.dart';
import 'package:tiffin/chat/chat.dart';
// import 'package:tiffin/chat/chatlist.dart';
import 'package:tiffin/chat/firebase_chatlist.dart';
import 'package:tiffin/chat/firebase_customers_or_sellers.dart';
import 'package:tiffin/chat/users_or_sellers.dart';
import 'package:tiffin/models/user.dart';
import 'package:tiffin/viewtiffins/viewtiffins.dart';
import 'package:tiffin/chat/chat.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:tiffin/chat/firebase_customers_or_sellers.dart';

class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  String _userType = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // final Map<String, dynamic> user = await getUser();
    // userType = user['userType'];

    _getUserType();
  }

  Future<void> _getUserType() async {
    await SharedPrefHelper.init();
    String? usertp = SharedPrefHelper.getString('userType');

    print('Chat Home user type $usertp');
    final uid = await FirebaseAuth.instance.currentUser!.uid;

    final user = await getUserData(uid);

    setState(() {
      _userType = user?.user_type ?? '';
    });
  }

  Future<Users?> getUserData(String uid) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        // Map the document data to a User object
        return Users.fromJson(snapshot.data()!);
      } else {
        print('User data not found');
        return null;
      }
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Chat with ${_userType == 'Customer' ? 'Seller' : 'Customer'}s',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          // Text(
          //   'Chat with ' + _userType + 's',
          //   style: TextStyle(
          //     color: Colors.white,
          //   ),
          // ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: TabBar(
                indicator: BubbleTabIndicator(
                  indicatorRadius: 10,
                  indicatorHeight: 40,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                      text:
                          '${_userType == 'Customer' ? 'Seller' : 'Customer'}s'),
                  Tab(text: 'Chat List'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SellerCustomerScreen(),
            ChatListScreen(),
          ],
        ),
      ),
    );
  }
}
