import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/Utils/utils.dart';
import 'package:gritzafood/api/categories_api.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/models/category_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';
import 'package:gritzafood/screens/cart/cart.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

CategoriesApi categoriesApi = CategoriesApi();

class RestaurantFullPage extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantFullPage({Key key, this.restaurant}) : super(key: key);
  @override
  _RestaurantFullPageState createState() => _RestaurantFullPageState();
}

class _RestaurantFullPageState extends State<RestaurantFullPage> {
  RestaurantModel restaurant;

  List<CategoryModel> products = [];
  List<CategoryModel> categories = [];

  dynamic activeCategory = "0";
  @override
  void initState() {
    super.initState();
    restaurant = widget.restaurant;
    getCategories("0");
  }

  void getCategories(String id) async {
    setState(() {
      activeCategory = id;
      products = [];
    });
    if (id == "0") {
      List<CategoryModel> itemsx =
          await categoriesApi.getDocumentByUserId(restaurant.userId);
      setState(() {
        products = itemsx;
        categories = itemsx;
      });
    } else {
      CategoryModel item =
          CategoryModel.fromSnapshot(await categoriesApi.getDocumentById(id));
      //print("item Name Here: " + item.name);
      setState(() {
        products = [item];
      });
    }
  }

  List<Widget> _buildProducts() {
    return products.map<Widget>((doc) {
      return BuildCategoriesList(
        categoryModel: doc,
        restaurant: restaurant,
      );
    }).toList();
  }

  Widget _buildCategory() {
    //print("items: " + categories.length.toString());
    final List<Widget> children = categories.map<Widget>((doc) {
      return category(doc.name, doc.id);
    }).toList();
    return SliverToBoxAdapter(
      child: Container(
          height: 35,
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: [category("All", "0"), ...children])),
    );
  }

  Widget category(String categoryname, dynamic id) {
    return GestureDetector(
      onTap: () => {getCategories(id)},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
            color: activeCategory == id ? Utils.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: Text(
            categoryname,
            style: const TextStyle(
                fontFamily: "Roboto", fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    String sep = "\u{00B7}";
    String info =
        "4.5 $sep Min Order  ${Utils.nairaCode} ${restaurant.minOrder.toString()} $sep Delivery fee  ${Utils.nairaCode} ${restaurant.deliveryFee}";
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Utils.backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Utils.primaryColor,
                expandedHeight: 270,
                floating: true,
                pinned: true,
                title: Text(restaurant.restaurantName,
                    style: GoogleFonts.roboto(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                  children: [
                    CachedNetworkImage(
                      height: 210,
                      width: width,
                      //colorBlendMode: ColorBle,
                      fit: BoxFit.cover,
                      imageUrl: restaurant.backgroundUrl,
                      placeholder: (context, url) => const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                      fadeOutDuration: const Duration(seconds: 1),
                      fadeInDuration: const Duration(seconds: 3),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 100,
                        width: width,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(restaurant.restaurantName,
                                style: GoogleFonts.roboto(
                                    fontSize: 20,
                                    color: Utils.darkGray,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 6,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.star_border,
                                  color: Colors.grey[600],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(info),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        right: 20,
                        bottom: 75,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          height: 50,
                          width: 130,
                          child: Center(
                            child: Text(
                              restaurant.deliveryTime + " min",
                              style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Utils.darkGray,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ))
                  ],
                )),
              ),
              _buildCategory(),
              ..._buildProducts()
            ],
          ),
        ),
        bottomNavigationBar: //cartState.cartitems.length > 0
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
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 50,
            color: Colors.green,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    cartState.cartitems.length.toString() +
                        (cartState.cartitems.length.toString() == "1"
                            ? " item"
                            : " items"),
                    style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(
                  "VIEW CART",
                  style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "\u20A6 " +
                      Utils.moneyFormat(cartState.total.toInt().toString()),
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        )
        //: Container(Text),
        );
  }
}

class BuildCategoriesList extends StatefulWidget {
  final CategoryModel categoryModel;
  final RestaurantModel restaurant;

  const BuildCategoriesList({Key key, this.categoryModel, this.restaurant})
      : super(key: key);
  @override
  _BuildCategoriesListState createState() => _BuildCategoriesListState();
}

class _BuildCategoriesListState extends State<BuildCategoriesList> {
  CategoryModel categoryModel;
  List<CategoriesSubModel> items = [];
  RestaurantModel restaurant;
  @override
  void initState() {
    super.initState();
    categoryModel = widget.categoryModel;
    restaurant = widget.restaurant;
    getItems();
  }

  void getItems() async {
    List<CategoriesSubModel> itemsx =
        await categoriesApi.getDocumentListByCategoryId(categoryModel.id);
    setState(() {
      items = itemsx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = items.map<Widget>((doc) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: CategoryItem(
          categoriesSubModel: doc,
          categoryModel: categoryModel,
          restaurant: restaurant,
        ),
      );
    }).toList();

    return SliverList(
        delegate: SliverChildListDelegate([
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          categoryModel.name,
          style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold),
        ),
      ),
      ...children
    ]));
  }
}

