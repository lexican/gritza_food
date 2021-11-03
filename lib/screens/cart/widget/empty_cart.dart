import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset("assets/svg/cart.svg"),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Your Cart is empty",
          style: TextStyle(
              fontFamily: "Roboto", fontSize: 18, color: Color(0xFF333333)),
        ),
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Your cart is empty, go to homepage and select a meal to place an order",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Roboto", fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ),
      ],
    );
  }
}
