import 'package:cloud_firestore/cloud_firestore.dart';

//final FirebaseAuth _auth = FirebaseAuth.instance;
class OrderApi {
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("orders");

  Future<QuerySnapshot> getDataCollection() {
    return ref.orderBy("date").get();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.doc(id).get();
  }

  Stream<QuerySnapshot> getDocumentByUserId(String id) {
    return ref
        .where("userId",
            isEqualTo: FirebaseFirestore.instance.collection("users").doc(id))
        .snapshots();
  }

  Stream<QuerySnapshot> getDocumentByStatus(String status) {
    Query orderQuery = ref;
    return orderQuery
        .where("status", isEqualTo: status) //.orderBy("date", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getDocumentByUserIdAndStatus(String id, String status) {
    Query orderQuery = ref;
    return orderQuery
        .where("userId",
            isEqualTo: FirebaseFirestore.instance.collection("users").doc(id))
        .where("status", isEqualTo: status) //.orderBy("date", descending: true)
        .snapshots();
  }

  Future<void> removeDocument(String id) {
    return ref.doc(id).delete();
  }

  Future<DocumentReference> addDocument(Map<String, dynamic> data) {
    print("data: $data");
    return ref.add(data);
  }

  Future<void> updateDocument(Map<String, dynamic> data, String id) {
    return ref.doc(id).update(data);
  }

  Future<void> addSubDocuments(Map<String, dynamic> data, String id) {
    return ref.doc(id).collection('items').add(data);
  }
    Stream<QuerySnapshot> getSubDocStreamDataCollection(id) {
    return ref.doc(id).collection('items').snapshots();
  }
}
