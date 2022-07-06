import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/info_container.dart';
import 'package:wanderbar/views/widgets/modals/register_modal.dart';
import 'package:wanderbar/views/widgets/take_picture_screen.dart';
import 'package:wanderbar/views/widgets/user_info_tile.dart';

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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        flexibleSpace: AnimatedGradient(),
        elevation: 0,
        centerTitle: true,
        title: Text('My Profile',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'inter',
                fontWeight: FontWeight.w500,
                fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.logout_rounded, color: Colors.black),
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
                color: Colors.black,
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
              color: AppColor.whiteSoft,
              padding: EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: () async {
                  try {
                    final List<XFile> imageResult = await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        builder: (context) {
                          return TakePictureScreen();
                        });

                    if (imageResult.isNotEmpty && imageResult.first != null) {
                      setState(() {
                        isPhotoLoading = true;
                      });
                      User user = FirebaseAuth.instance.currentUser;
                      if (user.photoURL != null) {
                        QuickLogHelper.instance
                            .removeFromStorage("/user/${user.email}.jpg");
                      }

                      TaskSnapshot uploadTask = await QuickLogHelper.instance
                          .uploadUserImage(File(imageResult.first.path), user);

                      user.updatePhotoURL(
                          await uploadTask.ref.getDownloadURL());
                      QuickLogHelper.instance
                          .createSimpleUser(FirebaseAuth.instance.currentUser);
                      CachedNetworkImage.evictFromCache(user.photoURL);
                      setState(() {
                        isPhotoLoading = false;
                        tmpImg = imageResult.first.path;
                      });
                    }
                  } catch (e) {
                    print("Error uploading profile picture $e");
                    setState(() {
                      isPhotoLoading = false;
                    });
                  }
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
                                color: Colors.black)),
                        SizedBox(width: 8),
                        SvgPicture.asset('assets/icons/camera.svg',
                            color: Colors.black),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Section 2 - User Info Wrapper
            Visibility(
                visible: this.isPhotoLoading,
                child: LinearProgressIndicator(
                  backgroundColor: AppColor.primary.withAlpha(150),
                  color: AppColor.primarySoft,
                )),
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

                        if (user.displayName == null) {
                          return InfoContainer(
                              title: "No Username set",
                              subTitle:
                                  "Edit your Useraccount to set a Username");
                        }

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
