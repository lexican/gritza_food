import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gritzafood/models/User.dart' as modelUser;
import 'package:gritzafood/screens/auth/register.dart';
import 'package:gritzafood/screens/auth/reset.dart';
import 'package:gritzafood/screens/cart/cart.dart';
import 'package:gritzafood/screens/home_page.dart';
import 'package:gritzafood/screens/order/order_page.dart';
import 'package:gritzafood/screens/profile/profile.dart';
import 'package:gritzafood/screens/search/search.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final FirebaseAuth _auth = FirebaseAuth.instance;
final DateTime timestamp = DateTime.now();

modelUser.User currentUser;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  bool isLoading = false;
  bool isLoggedIn = false;

  String _email = "";
  String _password = "";

  final databaseReference = FirebaseFirestore.instance;

  final _formKey = new GlobalKey<FormState>();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    // Detects when user signed in

    getUser();
    // googleSignIn.onCurrentUserChanged.listen((account) {
    //   handleSignIn(account);
    // }, onError: (err) {
    //   print('Error signing in: $err');
    // });
    // // Reauthenticate user when app is opened
    // googleSignIn.signInSilently(suppressErrors: false).then((account) {
    //   handleSignIn(account);
    // }).catchError((err) {
    //   print('Error signing in: $err');
    // });
  }

  void _select(Choice choice) {
    if (choice.title == "Logout") {
      logout();
    }
  }

  Future getUser() async {
    // Initialize Firebase

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;

    final User user = _auth.currentUser;

    print("authSignedIn: " + authSignedIn.toString());

    if (authSignedIn == true) {
      if (user != null) {
        setState(() {
          isAuth = true;
        });
        // uid = user.uid;
        // name = user.displayName;
        // userEmail = user.email;
        // imageUrl = user.photoURL;
      } else {
        setState(() {
          isAuth = false;
        });
      }
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Search(),
    OrderPage(),
    Profile()
  ];

  onTap(int pageIndex) {
    setState(() {
      _selectedIndex = pageIndex;
    });
  }

  AppBar getAppBar(appState) {
    switch (_selectedIndex) {
      case 0:
        {
          return AppBar(
            backgroundColor: Utils.primaryColor,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery to",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
                Text(appState.location, style: TextStyle(fontSize: 18))
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CartModal(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              )
            ],
            //body:
          );
        }
        break;

      case 1:
        {
          return AppBar(
            backgroundColor: Utils.primaryColor,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery to",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
                Text(appState.location, style: TextStyle(fontSize: 18))
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CartModal(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              )
            ],
            //body:
          );
        }
        break;

      case 2:
        {
          return null;
        }

      case 3:
        {
          return AppBar(
            backgroundColor: Utils.primaryColor,
            title: Text(
              "Profile",
              style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              PopupMenuButton<Choice>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                        value: choice, child: Text(choice.title));
                  }).toList();
                },
              ),
            ],
          );
        }
        break;

      default:
        {
          return null;
        }
        break;
    }
  }

  Scaffold buildAuthScreen() {
    final appState = Provider.of<MapStates>(context);

    return Scaffold(
      appBar: getAppBar(appState),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: onTap,
          activeColor: Utils.primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.shopping_cart),
            // ),
            BottomNavigationBarItem(
              label: "Search",
              icon: Icon(
                Icons.search,
                //size: 35.0,
              ),
            ),
            BottomNavigationBarItem(
              label: "Orders",
              icon: Icon(Icons.shopping_cart),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(Icons.account_circle),
            ),
          ]),
    );
  }

  void validateAndSubmit() async {
    setState(() {
      isLoading = true;
    });
    final form = _formKey.currentState;
    form.save();
    if (validateAndSave()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);

        if (userCredential.user != null) {
          print("New Sign in: " + userCredential.user.uid);
          DocumentSnapshot doc =
              await usersRef.doc(userCredential.user.uid).get();
          currentUser = modelUser.User.fromSnapshot(doc);
          //print("${currentUser}");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('auth', true);

          prefs.setString('email', currentUser.email);
          prefs.setString('displayName', currentUser.displayName);
          prefs.setString('photoUrl', currentUser.photoUrl);
          prefs.setString('id', currentUser.id);
          prefs.setString('username', currentUser.username);

          setState(() {
            isAuth = true;
            isLoading = false;
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          showCenterShortToast("User does not exist.");
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          showCenterShortToast("Invalid username or password");
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  login() async {
    //googleSignIn.signIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User user = userCredential.user;

    if (user != null) {
      // Checking if email and name is null
      assert(user.uid != null);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User _currentUser = _auth.currentUser;
      assert(user.uid == _currentUser.uid);

      DocumentSnapshot doc = await usersRef.doc(user.uid).get();

      if (!doc.exists) {
        // 2) if the user doesn't exist, then we want to take them to the create account page
        // final username = await Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => CreateAccount()));

        // 3) get username from create account, use it to make new user document in users collection

        usersRef.doc(user.uid).set({
          "id": user.uid,
          "username": "",
          "photoUrl": user.photoURL,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": timestamp
        });
        doc = await usersRef.doc(user.uid).get();
      }
      currentUser = modelUser.User.fromSnapshot(doc);
      //print("${currentUser}");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);

      prefs.setString('email', currentUser.email);
      prefs.setString('displayName', currentUser.displayName);
      prefs.setString('photoUrl', currentUser.photoUrl);
      prefs.setString('id', currentUser.id);
      prefs.setString('username', currentUser.username);

      setState(() {
        isAuth = true;
      });

      //return 'Google sign in successful, User UID: ${user.uid}';
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      print("Valid form");
      return true;
    } else {
      print("Invalid form");
      return false;
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

  void showCenterShortToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        timeInSecForIosWeb: 1);
  }

  logout() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);

    // prefs.setString('email', "");
    // prefs.setString('displayName', "");
    // prefs.setString('photoUrl', currentUser.photoUrl);
    // prefs.setString('id', currentUser.id);
    // prefs.setString('username', currentUser.username);

    prefs.remove('email');
    prefs.remove('displayName');
    prefs.remove('photoUrl');
    prefs.remove('id');
    prefs.remove('username');

    print("User signed out of Google account");

    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => Home()), (_) => false);
  }

  Widget _signInButton() {
    return GestureDetector(
      onTap: () {
        login();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(35.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/images/google.jpg"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    final title = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Text("Sign In",
              style: TextStyle(
                  fontSize: 32,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold)),
        )
      ],
    );
    final emailField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(35.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35.0),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35.0),
          borderSide: BorderSide(
            color: Utils.primaryColor,
            width: 1.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        hintText: 'Email',
      ),
      validator: Utils.validateEmail,
      onSaved: (value) => _email = value.trim(),
    );

    final passwordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: new InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(35.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.primaryColor,
              width: 1.0,
            ),
          ),
          hintText: 'Password',
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) {
        if (value.length > 0) {
          return null;
        } else {
          return 'Password is required';
        }
      },
      onSaved: (value) => _password = value.trim(),
    );

    final forgetPassword = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ResetScreen()));
          },
          child: Text(
            "Forget Password?",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        )
      ],
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(35.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: validateAndSubmit,
        child: isLoading
            ? showCircularProgress()
            : Text("Login",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.white
                // gradient: LinearGradient(
                //   begin: Alignment.topRight,
                //   end: Alignment.bottomLeft,
                //   colors: [Colors.white, Colors.purple],
                // ),
                ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                title,
                SizedBox(
                  height: 35,
                ),
                emailField,
                SizedBox(
                  height: 15,
                ),
                passwordField,
                SizedBox(
                  height: 7,
                ),
                forgetPassword,
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 20,
                ),
                loginButton,
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 2,
                      color: Colors.grey,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                    )),
                    Container(
                      child: Text(
                        "Or",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          height: 2,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 20)),
                    )
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                _signInButton(),
                SizedBox(
                  height: 25,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Don't have an account yet?",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        )),
                    TextButton(
                      child: Text("Register",
                          style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Utils.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Register()));
                      },
                    ),
                  ],
                )

                // Center(
                //     child: Text("Don't have an account yet?",
                //         style: TextStyle(
                //           fontFamily: 'Roboto',
                //           fontWeight: FontWeight.w500,
                //         ))),
                // TextButton(
                //   child: Text("Register",
                //       style: GoogleFonts.roboto(
                //           fontSize: 18,
                //           fontWeight: FontWeight.w700,
                //           color: Colors.black)),
                //   onPressed: () {
                //     Navigator.of(context).push(
                //         MaterialPageRoute(builder: (context) => Register()));
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Logout', icon: Icons.admin_panel_settings),
];
