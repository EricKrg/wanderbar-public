import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/recipe_helper.dart';
import 'package:wanderbar/views/screens/quicklog_detail_page.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:intl/intl.dart';

class StatefulQuickLogTile extends StatefulWidget {
  const StatefulQuickLogTile({Key key, this.data}) : super(key: key);

  final QuickLog data;

  @override
  State<StatefulWidget> createState() => _StatefulQuickLogTileState(this.data);
}

class _StatefulQuickLogTileState extends State<StatefulQuickLogTile> {
  final QuickLog data;
  final RecipeHelper recipeHelper = RecipeHelper();

  _StatefulQuickLogTileState(this.data);

  DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  QuickLogDetailPage(key: UniqueKey(), data: data)));
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 90,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // border:
                  //     Border.all(color: AppColor.primary.withAlpha(50), width: 2),
                  color: AppColor.whiteSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Recipe Photo
                    Container(
                      width: 60,
                      height: 60,
                      child: SvgPicture.asset(
                        widget.data.photo,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,

                        // image: DecorationImage(
                        //     image: AssetImage(widget.data.photo), fit: BoxFit.cover),
                      ),
                    ),
                    // Recipe Info
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe title
                            Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Text(
                                data.titel,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'inter'),
                              ),
                            ),
                            // Recipe Calories and Time
                            Row(
                              children: [
                                Icon(Icons.list, size: 14, color: Colors.black),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    data.entries.length.toString(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.date_range,
                                  size: 14,
                                  color: Colors.black,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    formatter.format(widget.data.recordDate),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class QuickLogTile extends StatelessWidget {
  final QuickLog data;
  QuickLogTile({Key key, @required this.data});

  @override
  Widget build(BuildContext context) {
    return StatefulQuickLogTile(data: this.data);
  }
}
