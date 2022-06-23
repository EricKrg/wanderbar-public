import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/views/widgets/map_record_screen.dart';

class ExplorePage extends StatelessWidget {
  final Position position;
  final List<DocumentReference> docRefs;
  final List<Recipe> sweetFoodRecommendationRecipe =
      RecipeHelper.sweetFoodRecommendationRecipe;

  ExplorePage({Key key, this.position, this.docRefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: AllQuickLogsScreen(
              docRefs: [],
              showAllQuicklogs: true,
              showQuickLogCarousel: true,
              isFullScreen: true,
            )));
  }
}
