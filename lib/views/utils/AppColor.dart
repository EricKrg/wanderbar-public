import 'package:flutter/material.dart';

class AppColor {
  static Color warn = hexToColor("#FA0D51");
  static Color primary = hexToColor("#7B92A6");
  static Color primarySoft = hexToColor("#DFF0F2");
  static Color primaryExtraSoft = hexToColor("#EAF2DF");
  static Color secondary = Color(0xFFEDE5CC);
  static Color whiteSoft = Color(0xFFF8F8F8);
  static LinearGradient qlBagckground = LinearGradient(
      colors: [AppColor.primary, AppColor.primaryExtraSoft],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft);

  static LinearGradient bgMultiColor = LinearGradient(colors: [
    hexToColor("#FAF6EF"),
    hexToColor("#F2EADA"),
    hexToColor("#D5E8EB"),
    primary
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

  static LinearGradient bgSingleColor = LinearGradient(colors: [
    whiteSoft,
    primaryExtraSoft.withOpacity(0.5),
    primarySoft,
    primary.withOpacity(0.5),
    primary
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);
  static LinearGradient bottomShadow = LinearGradient(colors: [
    hexToColor("#4070DE").withOpacity(0.2),
    hexToColor("#4070DE").withOpacity(0)
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);
  static LinearGradient linearBlackBottom = LinearGradient(
      colors: [Colors.black.withOpacity(0.45), Colors.black.withOpacity(0)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter);
  static LinearGradient linearBlackTop = LinearGradient(
      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
// class AppColor {
//   static Color primary = Color(0xFF094542);
//   static Color primarySoft = Color(0xFF0B5551);
//   static Color primaryExtraSoft = Color(0xFFEEF4F4);
//   static Color secondary = Color(0xFFEDE5CC);
//   static Color whiteSoft = Color(0xFFF8F8F8);
//   static LinearGradient bottomShadow = LinearGradient(colors: [Color(0xFF107873).withOpacity(0.2), Color(0xFF107873).withOpacity(0)], begin: Alignment.bottomCenter, end: Alignment.topCenter);
//   static LinearGradient linearBlackBottom = LinearGradient(colors: [Colors.black.withOpacity(0.45), Colors.black.withOpacity(0)], begin: Alignment.bottomCenter, end: Alignment.topCenter);
//   static LinearGradient linearBlackTop = LinearGradient(colors: [Colors.black.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter);
// }