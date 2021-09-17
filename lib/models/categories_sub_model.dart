import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesSubModel {
  String name;
  String description;
  int price;
  String id;
  String image_url;
  int quantity;
  double total;
  bool available;
  String cartId;

  CategoriesSubModel(
      {this.name,
      this.description,
      this.price,
      this.id,
      this.image_url,
      this.quantity,
      this.total,
      this.available,
      this.cartId});

  factory CategoriesSubModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map getDocs = snapshot.data();
    return CategoriesSubModel(
        name: getDocs['name'],
        description: getDocs['description'],
        id: snapshot.id,
        price: getDocs['price'],
        image_url: getDocs['image_url'],
        quantity: 1,
        total: getDocs['price'].toDouble());
  }

  Map<dynamic, dynamic> toJson() => {
        //'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image_url': image_url,
        'available': available,
        'quantity': quantity,
        'total': total,
      };
}
