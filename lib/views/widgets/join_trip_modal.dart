import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/custom_text_field.dart';

import '../../models/core/recipe.dart';

class JoinTripModal extends StatefulWidget {
  const JoinTripModal({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JoinTripModalState();
}

class JoinTripModalState extends State<JoinTripModal> {
  final _tripCodeController = TextEditingController();
  var showAddbtn = false;
  Trip selectedTrip;

  final QuickLogHelper quickLogHelper = QuickLogHelper.instance;

  @override
  void initState() {
    super.initState();
    _tripCodeController.addListener(() async {
      if (_tripCodeController.text.trim().length == 20) {
        print("controller ${_tripCodeController.text}");
        final res =
            await quickLogHelper.getTripById(_tripCodeController.text.trim());
        if (res.exists) {
          print("Exists!");
          setState(() {
            selectedTrip = Trip.fromJson(res.data());
            showAddbtn = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: AlertDialog(
          backgroundColor: AppColor.whiteSoft,
          insetPadding: EdgeInsets.all(16),
          content: Container(
              height: 80,
              child: CustomTextField(
                  controller: _tripCodeController,
                  hint: "Enter the Trip-Code",
                  title: "Trip-Code")),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: showAddbtn
                        ? () async {
                            quickLogHelper.addForeignTrip(
                                FirebaseAuth.instance.currentUser,
                                selectedTrip.id);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Icon(Icons.add_to_photos,
                        color: showAddbtn ? AppColor.primarySoft : Colors.grey),
                    style: ElevatedButton.styleFrom(
                      primary: AppColor.primaryExtraSoft,
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
