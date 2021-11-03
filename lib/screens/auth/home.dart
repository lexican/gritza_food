import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: library_prefixes
import 'package:gritzafood/models/User.dart' as modelUser;
import 'package:gritzafood/screens/auth/register.dart';
import 'package:gritzafood/screens/auth/reset.dart';
import 'package:gritzafood/screens/home_page.dart';
import 'package:gritzafood/screens/order/order_page.dart';
import 'package:gritzafood/screens/profile/profile.dart';
import 'package:gritzafood/screens/search/search.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final FirebaseAuth _auth = FirebaseAuth.instance;
final DateTime timestamp = DateTime.now();

modelUser.User currentUser;

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

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

  final _formKey = GlobalKey<FormState>();

  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool authSignedIn = prefs.getBool('auth') ?? false;

    final User user = _auth.currentUser;

    if (authSignedIn == true) {
      if (user != null) {
        setState(() {
          isAuth = true;
        });
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

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Search(),
    const OrderPage(),
    const Profile()
  ];

  void onTap(int pageIndex) {
    setState(() {
      _selectedIndex = pageIndex;
    });
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      backgroundColor: Utils.backgroundColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: onTap,
          activeColor: Utils.primaryColor,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
              "assets/icon/home.svg",
              color: _selectedIndex == 0 ? Utils.primaryColor : Colors.grey,
            )),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icon/search.svg",
                color: _selectedIndex == 1 ? Utils.primaryColor : Colors.grey,
                height: 26,
                width: 26,
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icon/order.svg",
                color: _selectedIndex == 2 ? Utils.primaryColor : Colors.grey,
              ),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icon/profile.svg",
                color: _selectedIndex == 3 ? Utils.primaryColor : Colors.grey,
              ),
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
          //print("New Sign in: " + userCredential.user.uid);
          DocumentSnapshot doc =
              await usersRef.doc(userCredential.user.uid).get();
          currentUser = modelUser.User.fromSnapshot(doc);
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
          //print('No user found for that email.');
          showCenterShortToast("User does not exist.");
        } else if (e.code == 'wrong-password') {
          //print('Wrong password provided for that user.');
          showCenterShortToast("Invalid username or password");
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void login() async {
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
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      //print("Valid form");
      return true;
    } else {
      // print("Invalid form");
      return false;
    }
  }

  Widget showCircularProgress() {
    if (isLoading == true) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox();
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

  void logout() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);

    prefs.remove('email');
    prefs.remove('displayName');
    prefs.remove('photoUrl');
    prefs.remove('id');
    prefs.remove('username');

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => const Home()), (_) => false);
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Image(image: AssetImage("assets/images/google.jpg"), height: 30.0),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 14,
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
    final title = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Text("Sign In",
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
    final emailField = TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(35.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35.0),
          borderSide: BorderSide(
            color: Utils.lightGray,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        hintText: 'Email',
      ),
      validator: Utils.validateEmail,
      onSaved: (value) => _email = value.trim(),
    );

    final passwordField = TextFormField(
      maxLines: 1,
      obscureText: true,
      autofocus: false,
      decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(35.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35.0),
            borderSide: BorderSide(
              color: Utils.lightGray,
              width: 1.0,
            ),
          ),
          hintText: 'Password',
          contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      validator: (value) {
        if (value.isNotEmpty) {
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
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ResetScreen()));
          },
          child: const Text(
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
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
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
      backgroundColor: Utils.backgroundColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                title,
                const SizedBox(
                  height: 35,
                ),
                emailField,
                const SizedBox(
                  height: 15,
                ),
                passwordField,
                const SizedBox(
                  height: 7,
                ),
                forgetPassword,
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
                loginButton,
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 2,
                      color: Colors.grey,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    )),
                    const Text(
                      "Or",
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: Container(
                          height: 2,
                          color: Colors.grey,
                          margin: const EdgeInsets.symmetric(horizontal: 20)),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                _signInButton(),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Don't have an account yet?",
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
                            builder: (context) => const Register()));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
