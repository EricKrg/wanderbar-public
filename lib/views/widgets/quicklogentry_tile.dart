import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/widgets/audio_log_tile%20.dart';
import 'package:hungry/views/widgets/geolocation_log_tile.dart';
import 'package:hungry/views/widgets/info_container.dart';
import 'package:hungry/views/widgets/photo_log_tile%20.dart';
import 'package:hungry/views/widgets/text_log_tile.dart';

class QuickLogEntryTiles extends StatelessWidget {
  final QuickLog data;
  const QuickLogEntryTiles({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildLogListview(data.entries, data);
  }

  Widget buildLogListview(List<QuickLogEntry> entries, QuickLog ql) {
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
    return Dismissible(
      key: UniqueKey(),
      child: Container(
        key: ValueKey(entry.uuid),
        child: getLogEntryWidget(entry, ql),
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
      ),
      background: Container(
        child: Icon(Icons.delete, color: Colors.red),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 30),
      ),
      secondaryBackground: Container(
        child: Icon(Icons.delete, color: Colors.red),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 30),
      ),
      onDismissed: (direction) {
        if (entry.entryType == QuickLogType.photo) {
          QuickLogHelper.instance.removeFromStorage(entry.content);
        }
        ql.entries.remove(entry);
        QuickLogHelper.instance.updateQuickLog(ql.selfRef, ql);
      },
    );
  }

  Widget getLogEntryWidget(QuickLogEntry entry, QuickLog parent) {
    switch (entry.entryType) {
      case QuickLogType.location:
        return Text("not implemented");
        break;
      case QuickLogType.photo:
        //print("URL ${entry.content}");
        print("rebuilt photo");
        return PhotoLogTile(key: ValueKey(entry.uuid), data: entry);
        break;
      case QuickLogType.text:
        return TextLogTile(data: entry);
        break;
      case QuickLogType.audio:
        return AudioLogTile(entry: entry);
        break;
      case QuickLogType.geolocation:
        return GeolocationLogTile(key: ValueKey(entry.uuid), data: entry);
      default:
        throw Error();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
