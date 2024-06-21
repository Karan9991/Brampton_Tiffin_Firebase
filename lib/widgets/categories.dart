import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiffin/util/images.dart';
import 'package:http/http.dart' as http;
import 'package:tiffin/util/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:tiffin/util/images.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tiffin/util/app_constants.dart';

import 'dart:convert';
//
// class CategoryImage {
//   final int id;
//   final String image;
//   final String name;
//
//   CategoryImage({
//     required this.id,
//     required this.image,
//     required this.name,
//   });
//
//   factory CategoryImage.fromJson(Map<String, dynamic> json) {
//     return CategoryImage(
//       id: json['id'],
//       image: json['image'],
//       name: json['name'],
//     );
//   }
// }
//
// class CategoryImagesList {
//   final List<CategoryImage> bannerImages;
//
//   CategoryImagesList({
//     required this.bannerImages,
//   });
//
//   factory CategoryImagesList.fromJson(List<dynamic> json) {
//     List<CategoryImage> bannerImages = [];
//     bannerImages = json.map((i) => CategoryImage.fromJson(i)).toList();
//     return CategoryImagesList(bannerImages: bannerImages);
//   }
// }
//
// class Categories extends StatefulWidget {
//   @override
//   _CategoriesState createState() => _CategoriesState();
// }
//
// class _CategoriesState extends State<Categories> {
//   late Future<CategoryImagesList> futureBannerImages;
//
//   @override
//   void initState() {
//     super.initState();
//     futureBannerImages = fetchBannerImages();
//   }
//
//   Future<CategoryImagesList> fetchBannerImages() async {
//     final response = await http.get(Uri.parse(Constants.categories));
//
//     if (response.statusCode == 200) {
//       return CategoryImagesList.fromJson(jsonDecode(response.body)['data']);
//     } else {
//       throw Exception('Failed to load banner images');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<CategoryImagesList>(
//       future: futureBannerImages,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 for (int i = 0; i < snapshot.data!.bannerImages.length; i++)
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: 10),
//                     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                           margin: EdgeInsets.symmetric(vertical: 5),
//                           child: Column(children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: Image.network(
//                                 Constants.BASE_URL_without_API +
//                                     'public/categories/' +
//                                     snapshot.data!.bannerImages[i].image,
//                                 width: 100,
//                                 height: 100,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.only(top: 7),
//                               child: Text(
//                                 snapshot.data!.bannerImages[i].name,
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey),
//                               ),
//                             ),
//                           ]),
//                         ),
//                       ],
//                     ),
//                   )
//               ],
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Text('${snapshot.error}');
//         }
//         // By default, show a loading spinner.
//         return CircularProgressIndicator();
//       },
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryImage {
  final String image;
  final String name;

  CategoryImage({
    required this.image,
    required this.name,
  });

  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
      image: json['imageUrl'],
      name: json['name'],
    );
  }
}

class CategoryImagesList {
  final List<CategoryImage> bannerImages;

  CategoryImagesList({
    required this.bannerImages,
  });

  factory CategoryImagesList.fromJson(List<dynamic> json) {
    List<CategoryImage> bannerImages = [];
    bannerImages = json.map((i) => CategoryImage.fromJson(i)).toList();
    return CategoryImagesList(bannerImages: bannerImages);
  }
}

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late Future<CategoryImagesList> futureBannerImages;

  @override
  void initState() {
    super.initState();
    futureBannerImages = fetchBannerImages();
  }

  Future<CategoryImagesList> fetchBannerImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
      List<CategoryImage> categoryImages = snapshot.docs.map((doc) {
        return CategoryImage.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return CategoryImagesList(bannerImages: categoryImages);
    } catch (e) {
      throw Exception('Failed to load banner images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CategoryImagesList>(
      future: futureBannerImages,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < snapshot.data!.bannerImages.length; i++)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Column(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                snapshot.data!.bannerImages[i].image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 7),
                              child: Text(
                                snapshot.data!.bannerImages[i].name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
