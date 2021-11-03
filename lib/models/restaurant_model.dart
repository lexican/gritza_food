import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final dynamic id;
  final String restaurantName;
  final String address;
  final String backgroundUrl;
  final dynamic userId;
  final dynamic specialty;
  final int deliveryFee;
  final int minOrder;
  final String deliveryTime;

  RestaurantModel(
      {this.id,
      this.address,
      this.backgroundUrl,
      this.restaurantName,
      this.userId,
      this.specialty,
      this.deliveryFee,
      this.minOrder,
      this.deliveryTime});

  factory RestaurantModel.fromSnapshot(DocumentSnapshot snaphot) {
    Map getDocs = snaphot.data();

    return RestaurantModel(
        id: snaphot.id,
        address: getDocs['address'],
        backgroundUrl: getDocs['backgroundUrl'],
        restaurantName: getDocs['name'],
        userId: getDocs['userId'],
        specialty: getDocs['specialty'],
        deliveryFee: getDocs['deliveryFee'],
        minOrder: getDocs['minOrder'],
        deliveryTime: getDocs['deliveryTime']);
  }
}
