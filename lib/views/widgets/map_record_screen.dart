import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/audio_log_tile%20.dart';
import 'package:wanderbar/views/widgets/compass.dart';
import 'package:wanderbar/views/widgets/geolocation_log_tile.dart';
import 'package:wanderbar/views/widgets/photo_log_tile%20.dart';
import 'package:wanderbar/views/widgets/quick_log_tile.dart';
import 'package:wanderbar/views/widgets/text_log_tile.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:math' as math;

import 'package:permission_handler/permission_handler.dart';

class MapRecordScreen extends StatefulWidget {
  final Position position;
  const MapRecordScreen({Key key, this.position}) : super(key: key);

  @override
  _MapRecordScreenState createState() => _MapRecordScreenState();
}

class _MapRecordScreenState extends State<MapRecordScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            child: FlutterMap(
                options: new MapOptions(
                  interactiveFlags: InteractiveFlag.none,
                  center: LatLng(
                      widget.position.latitude, widget.position.longitude),
                  zoom: 12.0,
                ),
                layers: [
                  TileLayerOptions(
                      tileProvider: const CachedTileProvider(),
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        point: LatLng(widget.position.latitude,
                            widget.position.longitude),
                        builder: (ctx) => Icon(
                          Icons.location_pin,
                          color: AppColor.primary,
                          size: 35.0,
                        ),
                      ),
                    ],
                  ),
                ]),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5));
  }
}

class MapPositionStream extends StatefulWidget {
  final Function(QuickLogEntry) onFinishedRecording;

  const MapPositionStream({Key key, this.onFinishedRecording})
      : super(key: key);

  @override
  _MapPositionStreamState createState() => _MapPositionStreamState();
}

class _MapPositionStreamState extends State<MapPositionStream> {
  MapController mapController;
  TextEditingController titelController = TextEditingController();
  bool _hasPermissions = false;
  Position currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    LocationPermission permission;
    Geolocator.requestPermission();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    mapController = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: GeolocatorPlatform.instance.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 0)),
        builder: (context, AsyncSnapshot<Position> snapshot) {
          if (!snapshot.hasData)
            return CircularProgressIndicator();
          else {
            if (mapController != null) {
              mapController.move(
                  LatLng(snapshot.data.latitude, snapshot.data.longitude), 18);
            }
            currentPosition = snapshot.data;

            return Container(
              child: Stack(alignment: Alignment.center, children: [
                FlutterMap(
                    options: new MapOptions(
                        interactiveFlags: InteractiveFlag.pinchZoom,
                        center: LatLng(
                            snapshot.data.latitude, snapshot.data.longitude),
                        zoom: 18.0,
                        onMapCreated: (controller) {
                          mapController = controller;
                          FlutterCompass.events.listen((event) {
                            mapController.rotate(event.heading * -1);
                          });
                        }),
                    layers: [
                      TileLayerOptions(
                          tileProvider: const CachedTileProvider(),
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                          subdomains: ['a', 'b', 'c']),
                      MarkerLayerOptions(markers: [
                        Marker(
                            point: LatLng(snapshot.data.latitude,
                                snapshot.data.longitude),
                            builder: (context) {
                              return Compass(
                                asMapMarker: true,
                              );
                            })
                      ]),
                      CircleLayerOptions(circles: [
                        CircleMarker(
                            point: LatLng(snapshot.data.latitude,
                                snapshot.data.longitude),
                            color: AppColor.primarySoft.withOpacity(0.5),
                            borderColor: AppColor.primary,
                            borderStrokeWidth: 1,
                            useRadiusInMeter: true,
                            radius: snapshot.data.accuracy // 2000 meters | 2 km

                            )
                      ])
                    ]),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Compass(
                            onBearingChange: (double bearing) {
                              currentPosition = Position(
                                  longitude: snapshot.data.longitude,
                                  latitude: snapshot.data.latitude,
                                  timestamp: snapshot.data.timestamp,
                                  accuracy: snapshot.data.accuracy,
                                  altitude: snapshot.data.altitude,
                                  heading: bearing,
                                  speed: snapshot.data.speed,
                                  speedAccuracy: snapshot.data.speedAccuracy);
                            },
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  alignment: Alignment.bottomLeft,
                                  child: getPositionInfo(
                                      label: "Lat",
                                      value: snapshot.data.latitude,
                                      fixedPlaces: 4)),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  alignment: Alignment.bottomLeft,
                                  child: getPositionInfo(
                                      label: "Long",
                                      value: snapshot.data.longitude,
                                      fixedPlaces: 4)),
                            ],
                          ),
                          getTitelWidget(titelController),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 8, bottom: 16),
                            alignment: Alignment.bottomLeft,
                            child: getPositionInfo(
                                label: "Speed",
                                value: snapshot.data.speed == -1
                                    ? 0.0
                                    : snapshot.data.speed.roundToDouble())),
                        Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: AppColor.whiteSoft,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                                padding: EdgeInsets.all(2),
                                onPressed: () {
                                  widget.onFinishedRecording(QuickLogEntry(
                                      content: "",
                                      entryType: QuickLogType.geolocation,
                                      position: currentPosition,
                                      recordDate: currentPosition.timestamp,
                                      titel: titelController != null
                                          ? titelController.text
                                          : null));
                                },
                                icon: Icon(Icons.add_circle_outline_rounded))),
                        Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: AppColor.whiteSoft,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                                color: AppColor.warn,
                                padding: EdgeInsets.all(2),
                                onPressed: () {},
                                icon:
                                    Icon(Icons.radio_button_checked_rounded))),
                        Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.only(right: 8, bottom: 16),
                            child: getPositionInfo(
                                label: "Altitude",
                                value: snapshot.data.altitude.roundToDouble()))
                      ],
                    )
                  ],
                )
              ]),
            );
          }
        });
  }

  Widget getTitelWidget(TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 4, top: 2, left: 16),
      child: TextField(
          textAlign: TextAlign.start,
          controller: controller,
          autocorrect: true,
          style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter'),
          cursorColor: AppColor.primary,
          obscureText: false,
          minLines: 1,
          maxLines: 1,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(16),
            hintText: "Titel",
            hintStyle: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'inter'),
            border: InputBorder.none,
          )),
    );
  }
}

