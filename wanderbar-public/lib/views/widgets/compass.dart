import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:permission_handler/permission_handler.dart';

class Compass extends StatefulWidget {
  final bool isStatic;
  final double bearing;
  final bool asMapMarker;
  final MapController mapController;
  final Function(double) onBearingChange;

  const Compass(
      {Key key,
      this.asMapMarker = false,
      this.onBearingChange,
      this.isStatic = false,
      this.mapController,
      this.bearing = 0})
      : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _hasPermissions = false;
  double prevBearing = 0;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCompass();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildCompass() {
    if (widget.isStatic) {
      if (widget.asMapMarker) {
        return buildCompassMaker(widget.bearing);
      } else {
        return buildBearing(widget.bearing);
      }
    } else {
      return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error reading heading: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          double direction = snapshot.data.heading;

          // if direction is null, then device does not support this sensor
          // show error message
          if (direction == null)
            return Center(
              child: Text("Device does not have sensors !"),
            );
          if (widget.onBearingChange != null) {
            widget.onBearingChange(direction);
          }

          if (widget.asMapMarker) {
            return buildCompassMaker(direction);
          } else {
            final change = (direction - this.prevBearing).abs();
            if (change > 1) {
              HapticFeedback.selectionClick();
              this.prevBearing = direction;
            }
            return buildBearing(direction);
          }
        },
      );
    }
  }

  buildCompassMaker(double bearing) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Transform.rotate(
            angle: (bearing * (math.pi / 180)),
            child: Stack(
              children: [
                Icon(
                  Icons.navigation_rounded,
                  color: AppColor.primary,
                  size: 25.0,
                ),
              ],
            )));
  }

  buildBearing(double bearing) {
    return Container(
        decoration: BoxDecoration(
            color: AppColor.whiteSoft, borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(convertBearing(bearing - 10).round().toString(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'inter')),
            Text(convertBearing(bearing - 5).round().toString(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'inter')),
            Text(
              bearing.round().toString(),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  fontFamily: 'inter'),
            ),
            Text(convertBearing(bearing + 5).round().toString(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'inter')),
            Text(convertBearing(bearing + 10).round().toString(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'inter')),
          ],
        ));
  }

  double convertBearing(double bearing) {
    if (bearing > 360) {
      return bearing - 360;
    } else if (bearing < 0) {
      return bearing + 360;
    }
    return bearing;
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
