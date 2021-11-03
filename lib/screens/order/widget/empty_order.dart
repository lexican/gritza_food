import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyOrder extends StatelessWidget {
  const EmptyOrder({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
        color: const Color(0xfffafafa),
        width: double.infinity,
        height: height - (35 + 58 + 24 + kToolbarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/svg/empty_order.svg"),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "No History Yet",
              style: TextStyle(
                  fontFamily: "Roboto", fontSize: 18, color: Color(0xFF333333)),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "You are yet to place your first order, Once you place an order, it would be listed here. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 12,
                      color: Color(0xFF9E9E9E)),
                ))
          ],
        ));
  }
}