class MapDetailStatic extends StatelessWidget {
  final Position position;
  final bool noMap;
  const MapDetailStatic({Key key, this.position, this.noMap = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("build static map");
    return Container(
      child: Stack(alignment: Alignment.center, children: [
        if (!noMap)
          FlutterMap(
              key: ValueKey(key),
              options: new MapOptions(
                  allowPanningOnScrollingParent: true,
                  interactiveFlags: InteractiveFlag.none,
                  center: LatLng(position.latitude, position.longitude),
                  zoom: 16.0),
              layers: [
                TileLayerOptions(
                    key: ValueKey(key),
                    tileProvider: const CachedTileProvider(),
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(markers: [
                  Marker(
                      point: LatLng(position.latitude, position.longitude),
                      builder: (context) {
                        return Compass(
                            asMapMarker: true,
                            isStatic: true,
                            bearing: position.heading);
                      })
                ]),
                CircleLayerOptions(circles: [
                  CircleMarker(
                      point: LatLng(position.latitude, position.longitude),
                      color: AppColor.primarySoft.withOpacity(0.5),
                      borderColor: AppColor.primary,
                      borderStrokeWidth: 1,
                      useRadiusInMeter: true,
                      radius: position.accuracy // 2000 meters | 2 km
                      )
                ])
              ]),
        Column(
          mainAxisSize: this.noMap ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Compass(bearing: position.heading, isStatic: true),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.bottomLeft,
                          child: getPositionInfo(
                              label: "Lat",
                              value: position.latitude,
                              fixedPlaces: 4)),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.bottomLeft,
                          child: getPositionInfo(
                              label: "Long",
                              value: position.longitude,
                              fixedPlaces: 4)),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
                // make it scrollable
                child: Container(
              color: Colors.transparent,
            )),
            Container(
              margin: EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: Alignment.bottomLeft,
                      child: getPositionInfo(
                          label: "Speed",
                          value: position.speed == -1
                              ? 0
                              : position.speed.roundToDouble())),
                  Container(
                      alignment: Alignment.bottomLeft,
                      child: getPositionInfo(
                          label: "Altitude",
                          value: position.altitude.roundToDouble()))
                ],
              ),
            ),
          ],
        )
      ]),
    );
  }
}

Widget getPositionInfo({String label, double value, int fixedPlaces = 0}) {
  return Container(
      decoration: BoxDecoration(
          color: AppColor.whiteSoft, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label: ",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  fontFamily: 'inter')),
          Text(
            value.toStringAsFixed(fixedPlaces),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                fontFamily: 'inter'),
          ),
        ],
      ));
}

