import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/screens/cart/widget/cart_item.dart';
import 'package:gritzafood/screens/location/location.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:provider/provider.dart';

import 'widget/empty_cart.dart';

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
      backgroundColor: Utils.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: cartState.cartitems.isNotEmpty
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
                      : const EmptyCart()),
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sub Total:",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            "\u20A6" +
                                Utils.moneyFormat(
                                    cartState.total.toInt().toString()),
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14,
                              //fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Delivery Fee:",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            "${"\u20A6"}0",
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14,
                              //fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "\u20A6" +
                                Utils.moneyFormat(
                                    cartState.total.toInt().toString()),
                            style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                                //fontWeight: FontWeight.w800
                                ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(35.0),
                          color: cartState.cartitems.isNotEmpty
                              ? Colors.orange[300]
                              : Utils.primaryColor,
                          child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 15.0),
                              onPressed: () {
                                if (cartState.cartitems.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "Your cart is currently empty.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      timeInSecForIosWeb: 1);
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const Location(
                                            nextRoute: "Checkout",
                                          )));
                                }
                              },
                              child: const Text("Continue",
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
