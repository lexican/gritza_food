import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/api/restaurant_api.dart';
import 'package:gritzafood/common/rating.dart';
import 'package:gritzafood/models/category_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';
import 'package:gritzafood/screens/cart/cart.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'Restaurant/restaurant_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();

  RestaurantApi restaurantApi = RestaurantApi();

  Stream<QuerySnapshot> getRestaurants() {
    return restaurantApi.streamDataCollection();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final appState = Provider.of<MapStates>(context);
    return Scaffold(
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRestaurants(),
              builder: (context, stream) {
                if (stream.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: height - (70 + 58 + 24 + kToolbarHeight),
                      width: double.infinity,
                      child: const Center(child: CircularProgressIndicator()));
                }

                if (stream.hasError) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/internet.svg"),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "No internet Connection",
                        style: TextStyle(fontFamily: "Roboto", fontSize: 18),
                      ),
                      const Text(
                        "Your internet connection is currently not available please check or try again.",
                        style: TextStyle(fontFamily: "Roboto", fontSize: 14),
                      ),
                    ],
                  ));
                }
                if (stream.data.size == 0) {
                  return const SizedBox(
                    width: double.infinity,
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
  const VerticalScrollView({Key key, this.restaurant}) : super(key: key);
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
        padding:
            const EdgeInsets.only(bottom: 10, right: 10, left: 10, top: 10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 7,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: restaurant.backgroundUrl,
                    placeholder: (context, url) => const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.error)),
                    fadeOutDuration: const Duration(seconds: 1),
                    fadeInDuration: const Duration(seconds: 3),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(restaurant.restaurantName,
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
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Text("4.5",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        )),
                    const SizedBox(
                      width: 3,
                    ),
                    RatingBarIndicator(
                      itemCount: 5,
                      rating: 4.5,
                      itemSize: 15,
                      itemBuilder: (context, index) {
                        return const Icon(
                          Icons.star,
                          color: Color(0xffF2C946),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
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
