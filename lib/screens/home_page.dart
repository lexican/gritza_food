import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/api/restaurant_api.dart';
import 'package:gritzafood/models/category_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';

import 'Restaurant/restaurant_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();

  RestaurantApi restaurantApi = new RestaurantApi();

  Stream<QuerySnapshot> getRestaurants() {
    return restaurantApi.streamDataCollection();
    // .where('categoryId', isEqualTo: categoryReference.doc(activeCategory))
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //   child: TextField(
          //     cursorColor: Colors.black,
          //     controller: searchController,
          //     textInputAction: TextInputAction.go,
          //     onTap: () async {
          //       showSearch(context: context, delegate: ItemSearchDelegate());
          //     },
          //     onSubmitted: (value) {
          //       //appState.sendRequest(value);
          //     },
          //     decoration: InputDecoration(
          //       border: new OutlineInputBorder(
          //         borderRadius: const BorderRadius.all(
          //           const Radius.circular(30.0),
          //         ),
          //       ),
          //       prefixIcon: Padding(
          //         padding: EdgeInsets.all(0.0),
          //         child: Icon(Icons.search),
          //       ),
          //       hintText: "Search",
          //       // border: InputBorder.none,
          //       fillColor: Color(0XFFfeeeeee),
          //       filled: true,
          //       contentPadding: EdgeInsets.only(
          //         left: 15.0,
          //         top: 14,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRestaurants(),
              builder: (context, stream) {
                if (stream.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: height - (70 + 58 + 24 + kToolbarHeight),
                      width: double.infinity,
                      child: Center(child: CircularProgressIndicator()));
                }

                if (stream.hasError) {
                  return Center(child: Text(stream.error.toString()));
                }
                if (stream.data.size == 0) {
                  return Container(
                    width: double.infinity,
                    //height: height - (35 + 58 + 24 + kToolbarHeight + 80),
                    child: Center(
                      child: Text(
                        "No product found",
                        style: TextStyle(fontFamily: "Roboto"),
                      ),
                    ),
                  );
                }
                QuerySnapshot querySnapshot = stream.data;
                return ListView.builder(
                    primary: true,
                    shrinkWrap: true,
                    itemCount: querySnapshot.size,
                    itemBuilder: (context, index) {
                      RestaurantModel restaurant = RestaurantModel.fromSnapshot(
                          querySnapshot.docs[index]);
                      return VerticalScrollView(restaurant: restaurant);
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}

class VerticalScrollView extends StatelessWidget {
  VerticalScrollView({this.restaurant});
  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    String specialty = restaurant.specialty.join(" \u{00B7} ");
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RestaurantFullPage(
                  restaurant: restaurant,
                )));
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 10, right: 10, left: 10, top: 10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 7,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: restaurant.background_url,
                    placeholder: (context, url) => Container(
                        height: 150,
                        child:
                            Center(child: const CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                        Center(child: const Icon(Icons.error)),
                    fadeOutDuration: const Duration(seconds: 1),
                    fadeInDuration: const Duration(seconds: 3),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(restaurant.restaurant_name,
                    style: GoogleFonts.roboto(
                        fontSize: 24, color: Colors.grey[800])),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(specialty,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.roboto(
                        fontSize: 16, color: Colors.grey[600])),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star_border,
                      color: Colors.grey[600],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("4.5"),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
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
    // TODO: implement buildResults
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
    // TODO: implement buildSuggestions
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
