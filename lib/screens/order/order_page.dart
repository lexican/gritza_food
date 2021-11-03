import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/api/order_api.dart';
import 'package:gritzafood/models/Order.dart';
import 'package:gritzafood/screens/order/order_full_page.dart';
import 'package:gritzafood/screens/order/widget/empty_order.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  OrderApi orderApi = OrderApi();

  User currentUser;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Utils.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utils.primaryColor,
        title: Text(
          "Order History",
          style: GoogleFonts.roboto(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          labelColor: const Color(0xffFFFFFF),
          indicatorColor: const Color(0xffFFFFFF),
          controller: _controller,
          tabs: const [
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
                return SizedBox(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: const Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return const EmptyOrder();
              }
              QuerySnapshot querySnapshot = stream.data;
              return Container(
                color: const Color(0xfffafafa),
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
                return SizedBox(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: const Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return const EmptyOrder();
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
                return SizedBox(
                    height: height - (35 + 58 + 24 + kToolbarHeight),
                    width: double.infinity,
                    child: const Center(child: CircularProgressIndicator()));
              }

              if (stream.hasError) {
                return Center(child: Text(stream.error.toString()));
              }
              if (stream.data.size == 0) {
                return const EmptyOrder();
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
      return orderApi.getDocumentByUserIdAndStatus(
          currentUser.uid, "Completed");
    }
    return orderApi.getDocumentByUserId(currentUser.uid);
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

    if (widget.order.status == "Pending") {
      color = Colors.yellow;
    } else if (widget.order.status == "Confirmed") {
      color = Utils.statusConfirmed;
    } else {
      color = Utils.statusCancelled;
    }
    getaddress();
  }

  void getaddress() async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromCoordinates(order.lat, order.lng);
    setState(() {
      deliveryAddress = placemark[0].name;
    });
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Ref No: ",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  order.reference,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Delivery Address: ",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  deliveryAddress,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Date: ",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  formattedDateTime,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    order.status,
                    style: TextStyle(color: Utils.darkGray, fontSize: 12),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
