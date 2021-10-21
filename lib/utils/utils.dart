import 'dart:ui';

import 'package:flutter/material.dart';

class Utils {
  static Color primaryColor = Color(0xFFfd8105);

  static Color lightGray = Color(0xFF757575);
  static Color darkGray = Color(0xFF616161);
  static Color greyColor2 = Color(0xffE8E8E8);
  static String nairaCode = "\u20A6";

  static Color status_pending = Colors.yellow;
  static Color status_confirmed = Color(0xFF388e3c);
  static Color status_cacelled = Color(0xFFd32f2f);

  static final String kGoogleApiKey = "AIzaSyD3CuXvo8PvCSWo89j9SdVEkvvEnkShJZQ";

  static String moneyFormat(String price) {
    if (price.length > 2) {
      var value = price;
      value = value.replaceAll(RegExp(r'\D'), '');
      value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
      return value;
    }
    return price;
  }

  static String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid email address';
    else
      return null;
  }

  static String validatePhoneNumber(String value) {
    if (value.length != 11) {
      return 'Mobile Number must be of 10 digit';
    }
    Pattern pattern = r"^[0]\d{10}$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid phone number';
    else
      return null;
  }

  static String pwdValidator(String value) {
    if (value.length < 6) {
      return 'Password must be longer than 6 characters';
    } else {
      return null;
    }
  }

  static String validateText(value, fieldName) {
    if (value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
