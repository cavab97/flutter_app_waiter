import 'dart:convert';
import 'dart:io';
import 'package:mcncashier/helpers/LocalAPI/Cart.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';

class CartReq {
  static addCart(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      MST_Cart cart = MST_Cart.fromJson(data["cart_data"]);
      var res = await cartlist.addcart(null, cart);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added cart",
          "cart_id": res
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static addSaveOrder(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var orderdata = data["save_order"];
      SaveOrder order = SaveOrder.fromJson(orderdata);
      var res = await cartlist.addSaveOrder(order, data["table_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added save Order",
          "save_order_id": res
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static addCartDetails(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      MSTCartdetails details = MSTCartdetails.fromJson(data["cart_details"]);
      var res = await cartlist.addintoCartDetails(null, details);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added cart details.",
          "detail_id": res
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static addSubCartDetails(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      List<dynamic> dt = data["cart_sub_details"];
      List<MSTSubCartdetails> details = dt.length > 0
          ? dt.map((c) => MSTSubCartdetails.fromJson(c)).toList()
          : [];
      await cartlist.addsubCartData(null, details);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({
          "status": 200,
          "message": "successfuly added sub cart details",
        }))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static cartItemList(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getCartItem(data["cart_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getSaveOrder(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getSaveOrder(data["save_order_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static getCartTotals(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var res = await cartlist.getCurrCartTotals(data["cart_id"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static deletecartItem(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var cartItem = data["cart_item"];
      var cartID = data["cart_id"];
      var mainCart = data["main_cart"];
      var isLast = data["is_last"];
      var res =
          await cartlist.deleteCartItem(cartItem, cartID, mainCart, isLast);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(
            jsonEncode({"status": 200, "message": "success delete cart item."}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static cleatCart(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var cartID = data["cart_id"];
      var tableId = data["table_id"];
      var res = await cartlist.clearCartItem(cartID, tableId);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(
            jsonEncode({"status": 200, "message": "successfull clear cart."}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static productModifierdata(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);

      var cartdetailID = data["cart_details_id"];
      var res = await cartlist.getItemModifire(cartdetailID);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", "data": res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static updateCartData(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var cartdetails = data["cart_details"];
      await cartlist.updateCartdetails(cartdetails);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success."}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static updateCartList(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var cartdetails = data["cart_list"];
      await cartlist.updateCartList(cartdetails);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success."}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static vaucherExit(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      var code = data["code"];
      var res = await cartlist.checkVoucherIsExit(code);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", data: res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static addVoucher(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);

      var res = await cartlist.addVoucherInOrder(data["cart"], data["details"]);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success.", data: res}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }

  static makeProductAsFoc(request) async {
    Cartlist cartlist = new Cartlist();
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = await jsonDecode(content);
      await cartlist.makeAsFocProduct(
          data["focProduct"], data["isUpdate"], data["cart"], data["cartitem"]);
      await request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 200, "message": "success."}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType =
            new ContentType("json", "plain", charset: "utf-8")
        ..write(jsonEncode({"status": 500, "message": "Something went wrong"}))
        ..close();
    }
  }
}
