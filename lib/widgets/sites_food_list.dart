import 'package:capstone/services/favorites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstone/tripready.dart';

class SitesFoodList extends StatefulWidget {
  final DestinationModel destination;
  final String category;

  const SitesFoodList({Key key, this.destination, this.category})
      : super(key: key);

  @override
  _SitesFoodListState createState() => _SitesFoodListState();
}

class _SitesFoodListState extends State<SitesFoodList> {
  Future<QuerySnapshot> getFavorites() async {
    var uid = await AuthenticationService.currentUserId();

    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection('destinations')
        .document(widget.destination.documentID)
        .collection('favorites')
        .getDocuments();
  }

  Stream<QuerySnapshot> buildQueryStream(String destinationId) {
    return Firestore.instance
        .collection('destinations')
        .document(destinationId)
        .collection('activities')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var destinationId = this.widget.destination.documentID;

    var stream = buildQueryStream(destinationId);

    return Container(
      child: FutureBuilder(
        future: getFavorites(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> favoritesSnapshot) {
          return StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.documents.length > 0) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      var snapshotItem = snapshot.data.documents[index];
                      var activity = ActivityModel.fromSnapshot(snapshotItem);

                      var isFavorite = false;

                      if (favoritesSnapshot.hasData) {
                        isFavorite = favoritesSnapshot.data.documents.any(
                            (element) =>
                                element.documentID == activity.documentID);
                      }

                      var showTile = widget.category == ActivityCategories.favorites && isFavorite || 
                                     activity.category == widget.category;

                      return Visibility(
                        visible: showTile,
                        child: PhotoListViewTile(
                            context: context,
                            title: activity.name,
                            subtitle: activity.type,
                            imageUrl: activity.imageUrl,
                            isFavorite: isFavorite,
                            onFavorite: () async { 
                              await FavoritesService.toggleFavorite(widget.destination.documentID, activity.documentID);
                              setState(() {});
                            },
                            route: MaterialPageRoute(
                              builder: (_) => SitesFoodDetailScreen(
                                destination: widget.destination,
                                activity: activity,
                              ),
                            )),
                      );
                    },
                  );
                } else {
                  return Center(
                      child: Column(children: [
                    Text(
                        'No favorites. Please favorite an activity to show it here.')
                  ]));
                }
              });
        },
      ),
    );
  }
}
