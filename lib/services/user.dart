import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/TerminalKey.dart';
import 'package:http/http.dart' as http;
import 'package:mcncashier/models/User.dart';

Future<User> login(User user) async {
  print(user);
  try {
    Uri url = Uri.parse(Configrations.base_URL + Configrations.login);
    //print("url");
    print(url);
    final client = new http.Client();
    Map<String, dynamic> params = {
      'username': user.name,
      'user_pin': user.userPin,
      'device_type': user.deviceType,
      'device_token': user.deviceToken,
      'device_id': user.deviceId,
      'terminal_id': user.terminalId,
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
    if (data["status"] == 200) {
      return User.fromJson(data["data"]);
    } else {
      return User.fromJson({});
    }
  } catch (e) {
    print(e);
    return User.fromJson({});
  }
}
