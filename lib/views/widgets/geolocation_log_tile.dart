import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:intl/intl.dart';

class GeolocationLogTile extends StatelessWidget {
  final QuickLogEntry data;
  final bool noMap;

  GeolocationLogTile({Key key, this.data, this.noMap = false})
      : super(key: key);

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    // final Position position = Position.fromMap(jsonDecode(data.position));
    return ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColor.whiteSoft,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatter.format(data.recordDate),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              formatterTime.format(data.recordDate),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ]),
                      if (data.titel != null && data.titel.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              data.titel,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                    ]),
                  ),
                  // useer review
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    height: noMap ? 140 : 240,
                    child: MapDetailStatic(
                        key: ValueKey(data.uuid),
                        position: data.position,
                        noMap: noMap),
                  )
                ],
              ),
            )));
  }
}

class SimpleGeolocationLogTile extends StatelessWidget {
  final Position data;

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  SimpleGeolocationLogTile({@required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.bottomLeft,
      // padding: EdgeInsets.all(16),
      //margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      // Recipe Card Info
      child: Stack(
          alignment: Alignment.bottomLeft,
          children: [MapRecordScreen(position: data)]),
    ));
  }
}
