import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gritzafood/Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
//final usersRef = FirebaseFirestore.instance.collection('users');

class ProfilePicsUpload extends StatefulWidget {
  final File image;
  ProfilePicsUpload({
    Key key,
    this.image,
  }) : super(key: key);

  @override
  _ProfilePicsUploadState createState() => _ProfilePicsUploadState();
}

class _ProfilePicsUploadState extends State<ProfilePicsUpload> {
  bool loading = false;
  Future<String> uploadFile() async {
    final String uuid = Uuid().v1();
    if (widget.image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profileImage')
        .child(uuid);

    uploadTask = ref.putFile(widget.image);

    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    //print("imageUrl:" + imageUrl.toString());
    return imageUrl.toString();
  }

  void showCenterShortToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  upload() async {
    setState(() {
      loading = true;
    });
    final User user = _auth.currentUser;
    print("user : " + user.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uploadFile().then((img) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"photoUrl": img})
          .then((result) => {
                showCenterShortToast("Profile updated"),
                prefs.setString('photoUrl', img),
                Navigator.of(context).pop("loadUser"),
                setState(() {
                  loading = false;
                })
              })
          .catchError((err) => {
                showCenterShortToast("An error just occured"),
                print(err),
                setState(() {
                  loading = false;
                })
              });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: Text(
          "Profile Picture Upload",
        ),
      ),
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Container(
                      height: 200,
                      width: 200,
                      child: Image.file(widget.image, fit: BoxFit.cover))),
              Center(
                child: GestureDetector(
                  onTap: () {
                    upload();
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Utils.primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: loading
                        ? CircularProgressIndicator()
                        : Text(
                            "Upload",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Roboto",
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
