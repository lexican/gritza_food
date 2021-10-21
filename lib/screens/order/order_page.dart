import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/models/Order.dart';
import 'package:gritzafood/Utils/Utils.dart';
import 'package:gritzafood/api/order_api.dart';
import 'package:gritzafood/screens/order/order_full_page.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  OrderApi orderApi = new OrderApi();

  User currentUser;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
    currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: Text(
          "Orders",
          style: GoogleFonts.roboto(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          labelColor: Color(0xffFFFFFF),
          indicatorColor: Color(0xffFFFFFF),
          controller: _controller,
          tabs: [
            Tab(
              text: 'All',
            ),
            Tab(
              text: 'Pending',
            ),
            Tab(
              text: 'Completed',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: getOrders("All"),
            builder: (context, stream) {
              if (stream.connectionState == ConnectionState.waiting) {
                return Container(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return Container(
                    color: Color(0xfffafafa),
                    width: double.infinity,
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/cart.svg"),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "No orders yet",
                          style: TextStyle(fontFamily: "Roboto", fontSize: 18),
                        ),
                      ],
                    ));
              }
              QuerySnapshot querySnapshot = stream.data;
              return Container(
                color: Color(0xfffafafa),
                width: double.infinity,
                child: ListView.builder(
                    //reverse: true,
                    primary: false,
                    shrinkWrap: true,
                    itemCount: querySnapshot.size,
                    itemBuilder: (context, index) {
                      Order order =
                          Order.fromSnapshot(querySnapshot.docs[index]);
                      return Orderitem(order: order);
                    }),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getOrders("Pending"),
            builder: (context, stream) {
              if (stream.connectionState == ConnectionState.waiting) {
                return Container(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return Container(
                    width: double.infinity,
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/cart.svg"),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "No orders yet",
                          style: TextStyle(fontFamily: "Roboto", fontSize: 18),
                        ),
                      ],
                    ));
              }
              QuerySnapshot querySnapshot = stream.data;
              return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  //reverse: true,
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    Order order = Order.fromSnapshot(querySnapshot.docs[index]);
                    return Orderitem(order: order);
                  });
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getOrders("Completed"),
            builder: (context, stream) {
              if (stream.connectionState == ConnectionState.waiting) {
                return Container(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return Container(
                    width: double.infinity,
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/cart.svg"),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "No orders yet",
                          style: TextStyle(fontFamily: "Roboto", fontSize: 18),
                        ),
                      ],
                    ));
              }
              QuerySnapshot querySnapshot = stream.data;
              return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  //reverse: true,
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    Order order = Order.fromSnapshot(querySnapshot.docs[index]);
                    return Orderitem(order: order);
                  });
            },
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> getOrders(String s) {
    if (s == "Pending") {
      return orderApi.getDocumentByUserIdAndStatus(currentUser.uid, "Pending");
    } else if (s == "Completed") {
      print(s);
      return orderApi.getDocumentByUserIdAndStatus(
          currentUser.uid, "Completed");
    }
    return orderApi.getDocumentByUserId(currentUser.uid);
    //return orderApi.streamDataCollection();
  }
}

class Orderitem extends StatefulWidget {
  final Order order;

  const Orderitem({Key key, this.order}) : super(key: key);
  @override
  _OrderitemState createState() => _OrderitemState();
}

class _OrderitemState extends State<Orderitem> {
  Order order;
  String deliveryAddress = "";
  String formattedDateTime = "";
  Color color;
  @override
  void initState() {
    super.initState();
    order = widget.order;
    formattedDateTime =
        DateFormat('yyyy-MM-dd').format(widget.order.date.toDate());

    //print('$formattedDateTime');

    if (widget.order.status == "Pending") {
      color = Colors.yellow;
    } else if (widget.order.status == "Confirmed") {
      color = Utils.status_confirmed;
    } else {
      color = Utils.status_cacelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMaterialModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => OrderFullPage(id: order.id, order: order),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ref No.: " + order.reference,
              style: TextStyle(color: Utils.darkGray, fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Delivery Address: " + deliveryAddress,
              style: TextStyle(color: Utils.darkGray, fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              formattedDateTime,
              style: TextStyle(color: Utils.darkGray, fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4)),
              child: Text(
                order.status,
                style: TextStyle(color: Utils.darkGray, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
