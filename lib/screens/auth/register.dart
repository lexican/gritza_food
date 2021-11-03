import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

final DateTime timestamp = DateTime.now();

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);
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

  bool isLoading = false;
  bool isLoggedIn = false;
  final _formKey = GlobalKey<FormState>();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

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
                                          builder: (context) => const Home()),
                                      (_) => false),
                                  form.reset()
                                })
                            .catchError((err) => {
                                  showCenterShortToast("Email already exist"),
                                }))
                        .catchError((err) => {
                              showCenterShortToast("Email already exist"),
                            })
                });
      } else {
        showCenterShortToast("Password must match");
      }
    } else {
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
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
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
    final title = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Text("Create Account",
            style: TextStyle(
                color: Utils.primaryColor,
                fontSize: 32,
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 10,
        ),
        Text("Let’s get you started, this will only take a few seconds.",
            style: TextStyle(
                fontSize: 15,
                fontFamily: "Roboto",
                fontWeight: FontWeight.normal,
                color: Utils.lightGray))
      ],
    );
    final firstNameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'First Name',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
      onSaved: (value) => _firstName = value.trim(),
    );

    final lastNameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Last Name',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
      onSaved: (value) => _lastName = value.trim(),
    );

    final usernameField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Username',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
      onSaved: (value) => _username = value.trim(),
    );

    final emailField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Email',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: emailValidator,
      onSaved: (value) => _email = value.trim(),
    );

    final passwordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Password',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: pwdValidator,
      onSaved: (value) => _password = value.trim(),
    );

    final confirmPasswordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Confirm Password',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Utils.lightGray, width: 1.0),
            borderRadius: BorderRadius.circular(35.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: pwdValidator,
      onSaved: (value) => _confirmPassword = value.trim(),
    );

    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: validateAndSubmit,
        child: isLoading
            ? showCircularProgress()
            : Text("Sign Up",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
        backgroundColor: Utils.backgroundColor,
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  title,
                  const SizedBox(
                    height: 35,
                  ),
                  emailField,
                  const SizedBox(
                    height: 15,
                  ),
                  usernameField,
                  const SizedBox(
                    height: 15,
                  ),
                  firstNameField,
                  const SizedBox(
                    height: 15,
                  ),
                  lastNameField,
                  const SizedBox(
                    height: 15,
                  ),
                  passwordField,
                  const SizedBox(
                    height: 15,
                  ),
                  confirmPasswordField,
                  const SizedBox(
                    height: 20,
                  ),
                  registerButton,
                  //showCircularProgress(),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",
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