class SimpleMapScreen extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final bool noLabels;
  const SimpleMapScreen({Key key, this.center, this.zoom, this.noLabels = true})
      : super(key: key);

  @override
  _SimpleMapScreenState createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  @override
  void initState() {
    print("init simple map");
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SimpleMapScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print("did update simple map");
    if (widget.center != null) {
      _mapController.move(widget.center, widget.zoom);
    }
  }

  MapController _mapController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            child: FlutterMap(
                options: new MapOptions(
                  interactiveFlags: InteractiveFlag.none,
                  center: widget.center,
                  zoom: widget.zoom,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                layers: [
                  TileLayerOptions(
                      tileProvider: const CachedTileProvider(),
                      urlTemplate: widget.noLabels
                          ? "https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png"
                          : "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                      subdomains: ['a', 'b', 'c']),
                ]),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height));
  }
}

class AllQuickLogsScreen extends StatefulWidget {
  final List<DocumentReference> docRefs;
  final bool showAllQuicklogs;
  final bool showQuickLogCarousel;
  final bool isFullScreen;
  final bool showCenterBtn;
  final bool interactive;
  final bool isTrip;
  const AllQuickLogsScreen(
      {Key key,
      this.docRefs,
      this.showAllQuicklogs,
      this.isFullScreen,
      this.showCenterBtn = true,
      this.interactive = true,
      this.isTrip = false,
      this.showQuickLogCarousel})
      : super(key: key);

  @override
  _AllQuickLogsScreenState createState() => _AllQuickLogsScreenState();
}

