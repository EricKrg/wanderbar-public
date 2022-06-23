import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class FullScreenImage extends StatelessWidget {
  final Widget image;
  FullScreenImage({@required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (() {
                //GallerySaver.saveImage(image)
              }),
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ))
        ],
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: new Container(
        alignment: Alignment.center,
        // Image Wrapper
        child: Container(
          width: MediaQuery.of(context).size.width,
          // Image Widget
          child: image,
        ),
      ),
    );
  }
}

class FullScreenLocalImage extends StatelessWidget {
  final String url;

  FullScreenLocalImage({@required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (() async {
                  final path = await _findPath(url);
                  Share.shareFiles([path]);
                }),
                icon: Icon(
                  Icons.ios_share,
                  color: Colors.white,
                ))
          ],
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
            child: CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, imageProvider) {
            return PhotoView(imageProvider: imageProvider);
          },
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        )));
  }

  Future<String> _findPath(String imageUrl) async {
    final cache = CacheManager(Config(
      "logImages",
      stalePeriod: const Duration(days: 7),
      //one week cache period
    ));
    final fileInfo = await cache.getFileFromCache(imageUrl);
    return fileInfo.file.path;
  }
}
