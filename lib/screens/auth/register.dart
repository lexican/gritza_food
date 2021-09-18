import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gritzafood/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

final DateTime timestamp = DateTime.now();

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);
  //final String title;
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var _email = "";
  var _password = "";
  var _confirmPassword = "";
  var _firstName = "";
  var _lastName = "";
  var _username = "";

  var err = "";

  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // SharedPreferences _preferences;

  bool isLoading = false;
  bool isLoggedIn = false;
  final _formKey = new GlobalKey<FormState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  // @override
  // void intState() {
  //   super.initState();
  //   //isSignedIn();
  // }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    err = "";
    setState(() {
      isLoading = true;
    });
    final form = _formKey.currentState;
    form.save();
    if (validateAndSave()) {
      if (_password == _confirmPassword) {
        FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _username)
            .get()
            .then((QuerySnapshot querySnapshot) => {
                  if (querySnapshot.size > 0)
                    {
                      err = "Username already exist.",
                      print("Username is taken"),
                      showCenterShortToast("Username already exist"),
                    }
                  else
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _email, password: _password)
                        .then((currentUser) => FirebaseFirestore.instance
                            .collection("users")
                            .doc(currentUser.user.uid)
                            .set({
                              "id": currentUser.user.uid,
                              "username": _username,
                              "photoUrl": "",
                              "email": _email,
                              "displayName": _lastName + " " + _firstName,
                              "bio": "",
                              "timestamp": timestamp,
                            })
                            .then((result) => {
                                  prefs.setBool('auth', true),
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Home()),
                                      (_) => false),
                                  form.reset()
                                })
                            .catchError((err) => {
                                  showCenterShortToast("Email already exist"),
                                  print(err)
                                }))
                        .catchError((err) => {
                              showCenterShortToast("Email already exist"),
                              print(err)
                            })
                });
      } else {
        showCenterShortToast("Password must match");
      }
    } else {
      print("Invalid form");
    }
    setState(() {
      isLoading = false;
    });
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

  Widget showCircularProgress() {
    if (isLoading == true) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text("Sign Up",
            style: TextStyle(
                fontSize: 32,
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold)),
      ),
    );

    final firstNameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'First Name',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
      onSaved: (value) => _firstName = value.trim(),
    );

    final lastNameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Last Name',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
      onSaved: (value) => _lastName = value.trim(),
    );

    final usernameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Username',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
      onSaved: (value) => _username = value.trim(),
    );

    final emailField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Email',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: emailValidator,
      onSaved: (value) => _email = value.trim(),
    );

    final passwordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Password',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: pwdValidator,
      onSaved: (value) => _password = value.trim(),
    );

    final confirmPasswordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Confirm Password',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Utils.primaryColor, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),

          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: pwdValidator,
      onSaved: (value) => _confirmPassword = value.trim(),
    );

    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: validateAndSubmit,
        child: isLoading
            ? showCircularProgress()
            : Text("Sign Up",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    // Widget showLogo() {
    //   return new Hero(
    //     tag: 'hero',
    //     child: Padding(
    //       padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
    //       child: CircleAvatar(
    //         backgroundColor: Colors.transparent,
    //         radius: 48.0,
    //         child: Image.asset('assets/flutter-icon.png'),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  title,
                  SizedBox(
                    height: 0,
                  ),
                  emailField,
                  SizedBox(
                    height: 15,
                  ),
                  usernameField,
                  SizedBox(
                    height: 15,
                  ),
                  firstNameField,
                  SizedBox(
                    height: 15,
                  ),
                  lastNameField,
                  SizedBox(
                    height: 15,
                  ),
                  passwordField,
                  SizedBox(
                    height: 15,
                  ),
                  confirmPasswordField,
                  SizedBox(
                    height: 20,
                  ),
                  registerButton,
                  //showCircularProgress(),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          )),
                      TextButton(
                        child: Text("Login",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Utils.primaryColor)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
            )));
  }
}
