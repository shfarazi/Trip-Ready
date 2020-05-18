import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  String documentID;
  String destinationId;
  DateTime travelDate;
  
  PlanModel({this.documentID, this.destinationId, this.travelDate});

  PlanModel.fromSnapshot(DocumentSnapshot snapshot) {
    documentID = snapshot.documentID;
    destinationId = snapshot['destinationId'];
    travelDate = snapshot['travelDate'];
  }

  Map<String, dynamic> toMap() {
    return {
      'documentID': documentID,
      'destinationId': destinationId,
      'travelDate': travelDate,
    };
  }
}
