import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/custom_bottom_add_bar%20copy.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:wanderbar/views/widgets/quick_log_header.dart';
import 'package:wanderbar/views/widgets/quicklogentry_tile.dart';
import 'package:wanderbar/views/widgets/record_audio_screen.dart';
import 'package:wanderbar/views/widgets/take_picture_screen.dart';
import 'package:wanderbar/views/widgets/text_log_tile.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class QuickLogDetailPage extends StatefulWidget {
  final QuickLog data;
  QuickLogDetailPage({Key key, @required this.data});

  @override
  _QuickLogDetailPageState createState() => _QuickLogDetailPageState();
}

class _QuickLogDetailPageState extends State<QuickLogDetailPage>
    with TickerProviderStateMixin {
  ScrollController _scrollController;

  QuickLogHelper quickLogHelper = QuickLogHelper.instance;

  bool isEditing = false;

  List<QuickLogEntry> logEntries;

  double photoHeight = 300;

  Stream<QuickLog> quickLogStream;
  QuickLog currentQuickLog;

  TextEditingController _textController = TextEditingController();

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');

  @override
  void dispose() {
    super.dispose();
    print("dispose ql detail");
  }

  @override
  void didUpdateWidget(covariant QuickLogDetailPage oldWidget) {
    print("DID UPDATE");
    super.didUpdateWidget(oldWidget);
    setState(() {
      quickLogStream = widget.data.selfRef
          .snapshots()
          .map((event) => QuickLog.fromJson(event.data()));
    });
  }

  @override
  void initState() {
    print("init quicklog detail");
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    super.initState();
    currentQuickLog = widget.data;
    quickLogStream = widget.data.selfRef
        .snapshots()
        .map((event) => QuickLog.fromJson(event.data()));
  }

  _onItemTapped(int index) async {
    LocationPermission permission;
    final recordDate = DateTime.now();
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    switch (index) {
      // photo
      case 0:
        final List<XFile> imageResults = await showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            builder: (context) {
              return TakePictureScreen(isMulti: true);
            });

        List<Map<String, IfdTag>> exifs = [];

        if (imageResults == null || imageResults.isEmpty) {
          return;
        }
        await Future.forEach(imageResults, (file) async {
          exifs.add(await readExifFromBytes(await file.readAsBytes()));
        });

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RecordedPicture(
                  currentQuickLog: currentQuickLog,
                  files: imageResults,
                  position: position,
                  exifs: exifs,
                  recordDate: recordDate);
            });
        break;
      // text
      case 1:
        showModalBottomSheet<dynamic>(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            builder: (c) {
              return TextLogInput(
                  logController: this._textController,
                  recordDate: recordDate,
                  onSave: (input) {
                    currentQuickLog.entries.add(new QuickLogEntry(
                        content: input,
                        recordDate: recordDate,
                        entryType: QuickLogType.text,
                        position: position));
                    quickLogHelper.updateQuickLog(
                        currentQuickLog.selfRef, currentQuickLog);
                    Navigator.of(c).pop();
                    scrollDown();
                  });
            });
        break;
      // audio
      case 2:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              final audioRecoder = new FlutterSoundRecorder();
              File audioFile;

              return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: AlertDialog(
                      backgroundColor: AppColor.whiteSoft,
                      insetPadding: EdgeInsets.all(8),
                      content: Container(
                        width: 100,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Datetime of log entry
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatter.format(recordDate),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      formatterTime.format(recordDate),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ]),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(top: 8),
                                color: Colors.transparent,
                                child: RecordAudioScreen(
                                  recorder: audioRecoder,
                                  onFinishedRecording: (path) async {
                                    audioFile = File(path);

                                    final preparedContent =
                                        await audioToBase64(audioFile);
                                    currentQuickLog.entries.add(
                                        new QuickLogEntry(
                                            content:
                                                preparedContent, //audioFile.path,
                                            recordDate: recordDate,
                                            entryType: QuickLogType.audio,
                                            position: position));

                                    quickLogHelper.updateQuickLog(
                                        currentQuickLog.selfRef,
                                        currentQuickLog);
                                    Navigator.of(context).pop();
                                    scrollDown();
                                  },
                                ),
                              ),
                            ]),
                      )));
            });
        break;
      // map
      case 3:
        showModalBottomSheet<dynamic>(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        child: MapPositionStream(
                          onFinishedRecording: (QuickLogEntry entry) {
                            currentQuickLog.entries.add(entry);
                            quickLogHelper.updateQuickLog(
                                currentQuickLog.selfRef, currentQuickLog);
                            Navigator.of(context).pop();
                            scrollDown();
                          },
                        ))
                  ]);
            });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build scaffold");
    return Scaffold(
      key: UniqueKey(),
      bottomNavigationBar: SafeArea(
          bottom: false,
          child: CustomBottomAddNavigationBar(onItemTapped: _onItemTapped)),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: QuickLogDetailAppBarHeader(
              key: UniqueKey(),
              scrollController: _scrollController,
              data: currentQuickLog)),
      body: ListView(
        key: UniqueKey(),
        controller: _scrollController,
        shrinkWrap: false,
        addAutomaticKeepAlives: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          Stack(
            key: UniqueKey(),
            children: [
              Container(
                  key: UniqueKey(),
                  padding: EdgeInsets.only(top: 50, bottom: 0),
                  decoration: BoxDecoration(),
                  child: StreamBuilder(
                    stream: quickLogStream,
                    builder: (context, snapshot) {
                      print("build Tiles");
                      if (!snapshot.hasData) return Text("Loading...");
                      print("create tile");
                      currentQuickLog = snapshot.data;
                      return QuickLogEntryTiles(
                        key: UniqueKey(),
                        data: snapshot.data,
                      );
                    },
                  )),
              Column(
                children: [
                  QuickLogDetailHeader(
                      key: UniqueKey(),
                      data: currentQuickLog,
                      scrollController: _scrollController,
                      photoHeight: photoHeight,
                      isEditing: isEditing),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTextDisplay(String text, String title, bool deterimator,
      TextEditingController controller, TextStyle style, int textlines) {
    if (deterimator) {
      return TextField(
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

  Future audioToBase64(File audioFile) async {
    final audioString = base64Encode(await audioFile.readAsBytes());
    return audioString;
  }

  Future<String> createTempFileFromUint8List(Uint8List decodedAudio) async {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/tmp.mp3').create();
    file.writeAsBytesSync(decodedAudio);
    //return file.path
    return file.path;
  }

  scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 200,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class RecordedPicture extends StatelessWidget {
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final List<XFile> files;
  final DateTime recordDate;
  final QuickLog currentQuickLog;
  final Position position;
  final List<Map<String, IfdTag>> exifs;

  RecordedPicture(
      {Key key,
      this.files,
      this.recordDate,
      this.currentQuickLog,
      this.position,
      this.exifs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hintText = "Add Titel";
    final titles = List.generate(files.length, (i) => "");
    final positions = List.generate(files.length, (_) => position);
    return AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: () async {
                    var index = 0;
                    files.forEach(
                      (element) {
                        savePoto(element.path, recordDate, positions[index],
                            titles[index], currentQuickLog);
                        index = index + 1;
                      },
                    );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.primary,
                  ),
                  child: Icon(Icons.add_a_photo),
                ),
              ),
            ],
          )
        ],
        content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: files.length,
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  final exif = exifs[index];
                  Position exifPostion = getExifPosition(exif);
                  if (exifPostion == null) {
                    exifPostion = position;
                  }

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: Image.file(File(files[index].path)).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: PictureInfo(
                        hintText: hintText,
                        recordDate: recordDate,
                        onTitle: (title) {
                          titles[index] = title;
                        },
                        onUserPhotoLocation: (usePhotoLocation) {
                          print("photolocatiopn $usePhotoLocation");
                          if (usePhotoLocation) {
                            positions[index] = exifPostion;
                          } else {
                            positions[index] = position;
                          }
                        }),
                  );
                },
              ),
            )));
  }

  savePoto(String imagePath, DateTime recordDate, Position position,
      String title, QuickLog quickLog) {
    print("save $title");
    final ql = new QuickLogEntry(
        fileUrl: imagePath,
        content: imagePath,
        recordDate: recordDate,
        titel: title,
        entryType: QuickLogType.photo,
        position: position);
    quickLog.entries.add(ql);
    QuickLogHelper.instance.updateQuickLog(quickLog.selfRef, quickLog);
    QuickLogHelper.instance.tryUpload(imagePath, quickLog, ql.uuid);
  }

  LatLng exifLatitudeLongitudePoint(Map<String, IfdTag> data) {
    if (data.containsKey('GPS GPSLongitude')) {
      final gpsLatitude = data['GPS GPSLatitude'];
      final latitudeSignal = data['GPS GPSLatitudeRef'].printable;
      List latitudeRation = gpsLatitude.values.toList();
      List latitudeValue = latitudeRation.map((item) {
        return (item.numerator.toDouble() / item.denominator.toDouble());
      }).toList();
      double latitude = latitudeValue[0] +
          (latitudeValue[1] / 60) +
          (latitudeValue[2] / 3600);
      if (latitudeSignal == 'S') {
        latitude = -latitude;
      }

      final gpsLongitude = data['GPS GPSLongitude'];
      final longitudeSignal = data['GPS GPSLongitude'].printable;
      List longitudeRation = gpsLongitude.values.toList();
      List longitudeValue = longitudeRation.map((item) {
        return (item.numerator.toDouble() / item.denominator.toDouble());
      }).toList();
      double longitude = longitudeValue[0] +
          (longitudeValue[1] / 60) +
          (longitudeValue[2] / 3600);
      if (longitudeSignal == 'W') {
        longitude = -longitude;
      }

      return LatLng(latitude, longitude);
    }
    return LatLng(0, 0);
  }

  Position getExifPosition(Map<String, IfdTag> exif) {
    final exifLatLng = exifLatitudeLongitudePoint(exif);
    if (exifLatLng == null) {
      return null;
    }
    Map posMap = position.toJson();
    posMap.update("latitude", (value) => exifLatLng.latitude);
    posMap.update("longitude", (value) => exifLatLng.longitude);
    final exifPostion = Position.fromMap(posMap);
    return exifPostion;
  }
}

