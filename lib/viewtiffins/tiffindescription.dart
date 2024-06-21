import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiffin/models/createKitchen.dart';
import 'package:tiffin/models/publishTiffin.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/viewtiffins/viewtiffindescription.dart';
import 'package:tiffin/models/tiffin.dart';

class TiffinDescription extends StatefulWidget {
  final String tiffinId;
  TiffinDescription({required this.tiffinId});

  @override
  _TiffinDescriptionState createState() => _TiffinDescriptionState();
}

class _TiffinDescriptionState extends State<TiffinDescription> {
  late List<PublishTiffin> _tiffins = [];
  bool _isLoading = true;
  bool _kitchenDeleted = false;

  String kitchenName = '';
  String kitchenImage = '';
  String kitchenId = '';
  String uid = '';



  @override
  void initState() {
    super.initState();
    _isLoading = true;

    _getData();
  }

  Future<void> _getData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;

    _getTiffins();
  }

  Future<String?> getUserIdByTiffinId(String tiffinId) async {
    try {
      // Get all user documents
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        // Get all tiffins for the current user
        QuerySnapshot tiffinsSnapshot = await userDoc.reference.collection('tiffins').get();

        for (var tiffinDoc in tiffinsSnapshot.docs) {
          if (tiffinDoc.id == tiffinId) {
            // Return the user ID if the tiffinId matches
            print('usreidddd ${userDoc.id}');

            return userDoc.id;
          }
        }
      }

      print('No tiffin found with the given tiffinId');
      return null;
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }

  Future<void> _getTiffins() async {
    try {

     //String uid  = FirebaseAuth.instance.currentUser!.uid;
      String? uid  = await getUserIdByTiffinId(widget.tiffinId);

      List<CreateKitchen> kit = await getKitchens(uid!);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _kitchenDeleted
          ? null
          : kitchenName.isNotEmpty
              ? AppBar(
        backgroundColor: Theme.of(context).primaryColor,
                  title: Text(
                    kitchenName,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  actions: [],
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTiffin(tiffin: tiffin),
                          ),
                        );
                      },
                      child: Dismissible(
                        key: Key(tiffin.id.toString()),
                        onDismissed: (direction) async {
                          // Delete tiffin here
                          setState(() {
                            _tiffins.removeAt(index);
                          });
                        },
                        background: Container(
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                //  child: Icon(Icons.delete, color: Colors.white),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                //  child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                //child: Icon(Icons.delete, color: Colors.white),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                //child: Icon(Icons.delete, color: Colors.white),
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
                                        _tiffins[index].image!),
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
                                      _tiffins[index].name!,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      _tiffins[index].description!,
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
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
