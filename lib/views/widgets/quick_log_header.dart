import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/asset_helper.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/map_record_screen.dart';
import 'package:intl/intl.dart';

class QuickLogDetailHeader extends StatefulWidget {
  final QuickLog data;
  final ScrollController scrollController;
  bool isEditing = false;
  bool showBackdrop = true;

  double photoHeight;
  QuickLogDetailHeader(
      {Key key,
      @required this.data,
      @required this.scrollController,
      @required this.photoHeight,
      @required this.isEditing});

  @override
  _QuickLogDetailHeaderState createState() => _QuickLogDetailHeaderState();
}

class _QuickLogDetailHeaderState extends State<QuickLogDetailHeader> {
  DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');

  TextEditingController _titleController;
  TextEditingController _descController;

  double iconPadding = 120;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.titel);
    _descController = TextEditingController(text: widget.data.description);

    widget.scrollController.addListener(() {
      changeAppBarColor(widget.scrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(content: getIconSelection(widget.data));
              });
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: new Duration(milliseconds: 200),
              //height: widget.photoHeight,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColor.primaryExtraSoft,
              ),
              child: AnimatedContainer(
                alignment: Alignment.bottomCenter,
                duration: new Duration(milliseconds: 200),
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: widget.photoHeight,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
                alignment: Alignment.bottomCenter,
                child: streamIconChange(widget.data))
          ],
        ),
      ),
      Stack(
        children: [
          AnimatedContainer(
              duration: new Duration(milliseconds: 200),
              child: ClipRect(
                  child: Visibility(
                      visible: widget.showBackdrop,
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: double.infinity,
                              //margin: EdgeInsets.only(top: -10),
                              decoration: BoxDecoration(
                                color: AppColor.whiteSoft.withAlpha(50),
                              )))))),
          AnimatedPadding(
              padding: EdgeInsets.only(bottom: 0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        color: AppColor.primaryExtraSoft),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list,
                                size: 16,
                                color: AppColor.primary.withAlpha(200)),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                widget.data.entries.length.toString(),
                                style: TextStyle(
                                    color: AppColor.primary.withAlpha(200),
                                    fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.date_range,
                                size: 16,
                                color: AppColor.primary.withAlpha(200)),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                formatter.format(widget.data.recordDate),
                                style: TextStyle(
                                    color: AppColor.primary.withAlpha(200),
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        // Log Title
                        getLogTitel(),
                        // Log Description
                        getLogDescription()
                      ],
                    )),
              )),
        ],
      )
    ]);
  }

  changeAppBarColor(ScrollController scrollController) {
    if (this.mounted) {
      if (scrollController.position.hasPixels) {
        // print("PX ${scrollController.position.pixels}");
        if (scrollController.position.pixels > 10.0) {
          setState(() {
            iconPadding = 0;
            widget.photoHeight = 20;
            widget.showBackdrop = false;
          });
        }
        if (scrollController.position.pixels <= -35.0) {
          setState(() {
            iconPadding = 120;
            widget.photoHeight = 300;
            widget.showBackdrop = true;
          });
        }
      }
    }
  }

  Widget getTextDisplay(
      String text,
      FocusNode focusNode,
      String title,
      bool deterimator,
      TextEditingController controller,
      TextStyle style,
      int textlines) {
    if (deterimator) {
      //controller.value.copyWith(text: text);
      //return CustomTextField(title: title, controller: controller);
      return TextField(
        focusNode: focusNode,
        controller: controller,
        autocorrect: true,
        style: style,
        cursorColor: Colors.black,
        obscureText: false,
        minLines: 1,
        maxLines: textlines,
        decoration: InputDecoration(
          hintText: '$title',
          hintStyle: style,
          border: InputBorder.none,
        ),
      );
    }
    text = text.isEmpty ? title : text;
    return Text(
      text,
      style: style,
    );
  }

  streamIconChange(QuickLog log) {
    return StreamBuilder<DocumentSnapshot>(
        stream: QuickLogHelper.instance.getQuickLogAsStream(log.selfRef),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return Container(
              child: AnimatedContainer(
            duration: new Duration(milliseconds: 200),
            height: widget.photoHeight,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Container(
                padding: EdgeInsets.only(top: iconPadding),
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  log.photo,
                  height: 200,
                )),
          ));
        });
  }

  getIconSelection(QuickLog log) {
    return Container(
        width: MediaQuery.of(context).size.width * .9,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            crossAxisCount: 3,
          ),
          itemCount: AssetHelper.iconAsset.length,
          itemBuilder: (context, index) {
            return new GestureDetector(
              onTap: () {
                print("tap");
                log.photo = "assets/icons/${AssetHelper.iconAsset[index]}";
                QuickLogHelper.instance.updateQuickLog(log.selfRef, log);
                Navigator.of(context).pop();
              },
              child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    child: SvgPicture.asset(
                        "assets/icons/${AssetHelper.iconAsset[index]}"),
                  )),
            );
          },
        ));
  }

  Widget getLogTitel() {
    return GestureDetector(
        onTap: () {
          setState(() {
            widget.isEditing = true;
          });
        },
        child: Container(
            //margin: EdgeInsets.only(bottom: 6, top: 8),
            child: Focus(
          onFocusChange: ((value) {
            widget.data.titel = _titleController.text.trim();
            try {
              QuickLogHelper.instance
                  .updateQuickLog(widget.data.selfRef, widget.data);
            } catch (e) {
              print(e);
            }
          }),
          child: TextField(
              textAlign: TextAlign.center,
              controller: _titleController,
              autocorrect: true,
              style: TextStyle(
                  color: AppColor.primary.withAlpha(200),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'inter'),
              cursorColor: Colors.black,
              obscureText: false,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Titel",
                hintStyle: TextStyle(
                    color: AppColor.primary.withAlpha(200),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
                border: InputBorder.none,
              )),
        )));
  }

  Widget getLogDescription() {
    return GestureDetector(
        onTap: () {
          setState(() {
            widget.isEditing = true;
          });
        },
        child: Container(
            margin: EdgeInsets.only(bottom: 4, top: 0),
            child: Focus(
              onFocusChange: ((value) {
                widget.data.description = _descController.text.trim();
                try {
                  QuickLogHelper.instance
                      .updateQuickLog(widget.data.selfRef, widget.data);
                } catch (e) {
                  print(e);
                }
              }),
              child: TextField(
                  textAlign: TextAlign.center,
                  controller: _descController,
                  autocorrect: true,
                  style: TextStyle(
                      color: AppColor.primary.withAlpha(200),
                      fontSize: 14,
                      height: 150 / 100),
                  cursorColor: Colors.black,
                  obscureText: false,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: TextStyle(
                        color: AppColor.primary.withAlpha(200),
                        fontSize: 14,
                        height: 150 / 100),
                    border: InputBorder.none,
                  )),
            )));
  }
}

