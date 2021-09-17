import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String name;
  final dynamic userId;
  final String id;

  CategoryModel({this.userId, this.name, this.id});

  factory CategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map getDocs = snapshot.data();
    return CategoryModel(
        userId: getDocs['userId'], name: getDocs['name'], id: snapshot.id);
  }
}
