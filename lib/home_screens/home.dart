import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tiffin/addkitchen/add.dart';
import 'package:tiffin/auth/signin.dart';
import 'package:tiffin/auth/signup.dart';
import 'package:tiffin/home_screens/homeController.dart';
import 'package:tiffin/home_screens/userSupport.dart';
import 'package:tiffin/util/snackbar.dart';
import 'package:tiffin/widgets/bannerdisplay.dart';
import 'package:tiffin/chat/chathome.dart';
import 'package:tiffin/home_screens/HomeAppBar.dart';
import 'package:tiffin/models/user.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:tiffin/webview.dart';
import 'package:tiffin/widgets/categories.dart';
import 'package:tiffin/widgets/tiffinwidgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   String _searchQuery = '';
  final HomeController controller = Get.put(HomeController());
   var userScreens = <Widget>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(controller.userType.value == 'Seller'){
      userScreens.assignAll([
        MyHomePage(),
        MyTabBarScreen(),
        ChatHome(),
      ]);
    }else{
      userScreens.assignAll([
        MyHomePage(),
        ChatHome(),
      ]);
    }
  }


  @override
  Widget build(BuildContext context) {

   return
      Obx(() {
      // if (!controller.loginStatus.value) {
      //   return MyHomePage();
      // }

      // Prepare the items and screens list dynamically based on user type
      List<Widget> defaultItems = [

      ];

      List<Widget> items = controller.items.isNotEmpty && !controller.isLoading.value ? controller.items : defaultItems;


      return Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              if (controller.loginStatus.value)
                UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, // Set your desired background color here
                ),
                accountName: null,
                accountEmail:Obx(() => Text(
                  controller.email.value,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
                currentAccountPicture: CircleAvatar(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),

              if (!controller.loginStatus.value)
                ListTile(
                  leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
                  title: Text('Sign up for more features!'),
                  subtitle: Text('Chat with sellers or customers, publish tiffins, and more.'),
                  onTap: () {
                    // Navigate to sign-up screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()), // Adjust this to your sign-up screen
                    );
                  },
                ),

              if (controller.loginStatus.value)
                ListTile(
                leading:
                    Icon(Icons.logout, color: Theme.of(context).primaryColor),
                title: Text('Logout'),
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                  //logout();
                 // Navigator.pop(context);
                  // Perform logout action
                },
              ),

              ListTile(
                leading: Icon(Icons.support, color: Colors.blue),
                title: Text('Support'),
                onTap: () {
                  // Navigate to the support web URL
                  //_launchUrl();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SupportScreen()),
                  );
                },
              ),

              ListTile(
                leading:
                    Icon(Icons.policy, color: Theme.of(context).primaryColor),
                title: Text('Privacy Policy'),
                onTap: () {
                  _privacyUrl();
                  // Navigate to privacy policy screen or launch privacy policy URL
                  // Implement the desired navigation or launching logic here
                  // For example:
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.article, color: Theme.of(context).primaryColor),
                title: Text('Terms and Conditions'),
                onTap: () {
                  _termsUrl();
                  // Navigate to terms and conditions screen or launch terms and conditions URL
                  // Implement the desired navigation or launching logic here
                  // For example:
                },
              ),

              if (controller.loginStatus.value)
                ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Account'),
                onTap: () {
                  _showDeleteAccountConfirmationDialog(context);
                },
              ),

            ],
          ),
        ),
        body: ListView(
          children: [
            HomeAppBar(),
            Container(
              // height: 500,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  )),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          height: 50,
                          width: 250,
                          child: TextFormField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search here..."),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.search,
                          size: 27,
                        )
                      ],
                    ),
                  ),
                  //banner

                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    //Banners
                    child: BannerDisplay(),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    child: Text(
                      "Best Selling",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  //Categories
                  Categories(),
                  //Tiffins
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text(
                      "Tiffins",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),

                  //tiffins
                  //Flexible(
                  Tiffins(searchQuery: _searchQuery),
                  //),
                ],
              ),
            )
          ],
        ),


          bottomNavigationBar:
        // Obx(() {
        //   return
          controller.loginStatus.value ?
          CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            onTap: (index) {
              Get.to(controller.userScreens[index]);
            },
            color: Theme.of(context).primaryColor,
            height: 50,
            items: items

          ): null
     // })


      );
    });
        }


  Future<void> deleteAccountLogout() async {
    try {
      // Perform account deletion logic

      await deleteAccount(); // Call the server-side deleteAccount function

      // Perform other necessary cleanup or actions
      await SharedPrefHelper.init();
      await SharedPrefHelper.remove('email');
      await SharedPrefHelper.remove('password');
      await SharedPrefHelper.remove('userType');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      await _deleteAccountUrl();

      show(context, 'Account successfully deleted', isError: false);

    } catch (e) {
      print('Failed to delete account: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

     final firestore = await FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);
    await firestore.delete();
    await firebaseUser!.delete();

      // Handle successful deletion
      // TODO: Implement your desired logic here
      print('Account deleted successfully');
    } catch (e) {
      // Handle error
      // TODO: Implement your error handling logic here
      print('Failed to delete account: $e');
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete operation
                logout();
                //Navigator.of(context).pop(); // Close dialog

              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete Account'),
          content: Text('Are you sure you want to delete your account. Your all data will be deleted permanently and can not be recover?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete operation
                deleteAccountLogout();

                //Navigator.of(context).pop(); // Close dialog

              },
              child: Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    final firebaseUser = FirebaseAuth.instance;
    try {
      firebaseUser.signOut();

      await SharedPrefHelper.init();
      await SharedPrefHelper.remove('email');
      await SharedPrefHelper.remove('password');
      await SharedPrefHelper.remove('userType');

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    } catch (e) {
      print("Error signing out: $e");
    }

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

  Future<void> _termsUrl() async {
    final Uri _privUrl = Uri.parse(
        'https://doc-hosting.flycricket.io/brampton-tiffin-terms-conditions/83ec4a56-84f6-445a-a208-6a7bc805245e/terms');

    if (!await launchUrl(_privUrl)) {
      throw Exception('Could not launch $_privUrl');
    }
  }

  Future<void> _privacyUrl() async {
    final Uri _privUrl = Uri.parse(
        'https://doc-hosting.flycricket.io/brampton-tiffin-privacy-policy/a331e2a2-ba9e-4714-a359-9fb4f8513c9a/privacy');

    if (!await launchUrl(_privUrl)) {
      throw Exception('Could not launch $_privUrl');
    }
  }

   Future<void> _deleteAccountUrl() async {
     final Uri _deleteAccounttUrl = Uri.parse(
         'https://karan9991.github.io/bramptontiff/');

     if (!await launchUrl(_deleteAccounttUrl)) {
       throw Exception('Could not launch $_deleteAccounttUrl');
     }
   }
}
