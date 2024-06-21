import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tiffin/models/createKitchen.dart';
import 'package:tiffin/util/snackbar.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiffin/util/app_constants.dart';
import 'package:tiffin/util/shared_pref.dart';

class CreateKitchenPage extends StatefulWidget {
  const CreateKitchenPage({Key? key}) : super(key: key);

  @override
  _CreateKitchenPageState createState() => _CreateKitchenPageState();
}

class _CreateKitchenPageState extends State<CreateKitchenPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late File? _imageFile = null;
  int _currentUserId = 0;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String uid = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }



  Future<void> _createKitchen(String kitchenName, File bannerImage) async {
    print('Creating kitchen');
    setState(() {
      _loading =  true;
    });

    try {
      // Get current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;
      // Check if the user already has a kitchen
      bool hasKitchen = await _checkIfUserHasKitchen(uid);

      if (hasKitchen) {
        print('User already has a kitchen.');
        show(context, "You can't create more than one kitchen",
            isError: true);
        return; // Exit the method if the user already has a kitchen
      }
      // Upload kitchen banner to Firebase Storage
      print('Uploading banner image...');
      String bannerImageUrl = await _uploadBannerImage(bannerImage);
      print('Banner image uploaded successfully. URL: $bannerImageUrl');
      final kitchen = CreateKitchen(name: kitchenName, banner: bannerImageUrl).toJson();

      // Add kitchen data to Firestore
      print('Adding kitchen data to Firestore...');
      await _firestore.collection('users').doc(uid).collection('kitchens').add(kitchen);
      print('Kitchen data added to Firestore successfully');

      show(context, "Kitchen created successfully",
          isError: false);
      print('Kitchen created successfully');
    } catch (e) {
      print('Error creating kitchen: $e');
    }
  }
  Future<bool> _checkIfUserHasKitchen(String uid) async {
    try {
      QuerySnapshot kitchensSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('kitchens')
          .limit(1)
          .get();

      return kitchensSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has kitchen: $e');
      return false;
    }
  }

  Future<String> _uploadBannerImage(File imageFile) async {
    try {
      print('Starting upload of banner image...');
      // Generate a unique filename for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image to Firebase Storage
      final Reference storageReference =
      _storage.ref().child('kitchen_banners').child(fileName);
      await storageReference.putFile(imageFile);
      print('Banner image uploaded successfully.');

      // Get download URL of the uploaded image
      print('Getting download URL of the uploaded image...');
      String downloadURL = await storageReference.getDownloadURL();
      print('Download URL obtained: $downloadURL');

      return downloadURL;
    } catch (e) {
      print("Error uploading banner image: $e");
      rethrow;
    }
  }


  Future<List<dynamic>> fetchKitchenData(int userId) async {
    final String url = Constants.getkitchen;
    final Map<String, dynamic> queryParameters = {'user_id': userId};

    final Response response = await Dio().get(
      url,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final dynamic data = response.data;
      if (data != null && data.containsKey('data')) {
        return data['data'];
      } else {
        // Return an empty list if the response does not contain any kitchens
        return [];
      }
    } else {
      throw Exception('Failed to fetch kitchen data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor
                ),
                onPressed: _getImageFromGallery,
                icon: Icon(
                  Icons.image,
                  color: Colors.white,
                ),
                label: Text(
                  'Upload Kitchen Banner',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              if (_imageFile != null)
                SizedBox(
                  height: 200,
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: 'Kitchen Name',
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Kitchen Name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  if (_imageFile == null) {
                    show(context, "Please Upload Kitchen Banner",
                        isError: true);
                    return;
                  }

                  _createKitchen(_nameController.text,_imageFile!).then((value) => {

                    setState(() {
                      _loading = false;
                      _nameController.clear();
                      _imageFile = null;
                    })
                  });
                },
                child: Text(
                  'Create Kitchen',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              if (_loading)
                Center(
                  child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance;
     uid = user.currentUser!.uid;
     print('user iddddd $uid');
    // final Map<String, dynamic> user = await getUser();
    // setState(() {
    //   _currentUserId = user['id'];
    // });
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
