import 'package:flutter/material.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

class InfoContainer extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;

  const InfoContainer({Key key, this.title, this.subTitle, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon),
            Text(
              this.title,
              style: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.w600),
            ),
            Text(
              this.subTitle,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
    );
  }
}
