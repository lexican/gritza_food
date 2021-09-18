import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gritzafood/api/restaurant_api.dart';
import 'package:gritzafood/models/category_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';
import 'package:gritzafood/screens/restaurant/restaurant_details_page.dart';
import 'package:gritzafood/utils/utils.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
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
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.search,
                      color: Utils.lightGray,
                    ),
                  ),
                  hintText: "Search",
                  // border: InputBorder.none,
                  fillColor: Color(0XFFfeeeeee),
                  filled: true,
                  contentPadding: EdgeInsets.only(
                    left: 15.0,
                    top: 14,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Utils.lightGray, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate<CategoryModel> {
  RestaurantApi restaurantApi = new RestaurantApi();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: restaurantApi.streamDataCollection(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
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
                .where((element) => element.restaurant_name.startsWith(query))
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
                    restaurantmodel.restaurant_name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff212121)),
                  ),
                  Divider()
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
            return Center(
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
                  .where((element) => element.restaurant_name
                      .toUpperCase()
                      .contains(query.toUpperCase()))
                  .toList();

          return myList.isEmpty
              ? Container(
                  width: width,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Center(
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
                            restaurantmodel.restaurant_name,
                            style: TextStyle(
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
