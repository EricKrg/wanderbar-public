import 'package:flutter/material.dart';

class AppColor {
  static Color warn = hexToColor("#FA0D51");
  static Color primary = hexToColor("#7B92A6");
  static Color primarySoft = hexToColor("#DFF0F2");
  static Color primaryExtraSoft = hexToColor("#EAF2DF");
  static Color primaryExtraSofter = hexToColor("#BDD69A");
  static Color secondary = hexToColor("#F2DEA0");

  static Color secondaryShade = hexToColor("#EAE6B9");
  static Color secondaryShadeDark = hexToColor("#FCD797");
  static Color secondaryDarker = hexToColor("#FFC282");

  static Color whiteSoft = Color(0xFFF8F8F8);
  static LinearGradient qlBagckground = LinearGradient(
      colors: [AppColor.primary, AppColor.primaryExtraSoft],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft);

  static LinearGradient bgMultiColor = LinearGradient(
      colors: [
        hexToColor("#FAF6EF"),
        hexToColor("#EAF2DF"),
        hexToColor("#F2EADA"),
        hexToColor("#D5E8EB"),
        primary
      ],
      tileMode: TileMode.mirror,
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);

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

class AnimatedGradient extends StatefulWidget {
  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient> {
  Future<dynamic> timer;
  List<Color> colorList = [
    //AppColor.secondaryDarker,
    AppColor.primarySoft,
    AppColor.secondaryShadeDark,
    AppColor.primaryExtraSoft,
    //AppColor.primaryExtraSofter,
    AppColor.secondaryShade,
    // AppColor.primary
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = AppColor.secondary;
  Color topColor = AppColor.secondaryShade;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  void initState() {
    print("init animation background");
    timer = Future.delayed(Duration(seconds: 2)).then((value) {
      if (this.mounted)
        setState(() {
          print("set bottom color");
          bottomColor = AppColor.whiteSoft;
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 5),
          onEnd: () {
            setState(() {
              index = index + 1;
              // animate the color
              bottomColor = colorList[index % colorList.length];
              topColor = colorList[(index + 1) % colorList.length];

              //// animate the alignment
              begin = alignmentList[index % alignmentList.length];
              end = alignmentList[(index + 2) % alignmentList.length];
            });
          },
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, colors: [bottomColor, topColor])),
        )
      ],
    ));
  }
}
