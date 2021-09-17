import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gritzafood/screens/auth/home.dart';
import 'package:gritzafood/screens/checkout/checkout.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'Address.dart';

class Location extends StatefulWidget {
  final String nextRoute;
  Location({Key key, this.nextRoute}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  void initState() {
    super.initState();
  }

  //
  bool isLoading = false;
  //
  // final _formKey = new GlobalKey<FormState>();

  Widget showCircularProgress() {
    // if (isLoading == true) {
    //   return Center(child: CircularProgressIndicator());
    // }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  // bool validateAndSave() {
  //   final form = _formKey.currentState;
  //   form.save();
  //   if (form.validate()) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MapStates>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // final toField = TextFormField(
    //   maxLines: 1,
    //   keyboardType: TextInputType.text,
    //   autofocus: false,
    //   decoration: new InputDecoration(
    //       hintText: 'Enter Area',
    //       fillColor: Color(0xFFFFFFFF),
    //       filled: true,
    //       focusedBorder: OutlineInputBorder(
    //         //borderRadius: BorderRadius.circular(35.0),
    //         borderSide: BorderSide(
    //           color: Colors.blue,
    //         ),
    //       ),
    //       errorBorder: OutlineInputBorder(
    //         borderSide: BorderSide(color: Colors.red, width: 2.0),
    //         //borderRadius: BorderRadius.circular(35.0),
    //       ),
    //       border: OutlineInputBorder(
    //         //borderRadius: BorderRadius.circular(35.0),
    //         borderSide: BorderSide(
    //           color: Utils.primaryColor,
    //           width: 2.0,
    //         ),
    //       ),
    //       contentPadding: EdgeInsets.symmetric(horizontal: 20)),
    //   validator: (value) => value.isEmpty ? 'Area can\'t be empty' : null,
    //   //onSaved: (value) => _area = value.trim(),
    //   onTap: () async {},
    //   controller: appState.locationController,
    // );

    final continueButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width - 40,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (widget.nextRoute == "Home") {
            if (appState.lastPosition == null) {
              Fluttertoast.showToast(
                  msg: "No delivery address selected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            } else if (appState.distance > 5000) {
              Fluttertoast.showToast(
                  msg: "We do not deliver to this location",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            } else {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }
          } else {
            if (appState.lastPosition == null) {
              Fluttertoast.showToast(
                  msg: "No delivery address selected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Checkout()));
            } else if (appState.distance > 5000) {
              Fluttertoast.showToast(
                  msg: "We do not deliver to this location",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Checkout()));
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Checkout()));
            }
          }
        },
        child: isLoading
            ? showCircularProgress()
            : Text("Continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 18)),
      ),
    );

    return Scaffold(
        body: SafeArea(
      child: Container(
        height: height,
        width: width,
        color: Colors.white,
        child: Form(
          //key: _formKey,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: width,
                  height: height,
                  //color: Colors.green,
                  // child: Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [fromField, toField],
                  // ),
                ),
              ),
              appState.loading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : appState.initialPosition != null
                      ? GoogleMap(
                          onTap: (tapped) async {
                            appState.onTap(tapped.latitude, tapped.longitude);
                          },
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: appState.initialPosition, zoom: 10.0),
                          onMapCreated: appState.onCreated,
                          onCameraMove: appState.onCameraMove,
                        )
                      : Container(),
              Container(
                width: width,
                height: 100,
                //color: Utils.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: Colors.black,
                      controller: appState.locationController,
                      textInputAction: TextInputAction.go,
                      onTap: () async {
                        final sessionToken = Uuid().v4();
                        await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken),
                        );
                      },
                      onSubmitted: (value) {
                        //appState.sendRequest(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(Icons.place),
                        ),
                        hintText: "City, state or zip code?",
                        border: InputBorder.none,
                        fillColor: Color(0xFFFFFFFF),
                        filled: true,
                        contentPadding: EdgeInsets.only(
                          left: 15.0,
                          top: 14,
                        ),
                      ),
                    ),

                    //toField
                  ],
                ),
              ),
              Positioned(
                  bottom: 20,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: continueButton))
            ],
          ),
        ),
      ),
    ));
  }
}
