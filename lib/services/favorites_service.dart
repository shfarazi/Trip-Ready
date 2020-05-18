
import 'package:capstone/services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService
{
  static Future toggleFavorite(String destinationId, String activityId) async {
    var userId = await AuthenticationService.currentUserId(); 

    var collectionReference = Firestore.instance
          .collection('users')
          .document(userId)
          .collection('destinations')
          .document(destinationId)
          .collection('favorites');

    var documentReference = collectionReference.document(activityId);

    var document = await documentReference.get();

    if (document.exists) {
      documentReference.delete();
    } 
    else {
      await documentReference.setData(Map<String, dynamic>());
    }
  }
}