import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/models/category_model.dart';

class CategoriesApi {
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("categories");

  Future<QuerySnapshot> getDataCollection() {
    return ref.get();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.doc(id).get();
  }

  Future<QuerySnapshot> getDocumentByName(String name) {
    return ref.where("name", isEqualTo: name).get();
  }

  Future<void> removeDocument(String id) {
    return ref.doc(id).delete();
  }

  Future<DocumentReference> addDocument(Map<String, dynamic> data) {
    return ref.add(data);
  }

  Future<void> updateDocument(Map<String, dynamic> data, String id) {
    return ref.doc(id).update(data);
  }

  Stream<QuerySnapshot> getDocumentByCategoryId(String id) {
    return ref.doc(id).collection("items").snapshots();
  }

  Future<List<CategoriesSubModel>> getDocumentListByCategoryId(id) async {
    QuerySnapshot qShot = await ref.doc(id).collection("items").get();
    return qShot.docs
        .map((doc) => CategoriesSubModel(
            price: doc['price'],
            image_url: doc['image_url'],
            description: doc['description'],
            id: doc.id,
            name: doc['name']))
        .toList();
  }

  Future<List<CategoryModel>> getDocumentByUserId(id) async {
    QuerySnapshot qShot = await ref.where("userId", isEqualTo: id).get();
    return qShot.docs
        .map<CategoryModel>((doc) => CategoryModel(
              name: doc['name'],
              userId: doc['userId'],
              id: doc.id,
            ))
        .toList();
  }
}
