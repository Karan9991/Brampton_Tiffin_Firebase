import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UploadBannersScreen extends StatefulWidget {
  @override
  _UploadBannersScreenState createState() => _UploadBannersScreenState();
}

class _UploadBannersScreenState extends State<UploadBannersScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  bool _isLoading = false;

  Future<void> _browseAndUploadImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.length <= 5) {
        setState(() {
          _images = pickedFiles.map((file) => File(file.path)).toList();
        });

        await _uploadImagesToStorageAndFirestore();
      } else {
        // Show an error if more than 5 images are selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select exactly five images.'),
          ),
        );
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _uploadImagesToStorageAndFirestore() async {
    setState(() {
      _isLoading = true;
    });

    List<String> imageUrls = [];

    try {
      for (var image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('banners')
            .child(fileName);

        await storageReference.putFile(image);
        String downloadUrl = await storageReference.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      await FirebaseFirestore.instance.collection('banners').add({
        'imageUrls': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Images uploaded successfully.'),
        ),
      );
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _images = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Banners'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _browseAndUploadImages,
              child: Text('Select and Upload Images'),
            ),
            SizedBox(height: 20),
            _images.isNotEmpty
                ? Wrap(
              spacing: 10,
              children: _images
                  .map((image) => Image.file(
                image,
                width: 100,
                height: 100,
              ))
                  .toList(),
            )
                : Text('No images selected'),
          ],
        ),
      ),
    );
  }
}
