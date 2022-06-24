import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/info_container.dart';
import 'package:hungry/views/widgets/quick_log_tile.dart';

class NewlyPostedPage extends StatelessWidget {
  final TextEditingController searchInputController = TextEditingController();

  final QuickLogHelper quickLogHelper = QuickLogHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: AppColor.primary,
          centerTitle: true,
          elevation: 0,
          title: Text('All QuickLogs',
              style: TextStyle(
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16)),
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    // Navigator.of(context).pop();
                  })
              : Container()),
      body: Container(
        child: createQuickLogTilesFromStream(),
        padding: EdgeInsets.only(top: 10),
      ),
    );
  }

  createQuickLogTilesFromStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: quickLogHelper
          .getQuickLogsAsStream(FirebaseAuth.instance.currentUser),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        final length = snapshot.data.docs.length;
        final res = snapshot.data.docs.map((docSnapshot) {
          return QuickLog.fromJson(docSnapshot.data());
        }).toList();
        if (res.isEmpty) {
          return InfoContainer(
            title: "No QuickLogs found.",
            subTitle: "If you create Quicklogs they will appear here",
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          itemCount: length,
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(height: 16);
          },
          itemBuilder: (context, index) {
            return Dismissible(
              key: UniqueKey(),
              child: QuickLogTile(data: res[index]),
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
              onDismissed: (direction) async {
                await quickLogHelper.deleteQuickLog(
                    res[index].selfRef, res[index]);
                res.removeAt(index);
              },
            );
          },
        );
      },
    );
  }
}
