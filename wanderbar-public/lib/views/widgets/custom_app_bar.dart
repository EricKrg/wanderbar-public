import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hungry/views/utils/AppColor.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final bool showProfilePhoto;
  final String profilePhoto;
  final Function profilePhotoOnPressed;

  CustomAppBar(
      {@required this.title,
      @required this.showProfilePhoto,
      this.profilePhoto,
      this.profilePhotoOnPressed});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: AppColor.primary,
      title: title,
      elevation: 0,
      actions: [
        Visibility(
          visible: showProfilePhoto,
          child: Container(
            margin: EdgeInsets.only(right: 16),
            alignment: Alignment.center,
            child: IconButton(
              onPressed: profilePhotoOnPressed,
              icon: CachedNetworkImage(
                imageUrl: profilePhoto,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  );
                },
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
