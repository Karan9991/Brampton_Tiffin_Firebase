//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tiffin/addkitchen/add.dart';
// import 'package:tiffin/auth/signin.dart';
// import 'package:tiffin/chat/chathome.dart';
// import 'package:tiffin/home_screens/home.dart';
// import 'package:tiffin/models/user.dart';
//
// class HomeController extends GetxController {
//   var userType = ''.obs;
//   var email = ''.obs;
//   var loginStatus = false.obs;
//   var isLoading = false.obs;
//   var userScreens = <Widget>[].obs;
//
//   late StreamSubscription<User?> _authSubscription;
//
//   @override
//   void onInit() {
//     super.onInit();
//     checkLoginStatus();
//   }
//
//   void checkLoginStatus() async {
//     _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
//       if (user != null) {
//         print('home user not null');
//         loginStatus.value = true;
//         Users? firebaseUser;
//
//         // Retry logic to fetch user data
//         int retryCount = 0;
//         const int maxRetries = 3;
//         const Duration retryDelay = Duration(seconds: 2);
//
//         while (firebaseUser == null && retryCount < maxRetries) {
//           firebaseUser = await getUserData(user.uid);
//           if (firebaseUser == null) {
//             print('User data not available yet, retrying...');
//             retryCount++;
//             await Future.delayed(retryDelay);
//           }
//         }
//
//         if (firebaseUser != null) {
//           email.value = firebaseUser.email ?? '';
//           userType.value = firebaseUser.user_type ?? '';
//           print('home user not null email ${email.value}');
//
//           userScreens.assignAll([
//             MyHomePage(),
//             userType.value == 'Customer' ? ChatHome() : MyTabBarScreen(),
//             ChatHome(),
//           ]);
//         } else {
//           // Handle the case where user data is still not available after retries
//           print('Failed to fetch user data after retries');
//           loginStatus.value = false;
//           Get.offAll(SignIn());
//         }
//       } else {
//         print('home user is null');
//         loginStatus.value = false;
//         Get.offAll(SignIn());
//       }
//     });
//   }
//
//   Future<Users?> getUserData(String uid) async {
//     final _firestore = FirebaseFirestore.instance;
//     try {
//       DocumentSnapshot<Map<String, dynamic>> snapshot =
//       await _firestore.collection('users').doc(uid).get();
//       if (snapshot.exists) {
//         return Users.fromJson(snapshot.data()!);
//       } else {
//         print('User data not found');
//         return null;
//       }
//     } catch (e) {
//       print("Error getting user data: $e");
//       return null;
//     }
//   }
//
//   @override
//   void onClose() {
//     _authSubscription.cancel();
//     super.onClose();
//   }
// }


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiffin/addkitchen/add.dart';
import 'package:tiffin/auth/signin.dart';
import 'package:tiffin/chat/chathome.dart';
import 'package:tiffin/home_screens/home.dart';
import 'package:tiffin/models/user.dart';

class HomeController extends GetxController {
  var userType = ''.obs;
  var email = ''.obs;
  var loginStatus = false.obs;
  var isLoading = false.obs;
  var userScreens = <Widget>[].obs;
  var items = <Widget>[].obs;
  var selectedIndex = 0.obs; // Added this line

  late StreamSubscription<User?> _authSubscription;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    isLoading.value = true;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        print('home user not null');
        loginStatus.value = true;
        Users? firebaseUser;

        // Retry logic to fetch user data
        int retryCount = 0;
        const int maxRetries = 3;
        const Duration retryDelay = Duration(seconds: 2);

        while (firebaseUser == null && retryCount < maxRetries) {
          firebaseUser = await getUserData(user.uid);
          if (firebaseUser == null) {
            print('User data not available yet, retrying...');
            retryCount++;
            await Future.delayed(retryDelay);
          }
        }

        if (firebaseUser != null) {
          email.value = firebaseUser.email ?? '';
          userType.value = firebaseUser.user_type ?? '';
          print('home user not null email ${email.value}');

          if(userType.value == 'Seller'){
            userScreens.assignAll([
              MyHomePage(),
              MyTabBarScreen(),
              ChatHome(),
            ]);

             items.value = [
              Icon(
                Icons.home,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.chat,
                size: 30,
                color: Colors.white,
              ),
            ];

          }else{
            userScreens.assignAll([
              MyHomePage(),
              ChatHome(),
            ]);

            items.value = [
              Icon(
                Icons.home,
                size: 30,
                color: Colors.white,
              ),
              //Container(),

              Icon(
                Icons.chat,
                size: 30,
                color: Colors.white,
              ),
            ];
          }

        } else {
          // Handle the case where user data is still not available after retries
          print('Failed to fetch user data after retries');
          loginStatus.value = false;
          Get.offAll(MyHomePage());
        }
      } else {
        print('home user is null');
        loginStatus.value = false;
        Get.offAll(MyHomePage());
      }
    });
    isLoading.value = false;
  }

  Future<Users?> getUserData(String uid) async {
    final _firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
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
  void onClose() {
    _authSubscription.cancel();
    super.onClose();
  }
}
