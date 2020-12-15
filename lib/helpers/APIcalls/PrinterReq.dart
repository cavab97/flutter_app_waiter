import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/PrinterList.dart';

class PrinterReq {
  static getAllPrinters(request) async {
    PrinterList printerList = new PrinterList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res =
          await printerList.getAllPrinterList(null, data["printer_is_cashier"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": res.length > 0 ? "" : "No data Found",
          "data": res
        }))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getCartQTYPrinters(request) async {
    PrinterList printerList = new PrinterList();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await printerList.getPrinterForAddCartProduct(
          null, data["product_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": res.length > 0 ? "" : "No data Found",
          "data": res
        }))
        ..close();
    } catch (e) {
      print(e);
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
