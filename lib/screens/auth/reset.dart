import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gritzafood/Utils/Utils.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  String _email;
  final auth = FirebaseAuth.instance;
  bool isLoading = false;
  String err = "";

  final _formKey = new GlobalKey<FormState>();

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
    err = "";
    setState(() {
      isLoading = true;
    });
    final form = _formKey.currentState;
    form.save();
    if (validateAndSave()) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _email)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                if (querySnapshot.size > 0)
                  {
                    print("Email exist"),
                    auth.sendPasswordResetEmail(email: _email),
                    showCenterShortToast(
                        "A password reset link has been sent to your mail"),
                    Navigator.of(context).pop()
                  }
                else
                  {showCenterShortToast("Account does not exist")}
              });
    } else {
      print("Invalid form");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Utils.primaryColor,
            width: 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        hintText: 'Email',
      ),
      validator: Utils.validateEmail,
      onSaved: (value) => _email = value.trim(),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: emailField),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Utils.primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    child: Text('Reset'),
                    onPressed: () {
                      validateAndSubmit();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
