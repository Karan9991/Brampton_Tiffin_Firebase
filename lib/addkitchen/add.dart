import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:tiffin/addkitchen/createkitchen.dart';
import 'package:tiffin/addkitchen/createtiffin.dart';
import 'package:tiffin/viewtiffins/viewtiffins.dart';

class MyTabBarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Create Your Kitchen',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: TabBar(
                indicator: BubbleTabIndicator(
                  indicatorRadius: 10,
                  indicatorHeight: 40,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Create Kitchen'),
                  Tab(text: 'Publish Tiffin'),
                  Tab(text: 'View Tiffins'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            CreateKitchenPage(),
            CreateTiffinPage(),
            TiffinScreen(),
          ],
        ),
      ),
    );
  }
}
