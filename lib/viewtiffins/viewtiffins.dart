import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiffin/models/createKitchen.dart';
import 'package:tiffin/models/publishTiffin.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:tiffin/models/tiffin.dart';

class TiffinScreen extends StatefulWidget {
  @override
  _TiffinScreenState createState() => _TiffinScreenState();
}

class _TiffinScreenState extends State<TiffinScreen> {
  //late List<Tiffin> _tiffins = [];
  List<PublishTiffin> _tiffins = [];
  bool _isLoading = true;
  bool _kitchenDeleted = false;
  int userId = 0;

  String kitchenName = '';
  String kitchenImage = '';
  String kitchenId = '';
  String uid = '';

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    print('init clledddd');

    _getData();
  }

  Future<void> _getData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;

    _getTiffins(userId);
  }


  Future<void> _getTiffins(int userId) async {
    print('get tiffin User ID okkk: $userId');
    try {

      String uid  = FirebaseAuth.instance.currentUser!.uid;

      List<CreateKitchen> kit = await getKitchens(uid);
      _tiffins = await getTiffins(uid);
      //if (success) {
        kitchenId = kit[0].id!;
        kitchenName = kit[0].name!;
        kitchenImage = kit[0].banner!;
        print("real data" + kitchenName);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<List<CreateKitchen>> getKitchens(String uid) async {
    List<CreateKitchen> kitchens = [];
    try {
      QuerySnapshot kitchenSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('kitchens')
          .get();

      kitchenSnapshot.docs.forEach((DocumentSnapshot doc) {
        kitchens.add(CreateKitchen.fromJson(doc.id, doc.data() as Map<String, dynamic>));
      });
    } catch (e) {
      print('Error fetching kitchens: $e');
    }
    return kitchens;
  }

  Future<List<PublishTiffin>> getTiffins(String uid) async {
    List<PublishTiffin> tiffins = [];
    try {
      QuerySnapshot tiffinSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tiffins')
          .get();

      tiffinSnapshot.docs.forEach((DocumentSnapshot doc) {
        tiffins.add(PublishTiffin.fromJson(doc.id, doc.data() as Map<String, dynamic>));
      });
    } catch (e) {
      print('Error fetching tiffins: $e');
    }
    return tiffins;
  }

  Future<void> deleteKitchen(String kitchenId) async {
    print('deleteKitchen $kitchenId');
    try {
      print('deleteKitchen try $uid');

      await FirebaseFirestore.instance.collection('users').doc(uid).collection('kitchens').doc(kitchenId)
          .delete();

      _kitchenDeleted = true;
      kitchenName = '';
      // Handle any additional tasks after deleting the kitchen
    } catch (e) {
      print('deleteKitchen catch');

      print('Error deleting kitchen: $e');
      // Handle error gracefully
    }
  }

  Future<void> deleteTiffin(String tiffinId, int index) async {

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid)
          .collection('tiffins')
          .doc(tiffinId)
          .delete();

      setState(() {
        _tiffins.removeAt(index);

      });
      // Handle any additional tasks after deleting the tiffin
    } catch (e) {
      print('Error deleting tiffin: $e');
      // Handle error gracefully
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String kitchenId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this kitchen?'),
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
                deleteKitchen(kitchenId).then((value) =>
                {
                  setState(() {

                  })
                });

                Navigator.of(context).pop(); // Close dialog

              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteConfirmationDialogTiffin(BuildContext context, String tiffinId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this kitchen?'),
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
                deleteTiffin(tiffinId, index).then((value) =>
                {
                  setState(() {
                    _isLoading = false;

                  })
                });

                Navigator.of(context).pop(); // Close dialog

              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _kitchenDeleted
          ? null
          : kitchenName.isNotEmpty
              ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
                  title: Text(
                    kitchenName,
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () => {
                        _showDeleteConfirmationDialog(context, kitchenId)
                      },
                    ),
                  ],
                )
              : null,
      body: Column(children: [
        kitchenName.isNotEmpty
            ? Container(
                height: 150.0,
                decoration: BoxDecoration(
                  image: kitchenImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                              kitchenImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Container(),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _tiffins.length,
                  itemBuilder: (context, index) {
                    final tiffin = _tiffins[index];
                    return Dismissible(
                      key: Key(UniqueKey().toString()),
                      onDismissed: (direction) async {
                        // Delete tiffin here
                        _showDeleteConfirmationDialogTiffin(context, _tiffins[index].id!, index);

                      },
                      background: Container(
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                          tiffin.image!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  Text(
                                    tiffin.name!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${tiffin.price}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            {
                                              _showDeleteConfirmationDialogTiffin(context, _tiffins[index].id!, index)
                                            },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    tiffin.description!,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class Tiffin {
  int id;
  String name;
  String description;
  String image;
  String price;

  Tiffin(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.price});

  factory Tiffin.fromJson(Map<String, dynamic> json) {
    return Tiffin(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? 0.0,
    );
  }
}
