import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wanderbar/models/core/log_model.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/views/screens/full_screen_image.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:intl/intl.dart';

class PhotoLogTile extends StatelessWidget {
  double mapOffset = 0;
  bool isLocal = false;
  int urlRetry = 0;

  final QuickLogEntry data;
  QuickLog parent;

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  final cacheManager = CacheManager(Config(
    "logImages",
    stalePeriod: const Duration(days: 7),
    //one week cache period
  ));

  PhotoLogTile({Key key, this.data, this.parent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200, child: getPictureWidget(data.fileUrl, context));
  }

  Widget getPictureWidget(String url, BuildContext context) {
    final imageWidget = getImage(url, context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullScreenLocalImage(url: url)));
      },
      child: Container(child: imageWidget),
    );
  }

  Widget getImage(String url, BuildContext context) {
    var returnWidget;
    if (url.startsWith("http")) {
      returnWidget = CachedNetworkImage(
        cacheManager: cacheManager,
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(8),
              child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Wrap(alignment: WrapAlignment.start, children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.26),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Title
                                if (data.titel.isNotEmpty)
                                  Text(
                                    data.titel,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 150 / 100,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'inter'),
                                  ),
                                Container(
                                  margin: EdgeInsets.only(top: 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        formatter.format(data.recordDate),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Padding(padding: EdgeInsets.all(4)),
                                      Text(
                                        formatterTime.format(data.recordDate),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ])),
              ),
            )),
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          urlRetry = urlRetry + 1;
          // QuickLogHelper.instance
          //     .tryUpdatingFileUrl(widget.parent, widget.data, urlRetry);
          return const Icon(Icons.error);
        },
      );
    } else {
      returnWidget = Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: Image.file(File(url)).image,
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(8),
            child: ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Wrap(children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black.withOpacity(0.26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Title
                              if (data.titel.isNotEmpty)
                                Text(
                                  data.titel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 150 / 100,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'inter'),
                                ),

                              Container(
                                margin: EdgeInsets.only(top: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          formatter.format(data.recordDate),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Padding(padding: EdgeInsets.all(4)),
                                        Text(
                                          formatterTime.format(data.recordDate),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    TryUploadBtn(
                                      data: data,
                                      parent: parent,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ])),
            ),
          ));
    }
    return returnWidget;
  }
}

class TryUploadBtn extends StatefulWidget {
  final QuickLog parent;
  final QuickLogEntry data;

  const TryUploadBtn({Key key, this.parent, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TryUploadBtnState();
}

class TryUploadBtnState extends State<TryUploadBtn> {
  bool showUploadBtn;
  bool isLoading = false;

  @override
  void initState() {
    showUploadBtn = widget.data.isLocalFile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showUploadBtn,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColor.warn,
          ),
          onPressed: () {
            widget.data.isLocalFile = false;
            isLoading = true;
            setState(() {
              this.showUploadBtn = false;
            });
            QuickLogHelper.instance
                .tryUpload(widget.data.fileUrl, widget.parent, widget.data.uuid)
                .then((value) {
              setState(() {
                this.showUploadBtn = !value;
              });
            });
          },
          child: Row(
            children: [Text("Try again"), Icon(Icons.replay_outlined)],
          )),
    );
  }
}

class SimplePhotoLogTile extends StatefulWidget {
  final QuickLogEntry data;
  const SimplePhotoLogTile({Key key, @required this.data}) : super(key: key);

  @override
  _SimplePhotoLogTileState createState() => _SimplePhotoLogTileState();
}

class _SimplePhotoLogTileState extends State<SimplePhotoLogTile> {
  bool isLocal = false;
  int urlRetry = 0;

  @override
  void initState() {
    super.initState();
  }

  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatterTime = DateFormat('HH:mm');
  final cacheManager = CacheManager(Config(
    "logImages",
    stalePeriod: const Duration(days: 7),
    //one week cache period
  ));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            QuickLogHelper.instance.getDownloadUrlForPath(widget.data, false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
                height: 200, child: getPictureWidget(snapshot.data));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Container();
        });
  }

  Widget getPictureWidget(String url) {
    return GestureDetector(
      onTap: () {
        print("open image");
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullScreenLocalImage(url: url)));
      },
      child: Container(child: getImage(url)),
    );
  }

  Widget getImage(String url) {
    if (url.startsWith("http")) {
      return CachedNetworkImage(
        cacheManager: cacheManager,
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(8),
              child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Wrap(alignment: WrapAlignment.start, children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.26),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Title
                                if (widget.data.titel.isNotEmpty)
                                  Text(
                                    widget.data.titel,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 150 / 100,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'inter'),
                                  ),
                                // Recipe Calories and Time
                                Container(
                                  margin: EdgeInsets.only(top: 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        formatter
                                            .format(widget.data.recordDate),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Padding(padding: EdgeInsets.all(4)),
                                      Text(
                                        formatterTime
                                            .format(widget.data.recordDate),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ])),
              ),
            )),
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          urlRetry = urlRetry + 1;
          return const Icon(Icons.error);
        },
      );
    } else {
      return Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.bottomLeft,
          //margin: EdgeInsets.only(right: 8),
          // margin: EdgeInsets.all(16),
          //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: Image.file(File(url)).image,
              fit: BoxFit.cover,
            ),
          ),
          // Recipe Card Info
          child: Container(
            margin: EdgeInsets.all(8),
            child: ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Wrap(children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black.withOpacity(0.26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Title
                              if (widget.data.titel.isNotEmpty)
                                Text(
                                  widget.data.titel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 150 / 100,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'inter'),
                                ),

                              Container(
                                margin: EdgeInsets.only(top: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          formatter
                                              .format(widget.data.recordDate),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Padding(padding: EdgeInsets.all(4)),
                                        Text(
                                          formatterTime
                                              .format(widget.data.recordDate),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ])),
            ),
          ));
    }
  }
}