class _AllQuickLogsScreenState extends State<AllQuickLogsScreen> {
  final CarouselController carouselController = CarouselController();
  QuickLog _currentQuicklog;
  int _currentIndex = 0;
  List<QuickLogEntry> entries = [];
  QuickLogEntry _selectedEntry;
  MapController _mapController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AllQuickLogsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Update trip map ${widget.isTrip}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTrip) {
      return getAllEntriesOnMap(widget.docRefs);
    }
    if (widget.docRefs.isEmpty) {
      print("empty refs");
      return getStreamBuilderAllQuicklogs();
    } else {
      return getStreamBuilderSelectionQuicklogs();
    }
  }

  getStreamBuilderAllQuicklogs() {
    return StreamBuilder(
        stream: QuickLogHelper.instance
            .getQuickLogsAsStream(FirebaseAuth.instance.currentUser),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Text("Loading...");

          if (!widget.showAllQuicklogs) {
            return getMainWidget([]);
          }

          var res = snapshot.data.docs.map((docSnapshot) {
            return QuickLog.fromJson(docSnapshot.data());
          }).toList();
          if (res.isNotEmpty) {
            _currentQuicklog = res.first;
          }

          return getMainWidget(res);
        });
  }

  getStreamBuilderSelectionQuicklogs() {
    return StreamBuilder(
        stream: QuickLogHelper.instance
            .getQuickLogSelectionAsStream(widget.docRefs),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (!snapshot.hasData) return Text("Loading...");

          var res = snapshot.data.map((element) {
            return QuickLog.fromJson(element.data());
          }).toList();
          if (res.isNotEmpty) _currentQuicklog = res.first;
          return getMainWidget(res);
        });
  }

  getAllEntriesOnMap(List<DocumentReference> entryRefs) {
    if (entryRefs.isEmpty) {
      return FlutterMap(
          options: new MapOptions(
            allowPanning: false,
            interactiveFlags: widget.interactive
                ? InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom
                : InteractiveFlag.none,
            allowPanningOnScrollingParent: false,
            center: getCurrentCenter([]),
            zoom: getZoomLvl([]),
            plugins: [
              MarkerClusterPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
                tileProvider: const CachedTileProvider(),
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                subdomains: ['a', 'b', 'c']),
            MarkerClusterLayerOptions(
              maxClusterRadius: 60,
              size: Size(40, 40),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: [],
              polygonOptions: PolygonOptions(
                  borderColor: AppColor.primary,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              builder: (context, markers) {
                return FloatingActionButton(
                  key: UniqueKey(),
                  heroTag: UniqueKey(),
                  shape: StadiumBorder(
                      side: BorderSide(color: AppColor.primary, width: 4)),
                  backgroundColor: AppColor.whiteSoft,
                  child: Text(markers.length.toString(),
                      style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter')),
                  onPressed: null,
                );
              },
            ),
          ]);
    } else {
      return StreamBuilder(
        stream: QuickLogHelper.instance.getQuickLogSelectionAsStream(entryRefs),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) return Text("Loading...");

          List<QuickLogEntry> allTripEntries = [];
          if (snapshot.data != null) {
            snapshot.data.forEach((element) {
              final ql = QuickLog.fromJson(element.data());
              allTripEntries.addAll(ql.entries);
            });
          }

          return FlutterMap(
              options: new MapOptions(
                allowPanning: false,
                interactiveFlags: widget.interactive
                    ? InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom
                    : InteractiveFlag.none,
                allowPanningOnScrollingParent: false,
                center: getCurrentCenter(allTripEntries),
                onMapCreated: (controller) {
                  QuickLogHelper.instance
                      .getQuickLogSelectionAsStream(entryRefs)
                      .listen((event) {
                    controller.move(getCurrentCenter(allTripEntries),
                        getZoomLvl(allTripEntries));
                  });
                },
                zoom: getZoomLvl(allTripEntries),
                plugins: [
                  MarkerClusterPlugin(),
                ],
              ),
              layers: [
                TileLayerOptions(
                    tileProvider: const CachedTileProvider(),
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                    subdomains: ['a', 'b', 'c']),
                MarkerClusterLayerOptions(
                  zoomToBoundsOnClick: true,
                  maxClusterRadius: 60,
                  size: Size(40, 40),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: allTripEntries.isNotEmpty
                      ? buildMarkers(allTripEntries)
                      : [],
                  polygonOptions: PolygonOptions(
                      borderColor: AppColor.primary,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      key: UniqueKey(),
                      heroTag: UniqueKey(),
                      shape: StadiumBorder(
                          side: BorderSide(color: AppColor.primary, width: 4)),
                      backgroundColor: AppColor.whiteSoft,
                      child: Text(markers.length.toString(),
                          style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter')),
                      onPressed: null,
                    );
                  },
                ),
              ]);
        },
      );
    }
  }

  getMainWidget(List<QuickLog> quicklogs) {
    return Stack(alignment: AlignmentDirectional.topCenter, children: [
      Container(
          child: FlutterMap(
              options: new MapOptions(
                allowPanning: false,
                interactiveFlags: widget.interactive
                    ? InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom
                    : InteractiveFlag.none,
                allowPanningOnScrollingParent: false,
                center: _currentQuicklog == null
                    ? getCurrentCenter([])
                    : getCurrentCenter(_currentQuicklog.entries),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                zoom: _currentQuicklog == null
                    ? getZoomLvl([])
                    : getZoomLvl(_currentQuicklog.entries),
                plugins: [
                  MarkerClusterPlugin(),
                ],
              ),
              layers: [
                TileLayerOptions(
                    tileProvider: const CachedTileProvider(),
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png",
                    subdomains: ['a', 'b', 'c']),
                CircleLayerOptions(
                    circles: _currentQuicklog != null
                        ? buildCircleMarker(quicklogs[_currentIndex].entries)
                        : []),
                MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: Size(40, 40),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: _currentQuicklog != null
                      ? buildMarkers(quicklogs[_currentIndex].entries)
                      : [],
                  polygonOptions: PolygonOptions(
                      borderColor: AppColor.primary,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      key: UniqueKey(),
                      heroTag: UniqueKey(),
                      shape: StadiumBorder(
                          side: BorderSide(color: AppColor.primary, width: 4)),
                      backgroundColor: AppColor.whiteSoft,
                      child: Text(markers.length.toString(),
                          style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter')),
                      onPressed: null,
                    );
                  },
                ),
              ]),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height),
      if (widget.showCenterBtn)
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8, bottom: 8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.primaryExtraSoft.withAlpha(50),
                          width: 2),
                      color: AppColor.whiteSoft,
                      borderRadius: BorderRadius.circular(10)),
                  child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(5),
                      child: IconButton(
                          splashColor: AppColor.primaryExtraSoft,
                          splashRadius: 20,
                          padding: EdgeInsets.all(4),
                          enableFeedback: true,
                          constraints: BoxConstraints(),
                          onPressed: () => _mapController.move(
                              getCurrentCenter(
                                  quicklogs[_currentIndex].entries),
                              getZoomLvl(quicklogs[_currentIndex].entries)),
                          icon: Icon(Icons.center_focus_strong))),
                )
              ],
            ),
          ],
        ),
      if (quicklogs != null && widget.showQuickLogCarousel)
        createQuickLogCarouselFromList(quicklogs),
      // createQuickLogCarouselFromStream(),
      if (_selectedEntry != null) getSelectedEntryWidget()
    ]);
  }

  getSelectedEntryWidget() {
    return Container(
        key: UniqueKey(),
        margin: widget.isFullScreen
            ? EdgeInsets.only(bottom: 120)
            : EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _mapController.move(getCurrentCenter([_selectedEntry]),
                          getZoomByAccuracy(_selectedEntry.position.accuracy));
                    },
                    child: Icon(Icons.zoom_in_rounded,
                        color: Colors.white, size: 16),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(side: BorderSide.none),
                      padding: EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      primary: Colors.grey, // <-- Button color
                      onPrimary: AppColor.primarySoft, // <-- Splash color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedEntry = null;
                      });
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 15),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(side: BorderSide.none),
                      padding: EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      primary: Colors.grey, // <-- Button color
                      onPrimary: AppColor.primarySoft, // <-- Splash color
                    ),
                  ),
                ]),
            getLogEntryWidget(_selectedEntry),
          ],
        ));
  }

  createQuickLogCarouselFromList(List<QuickLog> quickLogs) {
    var quickLogList = [];
    var res = quickLogs.map((ql) {
      quickLogList.add(ql);
      return Container(
          key: UniqueKey(),
          margin: EdgeInsets.symmetric(horizontal: 3),
          child: QuickLogTile(data: ql));
    }).toList();
    return Container(
        margin: widget.isFullScreen
            ? EdgeInsets.only(top: 50)
            : EdgeInsets.only(top: 15),
        child: CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
              enableInfiniteScroll: false,
              height: 100,
              initialPage: 0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentQuicklog = quickLogList[index];
                  print("${_currentQuicklog.titel}");
                  _currentIndex = index;
                  _selectedEntry = null;
                });
                _mapController.move(getCurrentCenter(_currentQuicklog.entries),
                    getZoomLvl(_currentQuicklog.entries));
              },
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              disableCenter: true,
              scrollPhysics: BouncingScrollPhysics()),
          items: res,
        ));
  }

  createQuickLogCarouselFromStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: QuickLogHelper.instance
          .getQuickLogsAsStream(FirebaseAuth.instance.currentUser),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        List<QuickLog> quickLogList = [];
        var res = snapshot.data.docs.map((docSnapshot) {
          var ql = QuickLog.fromJson(docSnapshot.data());
          quickLogList.add(ql);
          return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: QuickLogTile(data: ql));
        }).toList();

        _currentQuicklog = quickLogList.first;

        return this.createQuickLogCarouselFromList(quickLogList);
      },
    );
  }

  buildCircleMarker(List<QuickLogEntry> ql) {
    final res = ql.map(
      (element) {
        var isEntrySelected = false;
        if (_selectedEntry != null) {
          isEntrySelected = _selectedEntry.content == element.content;
        }
        if (element.position != null && isEntrySelected)
          return CircleMarker(
              point:
                  LatLng(element.position.latitude, element.position.longitude),
              color: AppColor.primarySoft.withOpacity(0.4),
              borderColor: AppColor.primary,
              borderStrokeWidth: 1,
              useRadiusInMeter: true,
              radius: element.position.accuracy // 2000 meters | 2 km
              );
      },
    ).toList();

    return res.whereType<CircleMarker>().toList();
  }

  buildMarkers(List<QuickLogEntry> ql) {
    var res = ql.map((element) {
      if (element.position != null) {
        return Marker(
            point:
                LatLng(element.position.latitude, element.position.longitude),
            builder: (ctx) {
              if (element.entryType == QuickLogType.geolocation) {
                return GestureDetector(
                  child: Compass(
                      asMapMarker: true,
                      isStatic: true,
                      bearing: element.position.heading),
                  onTap: () {
                    print("tap");
                    setState(() {
                      _selectedEntry = element;
                    });
                  },
                );
              } else {
                return GestureDetector(
                  child: getIconsForLogType(element),
                  onTap: () {
                    print("tap");
                    setState(() {
                      _selectedEntry = element;
                    });
                  },
                );
              }
            });
      }
    }).toList();
    return res.whereType<Marker>().toList();
  }

  Icon getIconsForLogType(QuickLogEntry entry) {
    var isEntrySelected = false;
    if (_selectedEntry != null) {
      isEntrySelected = _selectedEntry.content == entry.content;
    }
    switch (entry.entryType) {
      case QuickLogType.audio:
        return Icon(
          Icons.audio_file,
          color: isEntrySelected ? AppColor.warn : AppColor.primary,
          size: isEntrySelected ? 45 : 35.0,
        );
        break;
      case QuickLogType.text:
        return Icon(
          Icons.text_fields_rounded,
          color: isEntrySelected ? AppColor.warn : AppColor.primary,
          size: isEntrySelected ? 45 : 35.0,
        );
        break;
      case QuickLogType.photo:
        return Icon(
          Icons.photo,
          color: isEntrySelected ? AppColor.warn : AppColor.primary,
          size: isEntrySelected ? 45 : 35.0,
        );
        break;
      case QuickLogType.geolocation:
        return Icon(
          Icons.location_on_rounded,
          color: isEntrySelected ? AppColor.warn : AppColor.primary,
          size: isEntrySelected ? 45 : 35.0,
        );
        break;

      default:
        return Icon(
          Icons.location_on_rounded,
          color: isEntrySelected ? AppColor.warn : AppColor.primary,
          size: isEntrySelected ? 45 : 35.0,
        );
    }
  }

  Widget getLogEntryWidget(QuickLogEntry entry) {
    switch (entry.entryType) {
      case QuickLogType.photo:
        //print("URL ${entry.content}");
        return Container(
          child: SimplePhotoLogTile(data: entry),
          padding: EdgeInsets.all(10),
        );
        break;
      case QuickLogType.text:
        return TextLogTile(data: entry);
        break;
      case QuickLogType.audio:
        return AudioLogTile(entry: entry);
      case QuickLogType.geolocation:
        return GeolocationLogTile(data: entry, noMap: true);
      default:
    }
  }
}

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

