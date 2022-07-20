import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/models/helper/weather_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/audio_log_tile%20.dart';
import 'package:wanderbar/views/widgets/geolocation_log_tile.dart';
import 'package:wanderbar/views/widgets/info_container.dart';
import 'package:wanderbar/views/widgets/modals/weather_modal.dart';
import 'package:wanderbar/views/widgets/photo_log_tile%20.dart';
import 'package:wanderbar/views/widgets/text_log_tile.dart';

class QuickLogEntryTiles extends StatelessWidget {
  final QuickLog data;
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  QuickLogEntryTiles({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildLogListview(data.entries, data, context);
  }

  Widget buildLogListview(
      List<QuickLogEntry> entries, QuickLog ql, BuildContext context) {
    var lastRecordDate;
    if (entries.isEmpty) {
      print("EMPTY");
      return Center(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 400),
              child: InfoContainer(
                icon: Icons.add_circle_rounded,
                title: "Quicklog is empty, time to add something!",
                subTitle: "Use the Appbar below to add different logs.",
              )));
    }
    print("build list");
    return ListView.separated(
      shrinkWrap: true,
      addAutomaticKeepAlives: true,
      key: UniqueKey(),
      itemCount: entries.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return SizedBox(height: 0);
      },
      itemBuilder: (BuildContext context, index) {
        if (lastRecordDate != formatter.format(entries[index].recordDate)) {
          lastRecordDate = formatter.format(entries[index].recordDate);
          return Column(children: [
            Stack(alignment: Alignment.center, children: [
              Divider(
                height: 60,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.black.withAlpha(50),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        padding: EdgeInsets.all(4),
                        child: Text(lastRecordDate,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500))))
              ]),
            ]),
            QuickLogEntryTile(
              key: UniqueKey(),
              entry: entries[index],
              ql: ql,
            )
          ]);
        }
        return QuickLogEntryTile(
          key: UniqueKey(),
          entry: entries[index],
          ql: ql,
        );
      },
    );
  }
}

class QuickLogEntryTile extends StatelessWidget {
  final QuickLog ql;
  final QuickLogEntry entry;

  const QuickLogEntryTile({Key key, this.ql, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        key: UniqueKey(),
        elevation: 0,
        color: Colors.transparent,
        child: GestureDetector(
          child: Container(
            key: ValueKey(entry.uuid),
            child: getLogEntryWidget(entry, ql),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
          ),
          onLongPress: () async {
            HapticFeedback.heavyImpact();
            if (await askDelete(context, entry, ql)) {
              print("deleting");
              if (entry.entryType == QuickLogType.photo) {
                QuickLogHelper.instance.removeFromStorage(entry.content);
              }
              ql.entries.remove(entry);
              QuickLogHelper.instance.updateQuickLog(ql.selfRef, ql);
            }

            print("not deleting");
          },
        ));
  }

  Future<bool> askDelete(
      BuildContext context, QuickLogEntry entry, QuickLog ql) async {
    var answer = await showDialog(
        context: context,
        builder: ((context) {
          return ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: AlertDialog(
                      backgroundColor: Colors.transparent,
                      actions: [
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 80),
                            decoration: BoxDecoration(
                                color: AppColor.warn,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                icon: Icon(
                                  Icons.delete_forever_rounded,
                                  color: AppColor.whiteSoft,
                                )))
                      ],
                      content:
                          Wrap(children: [getLogEntryWidget(entry, ql)]))));
        }));

    if (answer == null) {
      answer = false;
    }
    print("Answer ${answer}");
    return answer;
  }

  Widget getLogEntryWidget(QuickLogEntry entry, QuickLog parent) {
    switch (entry.entryType) {
      case QuickLogType.location:
        return Text("not implemented");
        break;
      case QuickLogType.photo:
        //print("URL ${entry.content}");
        print("rebuilt photo");
        return PhotoLogTile(
            key: ValueKey(entry.uuid), data: entry, parent: parent);
        break;
      case QuickLogType.text:
        return TextLogTile(data: entry);
        break;
      case QuickLogType.audio:
        return AudioLogTile(entry: entry);
        break;
      case QuickLogType.geolocation:
        return GeolocationLogTile(key: ValueKey(entry.uuid), data: entry);
      case QuickLogType.weather:
        final contentSplit = entry.content.split(":");
        final preset = WeatherHelper().getEntry(contentSplit.first);
        final weatherInfo = WeatherInfo(int.parse(contentSplit.last),
            contentSplit.first, preset.description, preset.iconPath);
        return WeatherTile(
            key: ValueKey(entry.uuid),
            manualInput: false,
            recordDate: entry.recordDate,
            weatherInfo: weatherInfo);
      default:
        throw Error();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
