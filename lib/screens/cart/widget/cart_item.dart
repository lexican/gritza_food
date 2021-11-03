import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/states/cart_state.dart';
import 'package:gritzafood/utils/utils.dart';
import 'package:provider/provider.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        height: 140,
        width: double.infinity,
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
                  placeholder: (context, url) =>  const SizedBox(
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
                SizedBox(
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
                        child: const Icon(Icons.clear),
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
                const SizedBox(
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
                                color: const Color(0xFFffb74d), width: 2.0),
                            //color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          height: 30.0,
                          width: 30.0,
                          child: const Center(
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
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("${categoriesSubModel.quantity}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: "Roboto",
                                  color:  Color(0xFF757575))),
                        )),
                    GestureDetector(
                      onTap: () => {
                        cartState.incrementQuantity(categoriesSubModel.cartId)
                      },
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFffb74d), width: 2.0),
                            //color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          height: 30.0,
                          width: 30.0,
                          child: const Center(
                              child:  Text(
                            "+",
                            style: TextStyle(
                                color:  Color(0xFFffb74d), fontSize: 20),
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
