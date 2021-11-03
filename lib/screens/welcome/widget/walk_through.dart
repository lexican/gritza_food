import 'package:flutter/material.dart';
import 'package:gritzafood/utils/utils.dart';

class Walkthrough extends StatelessWidget {
  final String title;
  final String textContent;
  final Function next;
  final int index;
  final String url;
  final int pageLength;
  const Walkthrough(
      {Key key,
      @required this.textContent,
      this.title,
      this.next,
      this.index,
      this.url,
      this.pageLength})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(url, ),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(title,
            style: TextStyle(
                fontSize: 24,
                color: Utils.primaryColor,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 15,
        ),
        Text(
          textContent,
          style: TextStyle(fontSize: 15, color: Utils.lightGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
