import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/models/Order.dart';
import 'package:gritzafood/Utils/Utils.dart';
import 'package:gritzafood/api/order_api.dart';
import 'package:gritzafood/models/categories_sub_model.dart';

class OrderFullPage extends StatefulWidget {
  final String id;
  final Order order;
  OrderFullPage({Key key, this.id, this.order}) : super(key: key);

  @override
  _OrderFullPageState createState() => _OrderFullPageState();
}

class _OrderFullPageState extends State<OrderFullPage> {
  OrderApi orderApi = new OrderApi();
  String id = "";
  Order order;
  Color color;

  Stream<QuerySnapshot> getRestaurants() {
    return orderApi.getSubDocStreamDataCollection(widget.id);
    // .where('categoryId', isEqualTo: categoryReference.doc(activeCategory))
  }

  @override
  void initState() {
    super.initState();
    id = widget.id;
    order = widget.order;
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
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Utils.primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
          title: Text(
            "Order Full Page",
            style: GoogleFonts.roboto(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: getRestaurants(),
                  builder: (context, stream) {
                    if (stream.connectionState == ConnectionState.waiting) {
                      return Container(
                          height: height - (58 + 24 + kToolbarHeight),
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
                            "No order found.",
                            style:
                                TextStyle(fontSize: 18, fontFamily: "Roboto"),
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
                          CategoriesSubModel categoriesSubModel =
                              CategoriesSubModel.fromSnapshot(
                                  querySnapshot.docs[index]);
                          return CategoryItem(
                              categoriesSubModel: categoriesSubModel);
                        });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Color(0XFFeeeeee),
                child: Row(
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
                      "${"\u20A6" + Utils.moneyFormat(order.total.toInt().toString())}",
                      style: TextStyle(
                          color: Color(0xFF686868),
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                          //fontWeight: FontWeight.w800
                          ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Color(0XFFeeeeee),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status:",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
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
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                SizedBox(
                  height: 4,
                ),
                Text(
                  categoriesSubModel.quantity.toString(),
                  style:
                      GoogleFonts.roboto(fontSize: 16, color: Utils.lightGray),
                ),
                SizedBox(
                  height: 4,
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
              ],
            ))
          ],
        ),
      ),
    );
  }
}
