import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/views/utils/AppColor.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showProfilePhoto;
  final Stream<UserSimple> profilePhoto;
  final Function profilePhotoOnPressed;
  final ScrollController scrollController;

  CustomAppBar(
      {@required this.showProfilePhoto,
      this.profilePhoto,
      this.profilePhotoOnPressed,
      this.scrollController});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  State<StatefulWidget> createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  bool showAppbar = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      changeAppBar(widget.scrollController);
    });
  }

  changeAppBar(ScrollController scrollController) {
    if (this.mounted) {
      if (scrollController.position.hasPixels) {
        if (scrollController.position.pixels > 10.0) {
          setState(() {
            this.showAppbar = false;
          });
        }
        if (scrollController.position.pixels <= 5.0) {
          setState(() {
            this.showAppbar = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: this.showAppbar ? 1 : 0,
        duration: Duration(milliseconds: 300),
        child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor:
                Colors.transparent, //AppColor.primary.withOpacity(0.2),
            title: Text('Wanderbar',
                style: TextStyle(
                    color: Colors.black, //AppColor.whiteSoft,
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w700)),
            elevation: 0,
            actions: [
              Visibility(
                visible: widget.showProfilePhoto,
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  alignment: Alignment.center,
                  child: IconButton(
                      onPressed: widget.profilePhotoOnPressed,
                      icon: StreamBuilder(
                        stream: widget.profilePhoto,
                        builder: (context, AsyncSnapshot<UserSimple> snapshot) {
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());
                          return CachedNetworkImage(
                            imageUrl: snapshot.data.photoUrl,
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
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          );
                        },
                      )),
                ),
              )
            ]));
  }
}
