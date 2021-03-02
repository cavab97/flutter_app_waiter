import 'dart:io';
import 'dart:convert';
import 'package:wifi/wifi.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/response.dart';

import 'package:mcncashier/components/preferences.dart';
import '../components/constant.dart';

class SlaveModel {
  static bool _status = false;
  static Future<void> start(String deviceIp) async {
    try {
     
      final server = await createServer(deviceIp);
      print('Slave Server started: ${server.address} port ${server.port}');
      await handleRequests(server); 
    } catch (e) {
    }
  }

  static Future<HttpServer> createServer(String deviceIp) async {
    print('create server');
    return await HttpServer.bind(deviceIp, 4040);
    
  }

  static Future<void> handleRequests(HttpServer server) async {
    await for (HttpRequest request in server) {
      switch (request.method) {
        case 'GET':
          handleGet(request);
          break;
        case 'POST':
          handlePost(request);
          break;
        default:
          handleDefault(request);
      }
    }
  }

  static Future<bool> _pingIP(String ip) async {
    Response _responce = await http.get(ip + '4040' + '/ping');
    _status = true;
    return _status;
  }

  static bool _open = true;
  static getIsOpen(String serverIP, String parameter) async {
    Response _responce =
        await http.get(serverIP + '4040' + parameter); //'/getOpenShift');
    return _responce.body;
  }

  static void handleGet(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/ping':
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
        break;
      default:
        handleGetOther(request);
    }
  }

  static void handleGetOther(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..close();
  }

  static Future<void> handlePost(HttpRequest request) async {
    final path = request.uri.path;
    switch (path) {
      case '/shift':
        var test = await utf8.decoder.bind(request).join();
        print('enter shift post');
        String _receiveShift = 'anc';
        //update to listener to update shift
        //Preferences.setStringToSF(Constant.IS_SHIFT_OPEN,  _receiveShift);
        request.response
          ..statusCode = HttpStatus.ok
          ..close();
        break;
      default:
    }

    request.response
      ..write('Got it. Thanks.')
      ..close();
  }

  static void handleDefault(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Unsupported request: ${request.method}.')
      ..close();
  }
}