class QuickLogDetailAppBarHeader extends StatefulWidget {
  final ScrollController scrollController;
  final QuickLog data;

  QuickLogDetailAppBarHeader(
      {Key key, @required this.scrollController, this.data});

  @override
  _QuickLogDetailAppBarHeaderState createState() =>
      _QuickLogDetailAppBarHeaderState();
}

class _QuickLogDetailAppBarHeaderState
    extends State<QuickLogDetailAppBarHeader> {
  Color appBarColor = Colors.transparent;
  Color iconcColor = AppColor.whiteSoft;
  String titel = "";

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      changeAppBarColor(widget.scrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarColor,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      title: Text(this.titel,
          style: TextStyle(
              fontFamily: "inter",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.primary)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: this.iconcColor),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
            onPressed: () {
              getbottomModalMap(context, [widget.data.selfRef], false);
            },
            icon: Icon(Icons.map_rounded),
            color: this.iconcColor)
      ],
    );
  }

  changeAppBarColor(ScrollController scrollController) {
    if (this.mounted) {
      if (scrollController.position.hasPixels) {
        if (scrollController.position.pixels > 10.0) {
          setState(() {
            this.appBarColor = AppColor.primaryExtraSoft;
            this.titel = widget.data.titel;
            this.iconcColor = AppColor.primary;
          });
        }
        if (scrollController.position.pixels <= -35.0) {
          setState(() {
            this.appBarColor = Colors.transparent;
            this.titel = "";
            this.iconcColor = AppColor.whiteSoft;
          });
        }
      }
    }
  }
}
