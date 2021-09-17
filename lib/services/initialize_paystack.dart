import 'dart:convert';

import 'package:http/http.dart' as http;

createAccessCode(skTest, amount, email) async {
  // skTest -> Secret key
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $skTest'
  };
  Map data = {"amount": amount, "email": email};
  String payload = json.encode(data);
  http.Response response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: headers,
      body: payload);
  return jsonDecode(response.body);
}
