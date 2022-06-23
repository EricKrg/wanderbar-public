import 'package:flutter/material.dart';
import 'package:hungry/views/utils/AppColor.dart';

class UserInfoTile extends StatelessWidget {
  final String label, value;
  final EdgeInsetsGeometry margin, padding;
  final Color valueBackground;
  final Widget textWidget;
  UserInfoTile(
      {@required this.label,
      @required this.value,
      this.padding,
      this.margin,
      this.valueBackground,
      this.textWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('$label',
                style: TextStyle(color: AppColor.primary, fontSize: 12)),
          ),
          Container(
              margin: EdgeInsets.only(top: 6),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              color: valueBackground ?? AppColor.primaryExtraSoft,
              child: this.textWidget)
        ],
      ),
    );
  }
}
