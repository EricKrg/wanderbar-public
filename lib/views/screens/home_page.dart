import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderbar/models/core/recipe.dart';
import 'package:wanderbar/models/helper/asset_helper.dart';
import 'package:wanderbar/models/helper/quick_log_helper.dart';
import 'package:wanderbar/models/helper/recipe_helper.dart';
import 'package:wanderbar/views/screens/newly_posted_page.dart';
import 'package:wanderbar/views/screens/profile_page.dart';
import 'package:wanderbar/views/screens/quicklog_detail_page.dart';
import 'package:wanderbar/views/screens/search_page.dart';
import 'package:wanderbar/views/screens/trip_screen.dart';
import 'package:wanderbar/views/utils/AppColor.dart';
import 'package:wanderbar/views/widgets/custom_app_bar.dart';
import 'package:wanderbar/views/widgets/dummy_search_bar.dart';
import 'package:wanderbar/views/widgets/featured_recipe_card.dart';
import 'package:wanderbar/views/widgets/info_container.dart';
import 'package:wanderbar/views/widgets/join_trip_modal.dart';
import 'package:wanderbar/views/widgets/map_record_screen.dart';
import 'package:wanderbar/views/widgets/quick_log_tile.dart';
import 'package:wanderbar/views/widgets/recommendation_recipe_card.dart';

class StatefulHomePage extends StatefulWidget {
  const StatefulHomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StatefulHomePageState();
}

class _StatefulHomePageState extends State<StatefulHomePage> {
  List<Recipe> featuredRecipe;
  List<Recipe> recommendationRecipe;
  List<Recipe> newlyPostedRecipe;
  RecipeHelper recipeHelper = RecipeHelper();

  ScrollController _scrollController = ScrollController();

  QuickLogHelper quickLogHelper = QuickLogHelper.instance;

  bool showAppBar = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          scrollController: _scrollController,
          showProfilePhoto: true,
          profilePhoto: QuickLogHelper.instance
              .getUserAsStream(FirebaseAuth.instance.currentUser.email)
              .map((event) => UserSimple.fromJson(event.data())),
          profilePhotoOnPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
        body: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(gradient: AppColor.bgMultiColor),
          ),
          HomePageContent(scrollController: this._scrollController)
        ]));
  }

  @override
  void initState() {
    super.initState();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StatefulHomePage();
  }
}

class HomePageContent extends StatelessWidget {
  final scrollController;

