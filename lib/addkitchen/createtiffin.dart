import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiffin/models/publishTiffin.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';
import 'package:tiffin/util/snackbar.dart';

class CreateTiffinPage extends StatefulWidget {
  const CreateTiffinPage({Key? key}) : super(key: key);

  @override
  _CreateTiffinPageState createState() => _CreateTiffinPageState();
}

class _CreateTiffinPageState extends State<CreateTiffinPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  final _nameFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  int _currentUserId = 0;

  late File? _image = null;
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String uid = '';
  bool _loading = false;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  focusNode: _nameFocus,
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Tiffin Name',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tiffin name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0, // adjust the height to your desired padding
                ),
                TextFormField(
                  focusNode: _priceFocus,
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3)
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Price',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tiffin price';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0, // adjust the height to your desired padding
                ),
                TextFormField(
                  focusNode: _descriptionFocus,
                  controller: _descriptionController,
                  maxLines: 15,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(fontSize: 15.0),
                    hintText:
                        'Description:\n \nDelicious homemade vegetarian tiffin made with fresh ingredients and spices.\nCustomizable tiffin with options for vegan, gluten-free...\n\nContact:\n \nEmail: example@gmail.com\nPhone: +1-555-1234-567\nWhatsApp: +1-555-1234-567 (preferred)\nInstagram: @example_tiffin\nFacebook: Example Tiffin Services',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tiffin description';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0, // adjust the height to your desired padding
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: _image == null
                      ? Text('No image selected.')
                      : SizedBox(
                          height: 130,
                          width: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor
                      ),
                      onPressed: getImage,
                      child: Text(
                        "Select Tiffin Image",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Send data to server using Dio
                        _createTiffin().then((value) => {
                          setState(() {
                            _loading = false;
                          })
                        });
                      }
                    },
                    child: Text(
                      'Publish Tiffin',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if(_loading)
                  Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createTiffin() async {
    print('Creating Tiffin');
    setState(() {
      _loading =  true;
    });

    try {
      // Get current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;
     // Check if the user already has three tiffins
      bool hasThreeTiffin = await _checkIfUserHasThreeTiffins(uid);
      print('booololl $hasThreeTiffin');

      if (!hasThreeTiffin) {
        print('User already has three tiffin.');
        show(context, "You can't publish more than three tiffins",
            isError: true);
        return; // Exit the method if the user already has a kitchen
      }
      // Upload kitchen banner to Firebase Storage
      print('Uploading image...');
      String imageUrl = await _uploadImage(_image!);
      print('Banner image uploaded successfully. URL: $imageUrl');
      final tiffin = PublishTiffin(name: _nameController.text,
          price: int.tryParse(_priceController.text), description: _descriptionController.text,
      image: imageUrl).toJson();

      // Add kitchen data to Firestore
      print('Adding kitchen data to Firestore...');
      await _firestore.collection('users').doc(uid).collection('tiffins').add(tiffin);
      print('Kitchen data added to Firestore successfully');
            setState(() {
              _nameController.text = '';
              _priceController.text = '';
              _descriptionController.text = '';
              _image = null;
              _nameFocus.unfocus;
              _priceFocus.unfocus;
              _descriptionFocus.unfocus;
            });
      show(context, "Tiffin created successfully",
          isError: false);
      print('Tiffin created successfully');
    } catch (e) {
      print('Error creating Tiffin: $e');
    }
  }


  Future<bool> _checkIfUserHasThreeTiffins(String uid) async {
    try {
      QuerySnapshot tiffinsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tiffins')
          .get();
      print('sizeeeeee ${tiffinsSnapshot.size}');

      return tiffinsSnapshot.size < 3;
    } catch (e) {
      print('Error checking if user has enough kitchens: $e');
      return false;
    }
  }


  Future<String> _uploadImage(File imageFile) async {
    try {
      print('Starting upload of banner image...');
      // Generate a unique filename for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image to Firebase Storage
      final Reference storageReference =
      _storage.ref().child('tiffins').child(fileName);
      await storageReference.putFile(imageFile);
      print('Image uploaded successfully.');

      // Get download URL of the uploaded image
      print('Getting download URL of the uploaded image...');
      String downloadURL = await storageReference.getDownloadURL();
      print('Download URL obtained: $downloadURL');

      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
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
      'email': SharedPrefHelper.getString('email') ?? '',
      'userType': SharedPrefHelper.getString('userType') ?? '',
      'token': SharedPrefHelper.getString('token') ?? '',
    };
  }
}
