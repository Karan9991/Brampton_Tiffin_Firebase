import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class BannerDisplay extends StatefulWidget {
  @override
  _BannerDisplayState createState() => _BannerDisplayState();
}

class _BannerDisplayState extends State<BannerDisplay> {
  List<String> _banners = [];

  @override
  void initState() {
    super.initState();
   // _fetchBanners();
  }

  Future<List<String>> _fetchBanners() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('banners').get();
      List<String> bannerUrls = [];
      for (var doc in snapshot.docs) {
        List<dynamic> urls = doc['imageUrls'];
        bannerUrls.addAll(urls.map((url) => url.toString()).toList());
      }
      return bannerUrls;
    } catch (e) {
      print('Error fetching banners: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          _banners = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            height: 200,
            child: CarouselSlider.builder(
              itemCount: _banners.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Container(
                  margin: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(_banners[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 180.0,
               autoPlay: true,
                enlargeCenterPage: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
            ),
          );
        } else {
          return Center(child: Text('No banners available'));
        }
      },
    );
  }
  // Widget build(BuildContext context) {
  //   return Container(
  //     height: 100,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _banners.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Container(
  //           margin: EdgeInsets.symmetric(horizontal: 10),
  //           child: Image.network(_banners[index]),
  //         );
  //       },
  //     ),
  //   );
  // }
}

//
// Future<void> _fetchBanners() async {
//   var response = await http.get(Uri.parse(Constants.banners));
//
//   if (response.statusCode == 200) {
//     var data = jsonDecode(response.body)['data'];
//     var bannerUrls = <String>[];
//     for (var banner in data) {
//       bannerUrls.add(Constants.BASE_URL_without_API+'public/banners/' + banner['image']);
//     }
//     setState(() {
//       _banners = bannerUrls;
//     });
//   } else {
//     throw Exception('Failed to fetch banners');
//   }
// }