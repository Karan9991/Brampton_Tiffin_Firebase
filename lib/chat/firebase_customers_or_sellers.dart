//
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tiffin/chat/firebase_chatscreen.dart';
//
// class SellerCustomerScreen extends StatefulWidget {
//   @override
//   _SellerCustomerScreen createState() => _SellerCustomerScreen();
// }
//
// class _SellerCustomerScreen extends State<SellerCustomerScreen> {
//   Future<List<Map<String, dynamic>>> fetchSellers() async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('user_type', isEqualTo: 'Seller')
//           .get();
//
//       List<Map<String, dynamic>> sellers = snapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           'email': doc['email'],
//         };
//       }).toList();
//
//       return sellers;
//     } catch (e) {
//       throw Exception('Failed to load sellers: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchSellers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No sellers found'));
//           } else {
//             List<Map<String, dynamic>> sellers = snapshot.data!;
//             return ListView.builder(
//               itemCount: sellers.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(sellers[index]['email']),
//                   onTap: () {
//                     // Navigate to chat screen
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(userId: sellers[index]['id']),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }





import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiffin/chat/firebase_chatscreen.dart';
import 'package:tiffin/models/user.dart';

class SellerCustomerScreen extends StatefulWidget {
  @override
  _SellerCustomerScreen createState() => _SellerCustomerScreen();
}

class _SellerCustomerScreen extends State<SellerCustomerScreen> {
  String userType = '';

  Future<List<Map<String, dynamic>>> fetchSellers() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final user = await getUserData(uid);
    userType = user?.user_type ?? '';
    if(userType == 'Customer'){
      userType = 'Seller';
      print('user type if $userType');

    }else if(userType == 'Seller'){
      userType = 'Customer';
      print('user type if else $userType');

    }else{
      print('user type else $userType');
    }

    try {
      print('user type else $userType');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user_type', isEqualTo: userType)
          .get();

      List<Map<String, dynamic>> sellers = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'email': doc['email'],
        };
      }).toList();

      return sellers;
    } catch (e) {
      throw Exception('Failed to load sellers: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Chat users found'));
          } else {
            List<Map<String, dynamic>> sellers = snapshot.data!;
            return ListView.builder(
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        sellers[index]['email'][0].toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      sellers[index]['email'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.chat, color: Theme.of(context).primaryColor,
                  ),
                    onTap: () {
                      // Navigate to chat screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(userId: sellers[index]['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
