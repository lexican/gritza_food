import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gritzafood/models/place.dart';

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class MapStates with ChangeNotifier, DiagnosticableTreeMixin {
  // int _count = 0;
  //
  // int get count => _count;
  //
  // void increment() {
  //   _count++;
  //   notifyListeners();
  // }

  static LatLng _initialPosition;
  LatLng _lastPosition;
  bool locationServiceActive = true;
  bool _loading = true;
  String _location = "";
  double _distance = -1;

  GoogleMapController _mapController;
  GoogleMapController get mapController => _mapController;

  bool get loading => _loading;

  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  String get location => _location;
  double get distance => _distance;

  TextEditingController locationController = TextEditingController();

  MapStates() {
    _getUserLocation();
    _loadingInitialPosition();
  }

  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    _lastPosition = LatLng(position.latitude, position.longitude);
    calDistance();

    print(
        "the latitude is: ${position.longitude} and the longitude is: ${position.longitude} ");
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].name;
    _loading = false;
    //_loading = true;
    _location = placemark[0].name;

    double distance = await Geolocator().distanceBetween(6.4849781697593,
        3.352957023370103, 6.455028550938457, 3.3508100811908927);
    print("_distance: " + distance.toString());

    notifyListeners();
  }

  void isLoading(bool value) {
    //bool _loading = value;
    notifyListeners();
  }

  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    calDistance();
    notifyListeners();
  }

  void onTap(double lat, double lng) async {
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(lat, lng);
    _initialPosition = LatLng(lat, lng);
    _lastPosition = LatLng(lat, lng);
    calDistance();

    print(
        "the latitude is: $lat and the longitude is: $lng ");
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].name;
    _loading = false;
    //_loading = true;
    _location = placemark[0].name;
  }

  // void isLoading(value){
  //  _loading = value;
  //  notifyListeners();
  // }

  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }

  void calDistance() async {
    if (_lastPosition != null) {
      _distance = await Geolocator().distanceBetween(6.4849781697593,
          3.352957023370103, _lastPosition.latitude, _lastPosition.longitude);
    } else {
      _distance = -1;
    }
    notifyListeners();
  }

  void goToPlace(Place place) async {
    print("Place:" + place.name);
    locationController.text = place.name;
    _location = place.name;
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
    _lastPosition =
        LatLng(place.geometry.location.lat, place.geometry.location.lng);
    calDistance();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(IntProperty('count', count));
  // }
}
