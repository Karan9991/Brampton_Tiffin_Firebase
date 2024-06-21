// import 'package:flutter/material.dart';
// import 'package:tiffin/util/images.dart';
// import 'package:flutter/material.dart';
// import 'package:tiffin/util/images.dart';
// import 'package:http/http.dart' as http;
// import 'package:tiffin/util/app_constants.dart';
//
// import 'package:flutter/material.dart';
// import 'package:tiffin/util/images.dart';
//
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:tiffin/util/app_constants.dart';
//
// import 'dart:convert';
//
// import 'package:tiffin/viewtiffins/tiffindescription.dart';
//
// class TiffinImage {
//   final int id;
//   final String image;
//   final String name;
//   final int price;
//   final int userId;
//
//   TiffinImage({
//     required this.id,
//     required this.image,
//     required this.name,
//     required this.price,
//     required this.userId,
//   });
//
//   factory TiffinImage.fromJson(Map<String, dynamic> json) {
//     return TiffinImage(
//       id: json['id'],
//       image: json['image'],
//       name: json['name'],
//     price: int.parse(json['price']), // Parse the 'price' field as an int
//       userId: int.parse(json['user_id']),
//     );
//   }
// }
//
// class TiffinImagesList {
//   final List<TiffinImage> bannerImages;
//
//   TiffinImagesList({
//     required this.bannerImages,
//   });
//
//   factory TiffinImagesList.fromJson(List<dynamic> json) {
//     List<TiffinImage> bannerImages = [];
//     bannerImages = json.map((i) => TiffinImage.fromJson(i)).toList();
//     return TiffinImagesList(bannerImages: bannerImages);
//   }
// }
//
// class Tiffins extends StatefulWidget {
//   final String searchQuery;
//
//   const Tiffins({Key? key, required this.searchQuery}) : super(key: key);
//
//   @override
//   _TiffinsState createState() => _TiffinsState();
// }
//
// class _TiffinsState extends State<Tiffins> {
//   late Future<TiffinImagesList> futureBannerImages;
//
//   @override
//   void initState() {
//     super.initState();
//     futureBannerImages = fetchBannerImages();
//   }
//
//   Future<TiffinImagesList> fetchBannerImages() async {
//     final response = await http.get(Uri.parse(Constants.tiffinrecipes));
//
//     if (response.statusCode == 200) {
//       return TiffinImagesList.fromJson(jsonDecode(response.body)['data']);
//     } else {
//       throw Exception('Failed to load banner images');
//     }
//   }
//
//   void navigateToChatScreen(int userIdd) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TiffinDescription(
//           userId: userIdd,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<TiffinImagesList>(
//         future: futureBannerImages,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             List<TiffinImage> filteredTiffins = snapshot.data!.bannerImages
//                 .where((tiffin) => tiffin.name
//                     .toLowerCase()
//                     .contains(widget.searchQuery.toLowerCase()))
//                 .toList();
//
//             return SizedBox(
//               height: MediaQuery.of(context).size.height,
//               child: GridView.count(
//                 childAspectRatio: 0.88,
//                 physics: NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2,
//                 shrinkWrap: true,
//                 children: [
//                   for (int i = 0; i < filteredTiffins.length; i++)
//                     GestureDetector(
//                       onTap: () {
//                         navigateToChatScreen(filteredTiffins[i].userId);
//                       },
//                       child: SizedBox(
//                         height: 250, // Fixed height value
//                         child: Container(
//                           padding: EdgeInsets.only(left: 0, right: 0, top: 10),
//                           margin: EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize
//                                 .min, // Set mainAxisSize to MainAxisSize.min
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 child: Image.network(
//                                   Constants.BASE_URL_without_API +
//                                       'public/tiffinrecipes/' +
//                                       filteredTiffins[i].image,
//                                   height: 100,
//                                   width: 130,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               Text(
//                                 filteredTiffins[i].name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Text(
//                                     "\$${filteredTiffins[i].price}",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Theme.of(context).primaryColor,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text('${snapshot.error}'));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         });
//   }
// }






import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiffin/models/createKitchen.dart';
import 'package:tiffin/viewtiffins/tiffindescription.dart';

// class TiffinImage {
//   final String? id;
//   final String? image;
//   final String? name;
//   final int? price;
//   final String? description;
//
//   TiffinImage({
//      this.id,
//      this.image,
//      this.name,
//      this.price,
//      this.description,
//   });
//
//   factory TiffinImage.fromJson(String id, Map<String, dynamic> json) {
//     return TiffinImage(
//       id: id,
//       image: json['image'],
//       name: json['name'],
//       price: json['price'],
//       description: json['description'],
//     );
//   }
// }
class TiffinImage {
  final String? id;  // Make id nullable
  final String image;
  final String name;
  final int price;
  final String description;

  TiffinImage({
    this.id,  // Make id optional
    required this.image,
    required this.name,
    required this.price,
    required this.description,
  });

  factory TiffinImage.fromJson(Map<String, dynamic> json, {String? id}) {
    return TiffinImage(
      id: id,  // id can be null or provided
      image: json['image'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
    );
  }
}

class TiffinImagesList {
  final List<TiffinImage> bannerImages;

  TiffinImagesList({
    required this.bannerImages,
  });

  factory TiffinImagesList.fromJson(List<dynamic> json) {
    List<TiffinImage> bannerImages = [];
    bannerImages = json.map((i) => TiffinImage.fromJson(i)).toList();
    return TiffinImagesList(bannerImages: bannerImages);
  }
}

class Tiffins extends StatefulWidget {
  final String searchQuery;

  const Tiffins({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _TiffinsState createState() => _TiffinsState();
}

class _TiffinsState extends State<Tiffins> {
  late Future<TiffinImagesList> fetchTiffins;
  List<String> userIds = [];

  @override
  void initState() {
    super.initState();
    fetchTiffins = fetchBannerImage();
   // fetchBannerImage();

    //getUserIdByTiffinId('T80obYCBkEc82uSLxWsy');

  }



  Future<TiffinImagesList> fetchBannerImage() async {
    try {
      // Get all user documents
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();

      // Initialize an empty list to store all tiffins
      List<TiffinImage> tiffinImages = [];
      List<CreateKitchen> kitchens = [];

      // Iterate through each user document
      for (var userDoc in userSnapshot.docs) {
        // Get the tiffins sub-collection for each user
      //  print('iddddddddds ${userDoc.id}');
        userIds.add(userDoc.id);
        QuerySnapshot tiffinSnapshot = await userDoc.reference.collection('tiffins').get();
        QuerySnapshot kitchenSnapshot = await userDoc.reference.collection('kitchens').get();

        // Add each kitchen to the list
        kitchens.addAll(kitchenSnapshot.docs.map((doc) {
        //  print('dataaaaaa kitchen ${doc.data()}');
          return CreateKitchen.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList());

        // Add each tiffin to the list
        tiffinImages.addAll(tiffinSnapshot.docs.map((doc) {
        //  print('dataaaaaa tiffin ${doc.data()}');
          return TiffinImage.fromJson(doc.data() as Map<String, dynamic>,id: doc.id);
        }).toList());
      }

      // Return the list of tiffin images
      return TiffinImagesList(bannerImages: tiffinImages);
    } catch (e) {
      throw Exception('Failed to load tiffin images: $e');
    }
  }


  void navigateToChatScreen(String tiffinId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TiffinDescription(
          tiffinId: tiffinId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TiffinImagesList>(
        future: fetchTiffins,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<TiffinImage> filteredTiffins = snapshot.data!.bannerImages
                .where((tiffin) => tiffin.name!
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()))
                .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: GridView.count(
                childAspectRatio: 0.88,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                children: [
                  for (int i = 0; i < filteredTiffins.length; i++)
                    GestureDetector(
                      onTap: () {
                        navigateToChatScreen(filteredTiffins[i].id!);
                      },
                      child: SizedBox(
                        height: 250, // Fixed height value
                        child: Container(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 10),
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  filteredTiffins[i].image!,
                                  height: 100,
                                  width: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                filteredTiffins[i].name!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "\$${filteredTiffins[i].price}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