void getbottomModalMap(
    BuildContext context, List<DocumentReference> docRefs, showQLCarousel) {
  showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (c) {
        return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            physics: BouncingScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: AllQuickLogsScreen(
                    docRefs: docRefs,
                    isFullScreen: false,
                    showAllQuicklogs: false,
                    showQuickLogCarousel: showQLCarousel,
                  ))
            ]);
      });
}

LatLng getCurrentCenter(List<QuickLogEntry> input) {
  var center;
  // if (input is QuickLog) {
  if (input.length == 0) {
    // if the currentQuicklog has no entries
    return LatLng(50.98, 11.33);
  }
  var count = 0;
  var absLat = 0.0;
  var absLon = 0.0;

  input.forEach((element) {
    if (element.position != null) {
      absLat = absLat + element.position.latitude;
      absLon = absLon + element.position.longitude;
      count = count + 1;
    }
  });
  center = LatLng(absLat / count, absLon / count);
  return center;
}

double getZoomByAccuracy(double accuracy) {
  print("Accuracy $accuracy");
  if (accuracy < 10) {
    return 18;
  } else if (accuracy > 10 && accuracy < 100) {
    return 16;
  } else if (accuracy > 100 && accuracy < 1000) {
    return 14;
  } else if (accuracy > 1000 && accuracy < 3000) {
    return 13;
  } else {
    return 12;
  }
}

double getZoomLvl(List<QuickLogEntry> entries) {
  if (entries.isEmpty) {
    return 12;
  }

  if (entries.length > 0) {
    var maxDist = 0.0;
    var dist = 0.0;
    entries.forEach((j) {
      entries.forEach((i) {
        if (i.position != null && j.position != null) {
          dist = calculateDistance(j.position.latitude, j.position.longitude,
              i.position.latitude, i.position.longitude);
        }
        if (dist > maxDist) maxDist = dist;
      });
    });
    if (maxDist < 10) {
      return 12;
    } else if (maxDist > 10 && maxDist < 30) {
      return 10;
    } else if (maxDist > 30 && maxDist < 100) {
      return 8;
    } else if (maxDist > 100 && maxDist < 250) {
      return 6;
    } else {
      return 4;
    }
  } else {
    return 12;
  }
}
