import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gritzafood/screens/auth/home.dart';
import 'package:gritzafood/screens/checkout/checkout.dart';
import 'package:gritzafood/screens/location/address.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Location extends StatefulWidget {
  final String nextRoute;
  const Location({Key key, this.nextRoute}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  Widget showCircularProgress() {
    return const SizedBox();
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MapStates>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final continueButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Utils.primaryColor, //Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (widget.nextRoute == "Home") {
            if (appState.lastPosition == null) {
              showCenterShortToast("No delivery address selected");
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            } else if (appState.distance > 5000) {
               showCenterShortToast("We do not deliver to this location");
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            }
          } else {
            if (appState.lastPosition == null) {
              showCenterShortToast("No delivery address selected");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Checkout()));
            } else if (appState.distance > 5000) {
              showCenterShortToast("We do not deliver to this location");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Checkout()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Checkout()));
            }
          }
        },
        child: isLoading
            ? showCircularProgress()
            : const Text("Continue",
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
                child: SizedBox(
                  width: width,
                  height: height,
                ),
              ),
              appState.loading
                  ? const Center(
                      child: CircularProgressIndicator(),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: Colors.black,
                      controller: appState.locationController,
                      textInputAction: TextInputAction.go,
                      onTap: () async {
                        final sessionToken = const Uuid().v4();
                        await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken),
                        );
                      },
                      onSubmitted: (value) {
                        //appState.sendRequest(value);
                      },
                      decoration: const InputDecoration(
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      child: continueButton))
            ],
          ),
        ),
      ),
    ));
  }
}
