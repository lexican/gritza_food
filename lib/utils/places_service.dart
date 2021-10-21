import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter_config/flutter_config.dart';
import 'package:gritzafood/models/place.dart';
import 'package:gritzafood/models/suggestion.dart';
import 'package:http/http.dart';

class PlaceApiProvider {
  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  final apiKey = FlutterConfig.get('GOOGLE_MAP_API_KEY');

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&language=$lang&key=$apiKey";

    final url = Uri.parse(request);
    Response response = await get(url);

    print("input" + input);
    print("Lang: " + lang);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print("result['status']" + result['status']);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(
                description: p['description'], placeId: p['place_id']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      print("Api error");
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlace(String placeId) async {
    var request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final url = Uri.parse(request);
    Response response = await get(url);

    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(
      double lat, double lng, String placeType) async {
    var request =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$apiKey';

    final url = Uri.parse(request);
    Response response = await get(url);

    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}
