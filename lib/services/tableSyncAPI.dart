import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:http/http.dart' as http;

Future<dynamic> syncTable(dynamic data) async {
  var reqdata = data;
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.synch_table);
    //print("url");
    print(url);
    final client = new http.Client();
    Map<String, dynamic> params = {
      'serverdatetime': reqdata["serverdatetime"],
      'table': reqdata["table"],
    };
    print(params);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(params),
    );
    print(response);
    var data = json.decode(response.body);
    return data;
  } catch (e) {
    print(e);
    return null;
  }
}

