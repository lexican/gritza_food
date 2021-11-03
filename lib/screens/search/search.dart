import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gritzafood/api/restaurant_api.dart';
import 'package:gritzafood/models/category_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';
import 'package:gritzafood/screens/cart/cart.dart';
import 'package:gritzafood/screens/restaurant/restaurant_details_page.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MapStates>(context);
    return Scaffold(
      backgroundColor: Utils.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery to",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            Text(appState.location, style: const TextStyle(fontSize: 18))
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showMaterialModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const CartModal(),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(right: 10),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          )
        ],
        //body:
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              cursorColor: Colors.black,
              controller: searchController,
              textInputAction: TextInputAction.go,
              onTap: () async {
                showSearch(context: context, delegate: ItemSearchDelegate());
              },
              onSubmitted: (value) {},
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.search,
                    color: Utils.lightGray,
                  ),
                ),
                hintText: "Search",
                // fillColor: const Color(0XFFfeeeee),
                // filled: true,
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
                contentPadding: const EdgeInsets.only(
                  left: 15.0,
                  top: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate<CategoryModel> {
  RestaurantApi restaurantApi = RestaurantApi();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: restaurantApi.streamDataCollection(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<RestaurantModel> items = snapshot.data.docs
            .map<RestaurantModel>((DocumentSnapshot document) {
          return RestaurantModel.fromSnapshot(document);
        }).toList();
        final myList = query.isEmpty
            ? items
            : items
                .where((element) => element.restaurantName.startsWith(query))
                .toList();

        return ListView.builder(
          itemCount: myList.length,
          itemBuilder: (context, index) {
            final RestaurantModel restaurantmodel = myList[index];
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantmodel.restaurantName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff212121)),
                  ),
                  const Divider()
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: restaurantApi.streamDataCollection(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<RestaurantModel> items = snapshot.data.docs
              .map<RestaurantModel>((DocumentSnapshot document) {
            return RestaurantModel.fromSnapshot(document);
          }).toList();

          final myList = query.isEmpty
              ? items
              : items
                  .where((element) => element.restaurantName
                      .toUpperCase()
                      .contains(query.toUpperCase()))
                  .toList();

          return myList.isEmpty
              ? Container(
                  width: width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: const Center(
                    child: Text(
                      "No Result Found",
                      style: TextStyle(fontSize: 16),
                    ),
                  ))
              : ListView.builder(
                  itemCount: myList.length,
                  itemBuilder: (context, index) {
                    final RestaurantModel restaurantmodel = myList[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RestaurantFullPage(
                                  restaurant: restaurantmodel,
                                )));
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantmodel.restaurantName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff212121)),
                          ),
                        ],
                      ),
                    );
                  },
                );
        });
  }
}
