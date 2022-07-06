import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/models/helper/recipe_helper.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/featured_recipe_card.dart';
import 'package:wanderbar/views/widgets/info_container.dart';
import 'package:wanderbar/views/widgets/modals/search_filter_modal.dart';
import 'package:wanderbar/views/widgets/quick_log_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchInputController = TextEditingController();
  final List<Recipe> searchResult = RecipeHelper.sarchResultRecipe;
  List<String> searchTerms = [];
  int activeSortOption = 0;
  Query<Map<String, dynamic>> query;

  @override
  Widget build(BuildContext context) {
    print(searchInputController.text.isEmpty);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AnimatedGradient(),
        elevation: 0,
        centerTitle: true,
        title: Text('Search',
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
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Search
          Container(
            width: MediaQuery.of(context).size.width,
            // height: 145,
            // color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search TextField
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.whiteSoft),
                          child: TextField(
                            controller: searchInputController,
                            onSubmitted: (value) {
                              searchInputController.clear();
                              this.searchTerms.add(value.toLowerCase().trim());

                              setState(() {});
                            },
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            maxLines: 1,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Type to search',
                              hintStyle: TextStyle(
                                color: AppColor.primary,
                                fontFamily: 'inter',
                              ),
                              prefixIconConstraints:
                                  BoxConstraints(maxHeight: 20),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 17),
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              prefixIcon: Visibility(
                                visible: (searchInputController.text.isEmpty)
                                    ? true
                                    : false,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 12),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 20,
                                    height: 20,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Filter Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              builder: (context) {
                                return SearchFilterModal(
                                  activeOption: this.activeSortOption,
                                  optionSelected: (opt) {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      print("opt $opt");
                                      this.activeSortOption = opt;
                                    });
                                  },
                                );
                              });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.whiteSoft,
                          ),
                          child: SvgPicture.asset('assets/icons/filter.svg'),
                        ),
                      )
                    ],
                  ),
                ),
                // Search Keyword Recommendation
                if (searchTerms.isNotEmpty)
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: searchTerms.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8);
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.topCenter,
                          child: TextButton(
                            onPressed: () {},
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                searchTerms.removeAt(index);
                              });
                            },
                            child: Text(
                              searchTerms[index],
                              style: TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: AppColor.primary, width: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          // Section 2 - Search Result
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Text(
                    'These Trips where found..',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                // trips
                FutureBuilder(
                    future: QuickLogHelper.instance
                        .resolveUserTrips(FirebaseAuth.instance.currentUser),
                    builder: (context, AsyncSnapshot<List<Trip>> snapshot) {
                      if (!snapshot.hasData)
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      final res = snapshot.data.where((element) {
                        if (searchTerms.isEmpty) {
                          return true;
                        }
                        if (searchTerms.contains(element.titel.toLowerCase())) {
                          return true;
                        }
                        if (searchTerms
                            .where((term) =>
                                element.titel.toLowerCase().contains(term))
                            .isNotEmpty) {
                          return true;
                        }

                        if (element.sharedWithNames.where((editor) {
                          if (editor != null) {
                            return searchTerms.contains(editor.toLowerCase());
                          }
                          return false;
                        }).isNotEmpty) {
                          return true;
                        }
                        return false;
                      }).toList();
                      if (res.isEmpty) {
                        return InfoContainer(
                            icon: Icons.golf_course_rounded,
                            title: "No trip found.",
                            subTitle: "Houston, we have a problem.");
                      }
                      return ListView.separated(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        itemCount: res.length,
                        physics: BouncingScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return Container(
                              height: 100,
                              child: FeaturedRecipeCard(inputTrip: res[index]));
                        },
                      );
                    }),

                // logs
                // Padding(padding: EdgeInsets.all(20)),
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    'These logs where found..',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                FutureBuilder(
                    future: QuickLogHelper.instance
                        .getAllQuickLogs(FirebaseAuth.instance.currentUser),
                    builder: (context, AsyncSnapshot<List<QuickLog>> snapshot) {
                      if (!snapshot.hasData)
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      final res = snapshot.data.where((element) {
                        if (searchTerms.isEmpty) {
                          return true;
                        }
                        if (searchTerms.contains(element.titel.toLowerCase())) {
                          return true;
                        }
                        if (searchTerms
                            .where((term) =>
                                element.titel.toLowerCase().contains(term))
                            .isNotEmpty) {
                          return true;
                        }
                        return false;
                      }).toList();
                      res.sort((a, b) => sortRes(a, b, this.activeSortOption));
                      if (res.isEmpty) {
                        return InfoContainer(
                          icon: Icons.air_rounded,
                          title: "No Log found",
                          subTitle: "What are you searching for anyways?",
                        );
                      }
                      return ListView.separated(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        itemCount: res.length,
                        physics: BouncingScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return QuickLogTile(
                              key: UniqueKey(), data: res[index]);
                        },
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int sortRes(QuickLog a, QuickLog b, int sortOption) {
    switch (sortOption) {
      case 0:
        return b.recordDate.compareTo(a.recordDate);
        break;
      case 1:
        return a.recordDate.compareTo(b.recordDate);
        break;
      default:
        return 0;
    }
  }
}
