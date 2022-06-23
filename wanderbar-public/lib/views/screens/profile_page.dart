import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/quick_log_helper.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/modals/register_modal.dart';
import 'package:hungry/views/widgets/take_picture_screen.dart';
import 'package:hungry/views/widgets/user_info_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String photoUrl;
  String tmpImg;
  bool isPhotoLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    photoUrl = FirebaseAuth.instance.currentUser.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('My Profile',
            style: TextStyle(
                fontFamily: 'inter',
                fontWeight: FontWeight.w400,
                fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            child: Text(
              'logout',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
                primary: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
          ),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  isScrollControlled: true,
                  builder: (context) {
                    return RegisterModal();
                  },
                );
              },
              icon: Icon(
                Icons.edit_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            // Section 1 - Profile Picture Wrapper
            Container(
              color: AppColor.primary,
              padding: EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: () async {
                  final XFile imageResult = await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      builder: (context) {
                        return TakePictureScreen();
                      });
                  User user = FirebaseAuth.instance.currentUser;
                  if (user.photoURL != null) {
                    QuickLogHelper.instance
                        .removeFromStorage("/user/${user.email}.jpg");
                  }
                  setState(() {
                    isPhotoLoading = true;
                  });
                  TaskSnapshot uploadTask = await QuickLogHelper.instance
                      .uploadUserImage(File(imageResult.path), user);

                  user.updatePhotoURL(await uploadTask.ref.getDownloadURL());
                  CachedNetworkImage.evictFromCache(user.photoURL);
                  setState(() {
                    isPhotoLoading = false;
                    tmpImg = imageResult.path;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    tmpImg != null
                        ? Container(
                            width: 130,
                            height: 130,
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(100),
                              // Profile Picture
                              image: DecorationImage(
                                  image: Image.file(File(tmpImg)).image,
                                  fit: BoxFit.cover),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: photoUrl,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                width: 130,
                                height: 130,
                                margin: EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(100),
                                  // Profile Picture
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              );
                            },
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isPhotoLoading
                            ? CircularProgressIndicator(color: AppColor.primary)
                            : Container(),
                        Text('Change Profile Picture',
                            style: TextStyle(
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        SizedBox(width: 8),
                        SvgPicture.asset('assets/icons/camera.svg',
                            color: Colors.white),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Section 2 - User Info Wrapper
            Container(
              margin: EdgeInsets.only(top: 24),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoTile(
                    margin: EdgeInsets.only(bottom: 16),
                    label: 'Email',
                    textWidget: Text(FirebaseAuth.instance.currentUser.email,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'inter')),
                    value: FirebaseAuth.instance.currentUser.email,
                  ),
                  StreamBuilder(
                      stream: QuickLogHelper.instance.getUserAsStream(
                          FirebaseAuth.instance.currentUser.email),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        final user = UserSimple.fromJson(snapshot.data.data());
                        return UserInfoTile(
                          margin: EdgeInsets.only(bottom: 16),
                          label: 'Display name',
                          textWidget: Text(user.displayName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'inter')),
                          value: user.displayName,
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
          child: // Log in Button
              SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: OutlinedButton(
              child: Text('Log out',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'inter')),
              onPressed: () {
                print("log out");
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: BorderSide(
                    color: AppColor.primary.withOpacity(0.5), width: 1),
                primary: AppColor.primary,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
