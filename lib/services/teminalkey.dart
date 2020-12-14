import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:http/http.dart' as http;

Future<dynamic> sendTerminalKey(TemimalKey terminal) async {
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.terminalKey);
    final client = new http.Client();
    Map<String, dynamic> params = {
      "terminal_key": terminal.terminalKey,
      "ter_device_id": terminal.deviceid,
      "ter_device_token": terminal.terDeviceToken
    };
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(params),
    );
    print(url);
    print(response.statusCode);
    var data = json.decode(response.body);
    return data;
  } catch (e) {
    print(e);
    var res = {"status": -1, "message": e.message.toString()};
    return res;
  }
}
