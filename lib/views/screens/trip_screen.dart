import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/models/helper/asset_helper.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/screens/page_switcher.dart';
import 'package:wanderbar/views/screens/quicklog_detail_page.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/info_container.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:wanderbar/views/widgets/quick_log_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wanderbar/views/widgets/user_card.dart';

class TripPage extends StatefulWidget {
  final Trip data;

  double photoHeight;
  TripPage({@required this.data});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  QuickLogHelper quickLogHelper = QuickLogHelper.instance;

  TextEditingController _titleController;

  Stream tripContent;
  Stream allQuickLogs;

  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.titel);
    this.tripContent =
        quickLogHelper.getTripfromPath("/trips/${widget.data.id}");

    this.allQuickLogs =
        quickLogHelper.getQuickLogsAsStream(FirebaseAuth.instance.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.primary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          getTripDeleteBtn(),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                          child: AlertDialog(
                              backgroundColor: Colors.white,
                              insetPadding: EdgeInsets.all(0),
                              content: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Use this code to share the trip: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w200),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Share.share(
                                            "Join my Trip ${widget.data.id}",
                                            subject: widget.data.id);
                                      },
                                      child: Text(
                                        widget.data.id,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              )));
                    });
              },
              icon: Icon(Icons.ios_share_rounded, color: AppColor.primary)),
          IconButton(
              onPressed: () {
                getbottomModalMap(context, widget.data.quickLogs, true);
              },
              icon: Icon(Icons.map_rounded, color: AppColor.primary)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          key: UniqueKey(),
          heroTag: UniqueKey(),
          mini: true,
          enableFeedback: true,
          backgroundColor: Colors.black.withOpacity(0.2),
          child: ClipRect(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
            ),
          )),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: AlertDialog(
                          // elevation: 0,
                          contentPadding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          content: Container(
                            // margin: EdgeInsets.zero,
                            // padding: EdgeInsets.zero,
                            width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height * 0.6,
                            child: createQuickLogTilesFromStream(),
                          ),
                          actions: [
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.only(bottom: 50),
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: GestureDetector(
                                      onTap: () async {
                                        QuickLog newQl = QuickLog(
                                            description: "",
                                            recordDate: DateTime.now(),
                                            entries: [],
                                            photo: AssetHelper
                                                .getRandomIconAsset(),
                                            titel: "");
                                        await quickLogHelper.addQuickLog(
                                            FirebaseAuth.instance.currentUser,
                                            newQl);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    QuickLogDetailPage(
                                                        key: UniqueKey(),
                                                        data: newQl)));
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_box_outlined,
                                                  color: AppColor.whiteSoft),
                                              Text('Create a new Log',
                                                  style: TextStyle(
                                                      fontFamily: 'inter',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColor.whiteSoft)),
                                            ],
                                          )
                                        ],
                                      ))),
                            ),
                          ]));
                });
          }),
      extendBody: true,
      body: getTripContent(),
    );
  }

  getTripContent() {
    return StreamBuilder<DocumentSnapshot>(
        stream: this.tripContent,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');

          Trip trip;
          try {
            trip = Trip.fromJson(snapshot.data.data());
          } catch (e) {
            return Center(child: Text("Could not resolve trip data"));
          }
          return Stack(alignment: Alignment.topCenter, children: [
            // background map
            Container(
              child: AllQuickLogsScreen(
                  docRefs: trip.quickLogs,
                  isTrip: true,
                  interactive: false,
                  showQuickLogCarousel: false,
                  showCenterBtn: false),
            ),
            // blur
            ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                    ))),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: (trip.quickLogs.length == 0)
                    ? InfoContainer(
                        icon: Icons.golf_course_rounded,
                        title: "No logs added yet!",
                        subTitle:
                            "Try adding some existing Logs, or create a new Log in order to at them to this Trip.",
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                            Padding(padding: EdgeInsets.only(top: 100)),
                            getTitelWidget(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTripOwner(trip),
                                  getAllEditors(trip)
                                ]),
                            Expanded(
                                child: ListView.separated(
                                    padding: EdgeInsets.only(bottom: 20),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: trip.quickLogs.length,
                                    physics: BouncingScrollPhysics(),
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 4);
                                    },
                                    itemBuilder: (context, index) {
                                      return createTripQuickLogTilesFromStream(
                                          trip.quickLogs[index], trip);
                                    }))
                          ]))
          ]);
        });
  }

  createTripQuickLogTilesFromStream(DocumentReference tripQuickLog, Trip trip) {
    return StreamBuilder<DocumentSnapshot>(
      stream: tripQuickLog.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        if (snapshot.hasError) {
          print(snapshot.error);
          return Text("Error loading this tile");
        } else {
          if (snapshot.data.data() == null) {
            return Text("This tile was probably removed!");
          }
          final res = QuickLog.fromJson(snapshot.data.data());
          return Dismissible(
            key: UniqueKey(),
            child: QuickLogTile(data: res),
            background: Container(
              child: Icon(Icons.remove_circle_rounded, color: AppColor.warn),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30),
            ),
            secondaryBackground: Container(
              child: Icon(Icons.remove_circle_rounded, color: AppColor.warn),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 30),
            ),
            onDismissed: (direction) async {
              trip.quickLogs.remove(res.selfRef);
              setState(() {
                widget.data.quickLogs = trip.quickLogs;
              });
              try {
                await quickLogHelper.updateTrip(trip);
              } catch (e) {
                print(e);
              }
            },
          );
        }
      },
    );
  }

  createQuickLogTilesFromStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: this.allQuickLogs,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        var res = snapshot.data.docs.map((docSnapshot) {
          final ql = QuickLog.fromJson(docSnapshot.data());
          if (!widget.data.quickLogs.contains(ql.selfRef)) {
            return ql;
          }
        }).toList();
        res = res.where((element) => element != null).toList();
        if (res.length == 0) {
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
                  Text(
                    "No more Logs to add!",
                    style: TextStyle(
                        color: Colors.grey[800], fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "You can create a new log with the button below and add it to this trip.",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: res.length,
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(height: 16);
          },
          itemBuilder: (context, index) {
            return Dismissible(
              key: UniqueKey(),
              child: QuickLogTile(data: res[index]),
              background: Container(
                child: Icon(Icons.add_circle, color: AppColor.primaryExtraSoft),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
              ),
              secondaryBackground: Container(
                child: Icon(Icons.add_circle, color: AppColor.primaryExtraSoft),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
              ),
              onDismissed: (direction) async {
                setState(() {
                  widget.data.quickLogs.add(res[index].selfRef);
                });

                quickLogHelper.updateTrip(widget.data);
                res.removeAt(index);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Widget getAllEditors(Trip trip) {
    return StreamBuilder(
        stream: QuickLogHelper.instance.getUsersStreams(trip.sharedWith),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData) return Text("Loading...");
          if (snapshot.hasData) {
            List<UserSimple> editors = snapshot.data
                .map((e) => UserSimple.fromJson(e.data()))
                .toList();

            return Container(
                height: 100,
                child: ListView.separated(
                  itemCount: editors.length,
                  // padding: EdgeInsets.symmetric(horizontal: 16),
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: 10,
                    );
                  },
                  itemBuilder: (context, index) {
                    return UserCard(user: editors[index]);
                  },
                ));
          } else {
            return Container();
          }
        });
  }

  Widget getTripOwner(Trip trip) {
    return StreamBuilder(
        stream: trip.owner.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Text("Loading...");
          if (snapshot.hasData) {
            final owner = UserSimple.fromJson(snapshot.data.data());
            return UserCard(
              user: owner,
            );
          } else {
            return Container();
          }
        });
  }

  Widget getTitelWidget() {
    return Center(
        child: GestureDetector(
            onTap: () {},
            child: Container(
                margin: EdgeInsets.only(bottom: 2, top: 8),
                child: Focus(
                  onFocusChange: ((value) {
                    widget.data.titel = _titleController.text.trim();
                    try {
                      QuickLogHelper.instance.updateTrip(widget.data);
                    } catch (e) {
                      print(e);
                    }
                  }),
                  child: TextField(
                      controller: _titleController,
                      autocorrect: true,
                      style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter'),
                      cursorColor: AppColor.primary,
                      obscureText: false,
                      minLines: 1,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Titel",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'inter'),
                        border: InputBorder.none,
                      )),
                ))));
  }

  getBgSelection(Trip trip) {
    return Container(
        width: MediaQuery.of(context).size.width * .9,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 5,
            mainAxisSpacing: 15,
            crossAxisCount: 1,
          ),
          itemCount: AssetHelper.bgAsset.length,
          itemBuilder: (context, index) {
            return new GestureDetector(
                onTap: () {
                  trip.photo = "${AssetHelper.bgAsset[index]}";
                  QuickLogHelper.instance.updateTrip(trip);
                  Navigator.of(context).pop();
                },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage("${AssetHelper.bgAsset[index]}"),
                          fit: BoxFit.fitHeight,
                        ))));
          },
        ));
  }

  Widget getTripDeleteBtn() {
    return FutureBuilder(
        future: QuickLogHelper.instance
            .canDeleteTrip(FirebaseAuth.instance.currentUser, widget.data),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data) {
            return IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: AlertDialog(
                                backgroundColor: Colors.white,
                                insetPadding: EdgeInsets.all(0),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Do you want to dissolve this Trip?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w200),
                                    ),
                                    Center(
                                        child: IconButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PageSwitcher()),
                                                (Route<dynamic> route) => false,
                                              );
                                              QuickLogHelper.instance
                                                  .deleteTrip(
                                                      FirebaseAuth
                                                          .instance.currentUser,
                                                      widget.data);
                                            },
                                            icon: Icon(
                                              Icons.delete_rounded,
                                              color: AppColor.warn,
                                            ))),
                                  ],
                                )));
                      });
                },
                icon: Icon(Icons.delete_rounded, color: AppColor.primary));
          }
          return Container();
        });
  }
}
