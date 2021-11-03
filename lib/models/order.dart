import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  dynamic userId;
  double lat;
  double lng;
  String status;
  String reference;
  dynamic date;
  String id;
  double deliveryFee;
  double total;
  String restaurantId;

  Order(
      {this.userId,
      this.id,
      this.lat,
      this.date,
      this.lng,
      this.reference,
      this.status,
      this.deliveryFee,
      this.total,
      this.restaurantId});
  factory Order.fromSnapshot(DocumentSnapshot doc) {
    Map getDocs = doc.data();
    return Order(
        id: doc.id,
        userId: getDocs['userId'],
        lat: getDocs['lat'].toDouble(),
        lng: getDocs['lng'].toDouble(),
        status: getDocs['status'],
        reference: getDocs['reference'],
        date: getDocs['date'],
        deliveryFee: getDocs['deliveryFee'].toDouble(),
        total: getDocs['total'].toDouble(),
        restaurantId: getDocs['restaurantId']);
  }
}
