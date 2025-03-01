import 'package:cloud_firestore/cloud_firestore.dart';

class RecentOrder {
  final String? foodName;
  final DateTime? date;
  final String? status;

  RecentOrder({this.foodName, this.date, this.status});

  // Factory method to create an instance from Firestore data
  factory RecentOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RecentOrder(
      foodName: data['items'][0]['foodName'],
      date: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'],
    );
  }
}
