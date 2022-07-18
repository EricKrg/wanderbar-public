import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

class UserCard extends StatelessWidget {
  final UserSimple user;

  const UserCard({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(this.user.displayName);
    return Container(
        margin: EdgeInsets.only(right: 4),
        child: Container(
            child: ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        // color: Colors.black.withOpacity(0.26),
                      ),
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: this.user.photoUrl,
                            imageBuilder: (context, imageProvider) {
                              return CircleAvatar(
                                backgroundImage: imageProvider,
                              );
                            },
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(
                                Icons.face,
                                color: AppColor.primary.withAlpha(180),
                                size: 40),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: AppColor.primary.withAlpha(180),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                "${this.user.displayName}",
                                style: TextStyle(
                                    color: AppColor.whiteSoft,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'inter'),
                              )),
                        ],
                      )),
                ],
              )),
        )));
  }
}
