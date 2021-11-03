import 'package:flutter/material.dart';
import 'package:gritzafood/models/suggestion.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/places_service.dart';
import 'package:provider/provider.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }
  final dynamic sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column(
      children: const [],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final appState = Provider.of<MapStates>(context);
    void onSelect(placeId, description, appState) async {
      if (placeId != null) {
        final placeDetails =
            await PlaceApiProvider(sessionToken).getPlace(placeId);
        appState.goToPlace(placeDetails);
      }
    }

    return FutureBuilder(
      future: apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text((snapshot.data[index] as Suggestion).description),
                    onTap: () {
                      onSelect(
                          (snapshot.data[index] as Suggestion).placeId,
                          (snapshot.data[index] as Suggestion).description,
                          appState);
                      close(context, snapshot.data[index] as Suggestion);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : const Center(
                child: CircularProgressIndicator(),
              ),
    );
  }
}
