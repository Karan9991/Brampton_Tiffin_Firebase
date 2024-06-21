import 'package:flutter/material.dart';
import 'package:tiffin/models/publishTiffin.dart';
import 'package:tiffin/models/tiffin.dart';
import 'package:tiffin/util/app_constants.dart';

class ViewTiffin extends StatelessWidget {
  final PublishTiffin tiffin;
  ViewTiffin({required this.tiffin});

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Tiffin Details',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: MediaQuery.of(context).size.height -
            appBar.preferredSize.height -
            MediaQuery.of(context).padding.top,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                          tiffin.image!,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tiffin.name!,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Divider(color: Colors.grey),
                    Text(
                      '\$${tiffin.price}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Divider(color: Colors.grey),
                    SizedBox(height: 16.0),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: SingleChildScrollView(
                        child: Text(
                          tiffin.description!,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         'Tiffin Details',
  //         style: TextStyle(
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //     body: Container(
  //       height: 500,
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Expanded(
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(8.0),
  //                 image: DecorationImage(
  //                   image: NetworkImage(
  //                     Constants.BASE_URL_without_API +
  //                         'storage/tiffinrecipes/' +
  //                         tiffin.image,
  //                   ),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(height: 16.0),
  //           Card(
  //             elevation: 4.0,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //             child: Container(
  //               padding: EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   Text(
  //                     tiffin.name,
  //                     style: TextStyle(
  //                       fontSize: 24.0,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   SizedBox(height: 8.0),
  //                   Divider(color: Colors.grey),
  //                   Text(
  //                     '\$${tiffin.price}',
  //                     style: TextStyle(
  //                       fontSize: 20.0,
  //                       fontWeight: FontWeight.bold,
  //                       color: Theme.of(context).primaryColor,
  //                     ),
  //                   ),
  //                   SizedBox(height: 16.0),
  //                   Divider(color: Colors.grey),
  //                   SizedBox(height: 16.0),
  //                   SingleChildScrollView(
  //                       child: Text(
  //                         tiffin.description,
  //                         style: TextStyle(
  //                           fontSize: 16.0,
  //                         ),
  //                       ),
  //                     ),
  //                   SizedBox(height: 16.0),
  //                 ],
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
