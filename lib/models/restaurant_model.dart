import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final dynamic id;
  final String restaurant_name;
  final String address;
  final String background_url;
  final dynamic userId;
  final dynamic specialty;
  final int delivery_fee;
  final int min_order;
  final String delivery_time;

  RestaurantModel(
      {this.id,
      this.address,
      this.background_url,
      this.restaurant_name,
      this.userId,
      this.specialty,
      this.delivery_fee,
      this.min_order,
      this.delivery_time});

  factory RestaurantModel.fromSnapshot(DocumentSnapshot snaphot) {
    Map getDocs = snaphot.data();

    return RestaurantModel(
        id: snaphot.id,
        address: getDocs['address'],
        background_url: getDocs['background_url'],
        restaurant_name: getDocs['name'],
        userId: getDocs['userId'],
        specialty: getDocs['specialty'],
        delivery_fee: getDocs['delivery_fee'],
        min_order: getDocs['min_order'],
        delivery_time: getDocs['delivery_time']);
  }
}
