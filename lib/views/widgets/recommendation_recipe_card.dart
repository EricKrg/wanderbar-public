import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/views/screens/full_screen_image.dart';
import 'package:intl/intl.dart';

class RecommendationRecipeCard extends StatelessWidget {
  final QuickLogEntry data;
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  RecommendationRecipeCard({@required this.data});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullScreenLocalImage(url: data.fileUrl)));
      },
      child: Container(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Photo
            CachedNetworkImage(
              cacheManager: CacheManager(Config(
                "logImages",
                stalePeriod: const Duration(days: 7),
                //one week cache period
              )),
              imageUrl: data.fileUrl,
              imageBuilder: (context, imageProvider) => Container(
                height: 120,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueGrey,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Recipe title
            if (data.titel.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 8),
                // padding: EdgeInsets.only(left: 4),
                child: Text(
                  data.titel,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'inter'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (data.titel.isEmpty) Padding(padding: EdgeInsets.only(top: 10)),
            // Recipe calories and time
            Container(
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    color: Colors.black,
                    size: 12,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      this.formatter.format(data.recordDate),
                      style: TextStyle(fontSize: 10, fontFamily: 'inter'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
