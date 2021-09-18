import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/screens/location/Location.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:provider/provider.dart';

class CartModal extends StatefulWidget {
  final CategoriesSubModel categoriesSubModel;
  const CartModal({Key key, this.categoriesSubModel}) : super(key: key);

  @override
  _CartModalState createState() => _CartModalState();
}

class _CartModalState extends State<CartModal> {
  CategoriesSubModel categoriesSubModel;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    categoriesSubModel = widget.categoriesSubModel;
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

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
        title: Text(
          "Cart",
          style: GoogleFonts.roboto(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: cartState.cartitems.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: cartState.cartitems.length,
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int i) {
                            return CategoryItem(
                                categoriesSubModel: cartState.cartitems[i]);
                          },
                        )
                      : Container(
                          child: Center(
                            child: Text("Your cart is currently empty"),
                          ),
                        )),
              Container(
                  //height: 150,
                  //color: Colors.red,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sub Total:",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Text(
                            "${"\u20A6" + Utils.moneyFormat(cartState.total.toInt().toString())}",
                            style: TextStyle(
                              color: Color(0xFF686868),
                              fontSize: 18,
                              //fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Fee:",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          Text(
                            "${"\u20A6"}0",
                            style: TextStyle(
                              color: Color(0xFF686868),
                              fontSize: 18,
                              //fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total:",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${"\u20A6" + Utils.moneyFormat(cartState.total.toInt().toString())}",
                            style: TextStyle(
                                color: Color(0xFF686868),
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                                //fontWeight: FontWeight.w800
                                ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(35.0),
                          color: Utils.primaryColor, //Color(0xff01A0C7),
                          child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              onPressed: () {
                                if (cartState.cartitems.length == 0) {
                                  Fluttertoast.showToast(
                                      msg: "Your cart is currently empty.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      timeInSecForIosWeb: 1);
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Location(
                                            nextRoute: "Checkout",
                                          )));
                                }
                              },
                              child: Text("Continue",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18))))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatefulWidget {
  final CategoriesSubModel categoriesSubModel;

  const CategoryItem({Key key, this.categoriesSubModel}) : super(key: key);
  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  CategoriesSubModel categoriesSubModel;
  @override
  void initState() {
    super.initState();
    categoriesSubModel = widget.categoriesSubModel;
  }

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    return GestureDetector(
      onTap: () {
        // showMaterialModalBottomSheet(
        //   expand: false,
        //   context: context,
        //   backgroundColor: Colors.transparent,
        //   builder: (context) => ModalFit(
        //     categoriesSubModel: categoriesSubModel,
        //   ),
        // );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        height: 140,
        width: double.infinity,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Container(
                width: 85,
                height: 200,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: categoriesSubModel.image_url,
                  placeholder: (context, url) => Container(
                      height: 120,
                      child: Center(child: const CircularProgressIndicator())),
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
            SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          categoriesSubModel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Utils.darkGray),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          cartState.removeItem(categoriesSubModel);
                        },
                        child: Container(child: Icon(Icons.clear)),
                      )
                      // IconButton(
                      //   onPressed: () {
                      //     cartState.removeItem(categoriesSubModel);
                      //   },
                      //   icon: Icon(Icons.clear),
                      // )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    categoriesSubModel.description,
                    maxLines: 1,
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
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => {
                        cartState.decrementQuantity(categoriesSubModel.cartId)
                      },
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFffb74d), width: 2.0),
                            //color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          height: 30.0,
                          width: 30.0,
                          child: Center(
                              child: Text(
                            '-',
                            style: TextStyle(
                                color: Color(0xFFffb74d), fontSize: 20),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("${categoriesSubModel.quantity}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: "Roboto",
                                  color: Color(0xFF757575))),
                        )),
                    GestureDetector(
                      onTap: () => {
                        cartState.incrementQuantity(categoriesSubModel.cartId)
                      },
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFffb74d), width: 2.0),
                            //color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          height: 30.0,
                          width: 30.0,
                          child: Center(
                              child: Text(
                            "+",
                            style: TextStyle(
                                color: Color(0xFFffb74d), fontSize: 20),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