  const HomePageContent({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: this.scrollController,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: [
        Container(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DummySearchBar(
              routeTo: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Trips',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('see all'),
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14)),
                  ),
                ],
              ),
            ),
            createCreatTripCollectionFromStream()
          ],
        )),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: GestureDetector(
                        onTap: () async {
                          var trip = new Trip(
                              titel: "New Trip",
                              id: "",
                              photo: AssetHelper.getRandomBackgroundAsset(),
                              quickLogs: [],
                              sharedWith: []);

                          var updatedTrip = await QuickLogHelper.instance
                              .addTrip(FirebaseAuth.instance.currentUser, trip);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  TripPage(data: updatedTrip)));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Create a new Trip',
                                    style: TextStyle(
                                        fontFamily: 'inter',
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.whiteSoft)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.whiteSoft,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: GestureDetector(
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return JoinTripModal();
                          });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Join a Trip',
                                style: TextStyle(
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your latest Memories ...',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              // Content
              StreamBuilder(
                  stream: QuickLogHelper.instance.streamLatestQuicklogEntries(
                      FirebaseAuth.instance.currentUser),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (!snapshot.hasData) return Text("loading...");
                    final latestPhotos = QuickLogHelper.instance
                        .filterLatestPhotos(snapshot.data);
                    if (latestPhotos.isEmpty) {
                      return Container(
                          padding: EdgeInsets.all(20),
                          child: InfoContainer(
                            title: "No Memories added yet!",
                            subTitle:
                                "If you add a Photolog, the most recent Photo will appear here.",
                          ));
                    }
                    return Container(
                      height: 174,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: latestPhotos.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 16);
                        },
                        itemBuilder: (context, index) {
                          return RecommendationRecipeCard(
                              data: latestPhotos[index]);
                        },
                      ),
                    );
                  }),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 14),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Logs',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewlyPostedPage()));
                    },
                    child: Text(
                      'see all',
                      textAlign: TextAlign.end,
                    ),
                    style: TextButton.styleFrom(
                        primary: Colors.black,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14)),
                  ),
                ],
              ),
              // Content
              //createQuickLogTilesFromStream(),
              Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: AllQuickLogsScreen(
                      docRefs: [],
                      isFullScreen: false,
                      showAllQuicklogs: true,
                      showQuickLogCarousel: true)),

              //createQuickLogTiles(),
              // Add new Quicklog entries
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 50),
                alignment: Alignment.bottomLeft,
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: GestureDetector(
                    onTap: () async {
                      QuickLog newQl = QuickLog(
                          description: "",
                          recordDate: DateTime.now(),
                          entries: [],
                          photo: AssetHelper.getRandomIconAsset(),
                          titel: "");
                      await QuickLogHelper.instance.addQuickLog(
                          FirebaseAuth.instance.currentUser, newQl);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QuickLogDetailPage(
                              key: UniqueKey(), data: newQl)));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_box_outlined,
                                color: AppColor.whiteSoft),
                            Text('Add new Log',
                                style: TextStyle(
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.whiteSoft)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget createQuickLogTiles() {
    return FutureBuilder(
        future: QuickLogHelper.instance
            .getAllQuickLogs(FirebaseAuth.instance.currentUser),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            final length = snapshot.data.length;
            return ListView.separated(
              shrinkWrap: true,
              itemCount: length > 3 ? 3 : snapshot.data.length,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key((index).toString()),
                  child: QuickLogTile(data: snapshot.data[index]),
                  background: Container(
                    child: Icon(Icons.delete, color: Colors.red),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 30),
                  ),
                  secondaryBackground: Container(
                    child: Icon(Icons.delete, color: Colors.red),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 30),
                  ),
                  onDismissed: (direction) async {
                    print(snapshot.data[index].id);
                    await QuickLogHelper.instance.deleteQuickLog(
                        snapshot.data[index].selfRes, snapshot.data[index]);
                    snapshot.data.removeAt(index);
                  },
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        }));
  }

  createCreatTripCollectionFromStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: QuickLogHelper.instance
          .getTripsAsStream(FirebaseAuth.instance.currentUser),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        final length = snapshot.data.docs.length;
        final List<UserTripCollection> res =
            snapshot.data.docs.map((docSnapshot) {
          return UserTripCollection.fromJson(docSnapshot.data());
        }).toList();
        if (res.isEmpty) {
          return Container(
              padding: EdgeInsets.all(20),
              child: InfoContainer(
                icon: Icons.air_rounded,
                title: "No Trips created yet!",
                subTitle:
                    "You can create a Trip or join a Trip with the buttons below",
              ));
        }
        return Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            height: 240,
            child: ListView.separated(
              itemCount: length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 16,
                );
              },
              itemBuilder: (context, index) {
                // return Text("data");
                return FeaturedRecipeCard(data: res[index]);
              },
            ));
      },
    );
  }

  showDeleteModal(
      QuickLog ql, List<QuickLog> res, int index, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var recordDate = DateTime.now();
          final _logController = TextEditingController();
          var hintText = "Add Titel";
          return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(0),
                content: GestureDetector(
                    onTap: () {}, child: QuickLogTile(data: ql)),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: ElevatedButton(
                          onPressed: () async {
                            await QuickLogHelper.instance
                                .deleteQuickLog(res[index].selfRef, res[index]);
                            res.removeAt(index);
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.delete),
                          style: ElevatedButton.styleFrom(
                            primary: AppColor.warn,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }
}
