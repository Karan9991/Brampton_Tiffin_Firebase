import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffin/addkitchen/add.dart';
import 'package:tiffin/admin/banner.dart';
import 'package:tiffin/admin/bestSelling.dart';
import 'package:tiffin/auth/signin.dart';
import 'package:tiffin/helper/notification_helper.dart';
import 'package:tiffin/home_screens/home.dart';
import 'package:tiffin/onbording.dart';
import 'package:tiffin/util/constants.dart';
import 'package:tiffin/webview.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int? initScreen = 0;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
NotificationHelper notificationHelper = NotificationHelper();
final FirebaseAuth _auth = FirebaseAuth.instance;
late User _currentUser;
late FirebaseMessaging _messaging;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  notificationHelper.notificationPermission();
  if(_auth.currentUser != null) {
    _currentUser = _auth.currentUser!;
// notification
    try {
      await NotificationHelper().initialize(flutterLocalNotificationsPlugin);
      _initializeFCM();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = await prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  // SharedPrefHelper.init();
  // initScreen = SharedPrefHelper.getInt('initScreen');
  // SharedPrefHelper.setInt('initScreen', 1);
  print('initScreen ${initScreen}');
  //  await SharedPrefHelper.init();
  //   await SharedPrefHelper.setBool('showOnboardingScreen', true);
  runApp(const MyApp());
}

void _initializeFCM() {
  _messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.messageId}');
    if (message.notification != null) {
      // Handle the notification
      print('Message contained a notification: ${message.notification?.title ?? 'no title'}');
      print('Message contained a notification: ${message.notification?.body ?? 'no body'}');
      _showNotification(message.notification!.title, message.notification!.body);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    // Handle the notification
  });

  _messaging.getToken().then((token) {
    print('FCM Token: $token');
    // Save the token to Firestore under the user's document
    FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).update({
      'fcmToken': token,
    });
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _showNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id', 'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  _showNotification(message.notification!.title, message.notification!.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: lightGren,
      ),

     // home: CategoryUploadScreen(),

      home: initScreen == 0 || initScreen == null ? Onbording() : MyHomePage(),
      initialRoute: '/home',
      routes: {
        '/home': (context) =>
            initScreen == 0 || initScreen == null ? Onbording() : MyHomePage(),
        '/login': (context) => SignIn(),
      },
    );
  }
}
