import 'package:flutter/material.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:intl/intl.dart';

class TextLogTile extends StatelessWidget {
  final QuickLogEntry data;

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  TextLogTile({@required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColor.whiteSoft //Colors.black.withOpacity(0.26),
          //border: Border(bottom: BorderSide(color: Colors.grey[350], width: 1))
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review username
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
          // useer review
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              data.content,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  height: 150 / 100),
            ),
          )
        ],
      ),
    );
  }
}

class TextLogInput extends StatefulWidget {
  final String restorationId;
  final TextEditingController logController;
  final DateTime recordDate;
  final Function(String) onSave;
  TextLogInput(
      {Key key,
      this.recordDate,
      this.onSave,
      this.restorationId,
      this.logController});

  @override
  _TextLogInputState createState() => _TextLogInputState();
}

class _TextLogInputState extends State<TextLogInput> {
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final input = widget.logController;
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
            // height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Datetime of log entry
                  Container(
                      padding: EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        formatter.format(widget.recordDate),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    color: Colors.white,
                    child: TextField(
                      controller: input,
                      autocorrect: true,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      minLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Write your Log here...',
                      ),
                      maxLines: null,
                    ),
                  )
                ]),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 15),
                child: IconButton(
                  onPressed: () {
                    widget.onSave(input.text.trim());
                    input.clear();
                  },
                  icon: Icon(Icons.add_circle_rounded),
                ),
              ),
            ],
          )
        ]);
  }
}
