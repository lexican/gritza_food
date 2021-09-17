import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gritzafood/Utils/Utils.dart';
import 'package:gritzafood/screens/profile/profile_picture_upload.dart';
import 'package:gritzafood/screens/splash_screens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

final TextEditingController emailController = TextEditingController();
final TextEditingController usernameController = TextEditingController();
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextStyle labelStyle =
      TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'SegoeUi');

  var displayName = "";
  var photoUrl = "";
  var username = "";
  var email = "";
  var firstname = "";
  var lastname = "";
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print("Called");
    loadUser();
  }

  loadUser() async {
    final User user = _auth.currentUser;
    print("user : " + user.toString());

    DocumentSnapshot doc = await usersRef.doc(user.uid).get();

    if (doc.exists) {
      //print("doc.data()['displayName'];" + doc.data()['displayName']);

      if (mounted) {
        setState(() {
          //displayName = doc.data()['displayName'];
          Map getDocs = doc.data();
          displayName = getDocs['displayName']
                  .split(' ')[0]
                  .substring(0, 1)
                  .toUpperCase() +
              getDocs['displayName'].split(' ')[0].substring(1) +
              " " +
              getDocs['displayName']
                  .split(' ')[1]
                  .substring(0, 1)
                  .toUpperCase() +
              getDocs['displayName'].split(' ')[1].substring(1);
          //photoUrl = doc.data()['photoUrl'];
          firstname = getDocs['displayName'].split(' ')[1];
          lastname = getDocs['displayName'].split(' ')[0];
          username = getDocs['username'];
          email = getDocs['email'];

          photoUrl = getDocs['photoUrl'];

          emailController.text = email;
          firstNameController.text = firstname;
          lastNameController.text = lastname;
          usernameController.text = username;
        });
      }
    }
  }

  logout() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('auth', false);
    prefs.remove('email');
    prefs.remove('displayName');
    prefs.remove('photoUrl');
    prefs.remove('id');
    prefs.remove('username');

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => SplashScreen()),
        (Route<dynamic> route) => false);
    print("User signed out of Google account");
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
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

  void validateAndSubmit() async {
    setState(() {
      isLoading = true;
    });
    final form = _formKey.currentState;
    form.save();
    if (validateAndSave()) {
      final User user = _auth.currentUser;
      //print("user : " + user.toString());

      SharedPreferences prefs = await SharedPreferences.getInstance();

      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update(
              {"displayName": lastname + " " + firstname, "username": username})
          .then((result) => {
                prefs.setBool('auth', true),
                showCenterShortToast("Profile updated"),
                prefs.setString('displayName', lastname + " " + firstname),
                prefs.setString('username', username),
                form.reset(),
                loadUser(),
                setState(() {
                  isLoading = false;
                })
              })
          .catchError((err) => {
                //showCenterShortToast("Email already exist"),
                setState(() {
                  isLoading = false;
                }),
                print(err)
              });
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget showCircularProgress() {
    if (isLoading == true) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePicsUpload(
                    image: File(pickedFile.path),
                  )),
        ).then((value) {
          // if value is true you get the result as bool else no result
          if (value != null) {
            setState(() {
              loadUser();
            });
            print("Value ${value.url.toString()}");
            print('Do something after getting result');
          } else {
            print('Do nothing');
          }
        });
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    List<Widget> items = [];

    items.add(
      TextFormField(
        decoration: InputDecoration(
          enabled: false,
          labelText: 'Username',
          labelStyle: labelStyle,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
          ),
          enabledBorder: new UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        onChanged: (String val) {
          username = val;
        },
        keyboardType: TextInputType.text,
        controller: usernameController,
        style: TextStyle(
            color: Colors.black87, fontSize: 14, fontFamily: 'Roboto'),
      ),
    );

    items.add(
      TextFormField(
        decoration: InputDecoration(
          enabled: false,
          labelText: 'Email',
          labelStyle: labelStyle,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Utils.primaryColor),
          ),
          enabledBorder: new UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        onChanged: (String val) {
          email = val;
        },
        keyboardType: TextInputType.text,
        controller: emailController,
        style: TextStyle(
            color: Colors.black87, fontSize: 14, fontFamily: 'Roboto'),
      ),
    );

    items.add(
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Firstname',
          labelStyle: labelStyle,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
          ),
          enabledBorder: new UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        onChanged: (String val) {
          firstname = val;
        },
        validator: (value) =>
            value.isEmpty ? 'First Name can\'t be empty' : null,
        keyboardType: TextInputType.text,
        controller: firstNameController,
        style: TextStyle(
            color: Colors.black87, fontSize: 14, fontFamily: 'Roboto'),
      ),
    );

    items.add(
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Lastname',
          labelStyle: labelStyle,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
          ),
          enabledBorder: new UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        onChanged: (String val) {
          lastname = val;
        },
        validator: (value) =>
            value.isEmpty ? 'Last Name can\'t be empty' : null,
        keyboardType: TextInputType.text,
        controller: lastNameController,
        style: TextStyle(
            color: Colors.black87, fontSize: 14, fontFamily: 'Roboto'),
      ),
    );

    items.add(SizedBox(
      height: 20,
    ));

    items.add(Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: validateAndSubmit,
        child: isLoading
            ? showCircularProgress()
            : Text("Update",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ));

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    alignment: Alignment.center,
                    //color: Colors.red,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            //decoration: new BoxDecoration(color: Colors.white),
                            alignment: Alignment.center,
                            height: 100,
                            width: 100,
                            child: photoUrl != ""
                                ? ClipOval(
                                    //borderRadius: BorderRadius.circular(40.0),
                                    child: CachedNetworkImage(
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      imageUrl: photoUrl,
                                      placeholder: (context, url) => Container(
                                          height: 100,
                                          width: 100,
                                          child: Center(child: Container())),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                              child: const Icon(Icons.error)),
                                      fadeOutDuration:
                                          const Duration(seconds: 1),
                                      fadeInDuration:
                                          const Duration(seconds: 3),
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/user.jpg')))),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Icon(Icons.camera_alt_rounded)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ...items,
                ],
              )),
        )),
      ),
    );
  }
}