class CategoryItem extends StatefulWidget {
  final CategoriesSubModel categoriesSubModel;
  final CategoryModel categoryModel;
  final RestaurantModel restaurant;
  const CategoryItem(
      {Key key, this.categoriesSubModel, this.categoryModel, this.restaurant})
      : super(key: key);
  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  CategoriesSubModel categoriesSubModel;
  CategoryModel categoryModel;
  RestaurantModel restaurant;
  @override
  void initState() {
    super.initState();
    categoriesSubModel = widget.categoriesSubModel;
    categoryModel = widget.categoryModel;
    restaurant = widget.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMaterialModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => ModalFit(
            categoriesSubModel: categoriesSubModel,
            categoryModel: categoryModel,
            restaurant: restaurant,
          ),
        );
      },
      child: Container(
        height: 125,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 85,
                height: 200,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: categoriesSubModel.imageUrl,
                  placeholder: (context, url) => const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Center(
                      child: Container(
                    color: Colors.white,
                    height: 150,
                  )),
                  fadeOutDuration: const Duration(seconds: 1),
                  fadeInDuration: const Duration(seconds: 3),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 4,
                ),
                Text(
                  categoriesSubModel.name.trim(),
                  maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Utils.darkGray),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    categoriesSubModel.description.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                        fontSize: 14, color: Utils.lightGray),
                  ),
                ),
                Text(
                  "\u20A6 " +
                      Utils.moneyFormat(categoriesSubModel.price.toString()),
                  style:
                      GoogleFonts.roboto(fontSize: 16, color: Utils.lightGray),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class ModalFit extends StatefulWidget {
  final CategoriesSubModel categoriesSubModel;
  final CategoryModel categoryModel;
  final RestaurantModel restaurant;
  const ModalFit(
      {Key key, this.categoryModel, this.categoriesSubModel, this.restaurant})
      : super(key: key);

  @override
  _ModalFitState createState() => _ModalFitState();
}

class _ModalFitState extends State<ModalFit> {
  CategoriesSubModel categoriesSubModel;
  CategoryModel categoryModel;
  int quantity = 1;
  RestaurantModel restaurant;

  @override
  void initState() {
    super.initState();
    categoriesSubModel = widget.categoriesSubModel;
    categoryModel = widget.categoryModel;
    restaurant = widget.restaurant;
  }

  void increment() {
    setState(() {
      quantity += 1;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity -= 1;
      });
    }
  }

  void showAlertDialog(BuildContext context, cartState) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        cartState.removeAll();
        // print("Cart cleared");
        // print("First Item");
        cartState.setRestuarantDetails(restaurant);
        categoriesSubModel.quantity = quantity;
        categoriesSubModel.total =
            (categoriesSubModel.price * quantity).toDouble();
        cartState.addToList(categoriesSubModel);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Confirm"),
      content: const Text(
          "Your cart contains items from another restaurant. Would you like to empty your cart to continue?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = categoriesSubModel.price * quantity;
    final cartState = Provider.of<CartState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          categoriesSubModel.name,
          style: GoogleFonts.roboto(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: categoriesSubModel.imageUrl,
                    placeholder: (context, url) => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => Center(
                        child: Container(
                      color: Colors.white,
                      height: 150,
                    )),
                    fadeOutDuration: const Duration(seconds: 1),
                    fadeInDuration: const Duration(seconds: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    decrement();
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text("-",
                          style: GoogleFonts.roboto(
                              fontSize: 24,
                              color: quantity == 1
                                  ? Utils.lightGray
                                  : Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                quantity == 1 ? Utils.lightGray : Colors.green,
                            width: 2)),
                  )),
              SizedBox(
                width: 60,
                child: Center(
                  child: Text(
                    quantity.toString(),
                    style: GoogleFonts.roboto(
                        fontSize: 24,
                        color: Utils.darkGray,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    increment();
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text("+",
                          style: GoogleFonts.roboto(
                              fontSize: 24,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2)),
                  )),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () {
                        if (cartState.restaurantDetails == null) {
                          //print("First Item");
                          cartState.setRestuarantDetails(restaurant);
                          categoriesSubModel.quantity = quantity;
                          categoriesSubModel.total = total.toDouble();
                          cartState.addToList(categoriesSubModel);
                          Navigator.of(context).pop();
                        } else {
                          // print("cartState.restaurantDetails.id :" +
                          //     cartState.restaurantDetails.id);
                          // print("categoryModel.id: " + categoryModel.id);
                          if (cartState.restaurantDetails.userId ==
                              categoryModel.userId) {
                            //print("Same restaurant");
                            categoriesSubModel.quantity = quantity;
                            categoriesSubModel.total = total.toDouble();
                            cartState.addToList(categoriesSubModel);
                            Navigator.of(context).pop();
                          } else {
                            showAlertDialog(context, cartState);
                            //print("Different restaurant");
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                "\u20A6 " + Utils.moneyFormat(total.toString()),
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 4,
                            ),
                            Text("ADD TO CART",
                                style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