class PictureInfo extends StatefulWidget {
  final hintText;
  final TextEditingController controller;
  final recordDate;
  final Function(bool) onUserPhotoLocation;
  final Function(String) onTitle;

  PictureInfo(
      {Key key,
      this.hintText,
      this.controller,
      this.recordDate,
      this.onTitle,
      this.onUserPhotoLocation})
      : super(key: key);

  @override
  PictureInfoState createState() => PictureInfoState();
}

class PictureInfoState extends State<PictureInfo> {
  bool _switchValue = true;
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  TextEditingController controller;
  @override
  void initState() {
    widget.onUserPhotoLocation(_switchValue);
    controller = widget.controller;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          //height: 80,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withOpacity(0.26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onSubmitted: (res) {
                  widget.onTitle(res.trim());
                },
                onChanged: (res) {
                  widget.onTitle(res.trim());
                },
                controller: controller,
                autocorrect: true,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                maxLines: 1,
                style: TextStyle(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 12,
                    height: 150 / 100,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 12, color: Colors.white),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        formatter.format(widget.recordDate),
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Use Picture Location",
                    style: TextStyle(
                        color: Colors.white,
                        decorationColor: Colors.white,
                        fontSize: 12,
                        height: 150 / 100,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
                  CupertinoSwitch(
                      value: _switchValue,
                      onChanged: (value) {
                        print("change $value");
                        setState(() {
                          _switchValue = !_switchValue;
                        });
                        this.widget.onUserPhotoLocation(_switchValue);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
