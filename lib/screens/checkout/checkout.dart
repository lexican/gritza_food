import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/Services/initialize_paystack.dart';
import 'package:gritzafood/Utils/Utils.dart';
import 'package:gritzafood/api/order_api.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/screens/auth/home.dart';
import 'package:gritzafood/screens/location/Location.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:gritzafood/states/map_states.dart';
import 'package:provider/provider.dart';

class Checkout extends StatefulWidget {
  final CategoriesSubModel categoriesSubModel;
  const Checkout({Key key, this.categoriesSubModel}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  CategoriesSubModel categoriesSubModel;
  int quantity = 1;
  Random random = new Random();

  var publicKey = FlutterConfig.get('PAYSTACK_PUBLIC_KEY').toString();
  var sk_test = FlutterConfig.get('PAYSTACK_TEST_KEY').toString();

  bool isGeneratingCode = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final plugin = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(publicKey: publicKey);
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

  chargeCard(double total, deliveryFee, context, cartState, appState) async {
    List<CategoriesSubModel> items = cartState.cartitems;
    OrderApi orderApi = new OrderApi();
    // final cartState = Provider.of<CartState>(context, listen: false);
    // final appState = Provider.of<MapStates>(context);
    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });
    User currentUser = _auth.currentUser;
    Map accessCode = await createAccessCode(sk_test, total, currentUser.email);

    print("accessCod: " + accessCode.toString());

    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });
    if (this.mounted) {
      Charge charge = Charge()
        ..amount = (total.toInt() + deliveryFee.toInt()) * 100
        ..accessCode = accessCode["data"]["access_code"]
        ..email = 'miamilexican@gmail.com';
      CheckoutResponse response = await plugin.checkout(
        context,
        //method: CheckoutMethod.bank, // Defaults to CheckoutMethod.selectable
        charge: charge,
      );

      final reference = response.reference;

      if (response.status == true) {
        print("Payment confirmed");
        print("Reference: $reference");

        //bloc.cartListSink.
        User currentUser = _auth.currentUser;

        orderApi.addDocument({
          'userId': FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid),
          'lat': appState.lastPosition.latitude,
          'lng': appState.lastPosition.longitude,
          'status': 'Pending',
          'reference': reference,
          'date': new DateTime.now(),
          'deliveryFee': deliveryFee,
          'total': total + deliveryFee,
          'restaurantId': cartState.restaurantDetails.id
        }).then((docRef) => {
              print("docRef: " + docRef.id),
              for (var i = 0; i < items.length; i++)
                {
                  orderApi.addSubDocuments({
                    'name': items[i].name,
                    'description': items[i].description,
                    'price': items[i].price,
                    'image_url': items[i].image_url,
                    'available': items[i].available,
                    'quantity': items[i].quantity,
                    'total': items[i].total
                  }, docRef.id)
                }
            });
        _showDialog();
        Fluttertoast.showToast(
            msg: "Order has been placed.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        cartState.removeAll();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false);
      } else {
        _showErrorDialog();
      }
    }
  }

  void _showErrorDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }

  Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Dialog successDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_box,
                color: Color(0XFF41aa5e),
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Payment has successfully',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'been made',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Your payment has been successfully",
                style: TextStyle(fontSize: 13),
              ),
              Text("processed.", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return successDialog(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    final appState = Provider.of<MapStates>(context);

    int randomNumber = random.nextInt(5000);
    double total = cartState.total;
    //var distance = appState.distance;
    var distance = randomNumber;
    double deliveryFee = 0.0;
    if (distance > 0 && distance <= 1000) {
      setState(() {
        deliveryFee = 500;
        total = cartState.total + 500;
      });
    } else if (distance > 1000 && distance <= 3500) {
      setState(() {
        deliveryFee = 1000;
        total = cartState.total + 1000;
      });
    } else {
      setState(() {
        deliveryFee = 1500;
        total = cartState.total + 1500;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Location(
                          nextRoute: "Checkout",
                        )));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delivery to",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              Text(appState.location, style: TextStyle(fontSize: 18))
            ],
          ),
        ),
        //body:
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
                            style:
                                TextStyle(fontSize: 16, color: Utils.lightGray),
                          ),
                          Text(
                            "${"\u20A6" + Utils.moneyFormat(cartState.total.toInt().toString())}",
                            style: TextStyle(
                              color: Utils.lightGray,
                              fontSize: 16,
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
                            style:
                                TextStyle(fontSize: 16, color: Utils.lightGray),
                          ),
                          Text(
                            "${"\u20A6"}" + deliveryFee.toString(),
                            style: TextStyle(
                              color: Utils.lightGray,
                              fontSize: 16,
                              //fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                      ),
                      appState.lastPosition == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "No Delivery Address yet",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red),
                                )
                              ],
                            )
                          : SizedBox(),
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
                                color: Utils.darkGray,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${"\u20A6" + Utils.moneyFormat(total.toInt().toString())}",
                            style: TextStyle(
                                color: Utils.darkGray,
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
                                // print("cartState.restaurantDetails.id" +
                                //     cartState.restaurantDetails.id);
                                chargeCard(cartState.total, deliveryFee,
                                    context, cartState, appState);
                              },
                              child: Text("Pay now",
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
      onTap: () {},
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
                      IconButton(
                        onPressed: () {
                          cartState.removeItem(categoriesSubModel);
                        },
                        icon: Icon(Icons.clear),
                      )
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
