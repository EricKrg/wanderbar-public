import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/screens/trip_screen.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:latlong2/latlong.dart';

class FeaturedRecipeCard extends StatelessWidget {
  final UserTripCollection data;
  final Trip inputTrip;
  QuickLogHelper quickLogHelper = QuickLogHelper.instance;
  FeaturedRecipeCard({this.data, this.inputTrip});

  @override
  Widget build(BuildContext context) {
    if (inputTrip != null) {
      return creatTripCollection(this.inputTrip, context);
    }
    return creatTripCollectionFromStream(data.trip.path, context);
  }

  creatTripCollectionFromStream(String docPath, BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: quickLogHelper.getTripAsStream(docPath),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return new Text('Loading...');
        final trip = Trip.fromJson(snapshot.data.data());
        return creatTripCollection(trip, context);
      },
    );
  }

  creatTripCollection(Trip trip, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TripPage(data: trip)));
      },
      // Card Wrapper
      child: Container(
          width: 180,
          height: 220,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          // Recipe Card Info
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AllQuickLogsScreen(
                  docRefs: trip.quickLogs,
                  isFullScreen: true,
                  showAllQuicklogs: false,
                  showCenterBtn: false,
                  interactive: false,
                  isTrip: true,
                  showQuickLogCarousel: false),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TripPage(data: trip)));
                },
              ),
              Container(
                  margin: EdgeInsets.all(8),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black.withOpacity(0.26),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe Title
                            Text(
                              trip.titel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 150 / 100,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'inter'),
                            ),
                            // Recipe Calories and Time
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.people,
                                      size: 12, color: Colors.white),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "${trip.sharedWith.length}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.list,
                                      size: 12, color: Colors.white),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "${trip.quickLogs.length}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
