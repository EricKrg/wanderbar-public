import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/record_audio_screen.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AudioLogTile extends StatefulWidget {
  final QuickLogEntry entry;
  const AudioLogTile({Key key, @required this.entry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AudioLogTileState();
}

class AudioLogTileState extends State<AudioLogTile>
    with AutomaticKeepAliveClientMixin {
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  String filePath;
  bool isReady = false;

  bool isInit = false;

  Widget audioSlider;

  @override
  void initState() {
    super.initState();
    //createTempFileFromUint8List(base64Decode(widget.entry.content));
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (filePath != null) {
      print("deleting on dispose audio_log_tile!");
      deleteFile(File(filePath));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: createTempFileFromUint8List(base64Decode(widget.entry.content)),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColor.whiteSoft,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatter.format(widget.entry.recordDate),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  formatterTime.format(widget.entry.recordDate),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ]),
                          // useer review
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              //color: Colors.black.withOpacity(0.26),
                              child:
                                  AudioSliderWidget(audioFile: File(filePath)))
                        ],
                      ),
                    )));
          } else {
            return CircularProgressIndicator();
          }
        }));
  }

  Future<String> createTempFileFromUint8List(Uint8List decodedAudio) async {
    final tempDir = await getTemporaryDirectory();
    File file =
        await File('${tempDir.path}/${widget.entry.uuid}-tmp.mp3').create();
    file.writeAsBytesSync(decodedAudio);
    //return file.path
    filePath = file.path;
    return filePath;
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("deleting was not successful!" + e.toString());
      // Error in getting access to the file.
    }
  }

  @override
  bool get wantKeepAlive => true;
}
