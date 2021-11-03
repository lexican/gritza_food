import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesSubModel {
  String name;
  String description;
  int price;
  String id;
  String imageUrl;
  int quantity;
  double total;
  bool available;
  String cartId;

  CategoriesSubModel(
      {this.name,
      this.description,
      this.price,
      this.id,
      this.imageUrl,
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
        imageUrl: getDocs['image_url'],
        quantity: 1,
        total: getDocs['price'].toDouble());
  }

  Map<dynamic, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'available': available,
        'quantity': quantity,
        'total': total,
      };
}
