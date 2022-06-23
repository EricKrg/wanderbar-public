import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungry/views/screens/explore_page.dart';
import 'package:hungry/views/screens/home_page.dart';
import 'package:hungry/views/screens/newly_posted_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_bottom_navigation_bar.dart';

class PageSwitcher extends StatefulWidget {
  @override
  _PageSwitcherState createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher> {
  int _selectedIndex = 0;
  Position backupPos;

  Future<Widget> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        return HomePage();
        break;
      case 1:
        LocationPermission permission;
        Geolocator.requestPermission();
        backupPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        return ExplorePage(
          position: backupPos,
          docRefs: [],
        );
        break;
      case 2:
        return NewlyPostedPage();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          FutureBuilder(
              future: _onItemTapped(_selectedIndex),
              builder: (builder, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else {
                  return Text("Loading ...");
                }
              }),
          BottomGradientWidget(),
        ],
      ),
      bottomNavigationBar: SafeArea(
          child: CustomBottomNavigationBar(
              onItemTapped: _onItemTapped, selectedIndex: _selectedIndex)),
    );
  }

  getNavigationPage(int index) {}
}

class BottomGradientWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        decoration: BoxDecoration(gradient: AppColor.bottomShadow),
      ),
    );
  }
}
