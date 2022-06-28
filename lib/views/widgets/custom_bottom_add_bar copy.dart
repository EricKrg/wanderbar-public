import 'package:flutter/material.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

// ignore: must_be_immutable
class CustomBottomAddNavigationBar extends StatefulWidget {
  Function onItemTapped;
  CustomBottomAddNavigationBar({@required this.onItemTapped});

  @override
  _CustomBottomAddNavigationBarState createState() =>
      _CustomBottomAddNavigationBarState();
}

class _CustomBottomAddNavigationBarState
    extends State<CustomBottomAddNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox(
      height: 85,
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: widget.onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded,
                  color: AppColor.primary, size: 18),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_fields, color: AppColor.primary, size: 18),
              label: ''),
          BottomNavigationBarItem(
              icon:
                  Icon(Icons.keyboard_voice, color: AppColor.primary, size: 18),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_location_rounded,
                  color: AppColor.primary, size: 18),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_rounded,
                  color: AppColor.primary, size: 18),
              label: ''),
        ],
      ),
    ));
  }
}
