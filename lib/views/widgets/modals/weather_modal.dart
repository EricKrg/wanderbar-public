import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wanderbar/models/helper/weather_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:weather/weather.dart';

enum WeatherInput { online, manual }

class WeatherInfo {
  int temp;
  String code;
  String weather;
  String weatherIcon;

  WeatherInfo(this.temp, this.code, this.weather, this.weatherIcon);
}

class WeatherControl extends StatefulWidget {
  final Function(WeatherInfo weatherInfo) onFinished;
  final Position position;
  final DateTime recordDate;
  const WeatherControl(
      {Key key, this.onFinished, this.position, this.recordDate})
      : super(key: key);

  @override
  State<WeatherControl> createState() => _WeatherControlState();
}

class _WeatherControlState extends State<WeatherControl> {
  WeatherInfo weatherInfo;
  WeatherHelper weatherHelper = WeatherHelper();

  @override
  void initState() {
    super.initState();
    final first = weatherHelper.getAllWeatherStates().first;
    final initPreset = weatherHelper.getEntry(first);
    weatherInfo =
        WeatherInfo(12, first, initPreset.description, initPreset.iconPath);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              height: MediaQuery.of(context).size.height * 0.24,
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  WeatherTile(
                      recordDate: widget.recordDate,
                      weatherInfo: weatherInfo,
                      manualInput: true,
                      latLng: LatLng(
                          widget.position.latitude, widget.position.longitude)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 15),
                        child: IconButton(
                          onPressed: () {
                            print("add ${weatherInfo.weather}");
                            widget.onFinished(weatherInfo);
                          },
                          icon: Icon(Icons.add_circle_rounded),
                        ),
                      ),
                    ],
                  )
                ],
              ))
        ]);
  }
}

class WeatherTile extends StatefulWidget {
  final bool manualInput;
  final WeatherInfo weatherInfo;
  final LatLng latLng;
  final DateTime recordDate;

  const WeatherTile(
      {Key key,
      this.manualInput = false,
      this.weatherInfo,
      this.latLng,
      this.recordDate})
      : super(key: key);

  @override
  State<WeatherTile> createState() => WeatherTileState();
}

class WeatherTileState extends State<WeatherTile> {
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  WeatherInfo currentWeather;
  WeatherHelper weatherHelper = WeatherHelper();
  @override
  void initState() {
    super.initState();
    if (widget.manualInput && widget.latLng != null) {
      weatherHelper
          .getWeather(widget.latLng.latitude, widget.latLng.longitude)
          .then((value) {
        print("code ${value.weatherConditionCode}");
        print("desc ${value.weatherDescription}");
        print("temp ${value.temperature}");
        final WeatherPreset weatherPreset =
            weatherHelper.getWeatherInfoFromCode(value.weatherConditionCode);

        setState(() {
          currentWeather.temp = value.temperature.celsius.floor();
          currentWeather.weather = weatherPreset.description;
          currentWeather.weatherIcon = weatherPreset.iconPath;
          currentWeather.code =
              weatherHelper.getWeatherCode(value.weatherConditionCode);
        });
      });
    }
    currentWeather = widget.weatherInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Material(
            clipBehavior: Clip.antiAlias,
            color: AppColor.primary.withAlpha(200),
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.only(left: 12, right: 12, top: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatter.format(widget.recordDate),
                          style: TextStyle(
                              color: AppColor.whiteSoft,
                              fontFamily: 'inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          formatterTime.format(widget.recordDate),
                          style: TextStyle(
                              color: AppColor.whiteSoft,
                              fontFamily: 'inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        )
                      ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        getWeatherDetailModal();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 12, left: 12, bottom: 12),
                        width: 75,
                        height: 75,
                        child: SvgPicture.asset(
                          currentWeather.weatherIcon,
                          color: AppColor.whiteSoft,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                        ),
                      )),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () => getWeatherDetailModal(),
                          child: Container(
                              margin: EdgeInsets.all(12),
                              child: Text(
                                currentWeather.weather,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                style: TextStyle(
                                    color: AppColor.whiteSoft,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'inter'),
                              ))),
                      InkWell(
                          onTap: () {
                            if (!widget.manualInput) {
                              return;
                            }
                            this.getTempModal(currentWeather, context);
                          },
                          child: Container(
                              margin: EdgeInsets.all(12),
                              child: Text("${currentWeather.temp} °C",
                                  style: TextStyle(
                                      color: AppColor.whiteSoft,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'inter'))))
                    ],
                  )
                ],
              )
            ])));
  }

  void getWeatherDetailModal() {
    if (!widget.manualInput) {
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: AppColor.primary.withAlpha(200),
              content: getIconSelection(currentWeather, context));
        });
  }

  void getTempModal(WeatherInfo inputWeather, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                      padding: EdgeInsets.only(left: 50),
                      child: TempSelector(
                          inputTemp: inputWeather.temp,
                          onFinishedSelection: (value) {
                            setState(() {
                              inputWeather.temp = value;
                            });
                          }))));
        });
  }

  getIconSelection(WeatherInfo weatherInfo, BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width * .5,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: 2,
          ),
          itemCount: WeatherHelper.weather.length,
          itemBuilder: (context, index) {
            final selected = this.weatherHelper.getAllWeatherStates()[index];
            final infoSelected = this.weatherHelper.getEntry(selected);
            return new GestureDetector(
              onTap: () {
                weatherInfo.code = selected;
                weatherInfo.weatherIcon = infoSelected.iconPath;
                weatherInfo.weather = infoSelected.description;
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Column(children: [
                Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: SvgPicture.asset(
                        infoSelected.iconPath,
                        color: AppColor.whiteSoft,
                      ),
                    )),
                Text(
                  infoSelected.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                      color: AppColor.whiteSoft,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'inter'),
                )
              ]),
            );
          },
        ));
  }
}

class TempSelector extends StatefulWidget {
  final int inputTemp;
  final Function(int) onFinishedSelection;
  const TempSelector({Key key, this.inputTemp, this.onFinishedSelection})
      : super(key: key);
  @override
  _TempSelectorState createState() => _TempSelectorState();
}

class _TempSelectorState extends State<TempSelector> {
  int _currentValue = 3;

  @override
  void initState() {
    super.initState();
    this._currentValue = widget.inputTemp;
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      NumberPicker(
          itemCount: 9,
          value: _currentValue,
          minValue: -30,
          maxValue: 60,
          haptics: true,
          itemHeight: 60,
          axis: Axis.vertical,
          selectedTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'inter',
              color: Colors.white),
          textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              fontFamily: 'inter',
              color: Colors.white),
          onChanged: (value) {
            setState(() {
              _currentValue = value;
            });
            widget.onFinishedSelection(value);
          }),
      Text("°C",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'inter',
              color: Colors.white))
    ]);
  }
}
