import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/helpers/sqlDatahelper.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/CheckInout.dart';
import 'package:mcncashier/models/Citys.dart';
import 'package:mcncashier/models/Countrys.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/colorTable.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/PosPermission.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Rac.dart';
import 'package:mcncashier/models/Role.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/States.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/Terminal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/Product_Categroy.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/wifi.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class LocalAPI {

  Future<String> getMasterURL() async {

    try {
      // final address = await Wifi.ip;
      final address = '192.168.1.2';
      var parts;

      parts = address.split('.');
      parts[3] = '239';

      return 'http://${parts.join(".")}:4040';
    } catch (error) {
      print("getMasterURL err : " +error);
      rethrow;
    }

  }

  Future<int> terminalLog(TerminalLog log) async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/mine/logs';

      var logData = {
        'module_name': log.module_name,
        'description': log.description,
        'table_name': log.table_name,
        'entity_id': log.entity_id,
        'user_id': log.uuid,
        'updated_by': log.updated_by
      };

      Response response = await Dio().post(
        path,
        data: logData,
        options: Options(contentType: "application/json")
      );

      return pick(response.data).asIntOrNull();

    } catch (error) {
      print(error);
      rethrow;
    }
    
  }

  Future<Terminal> getTerminalDetails(terminalkey) async {
    var query = "SELECT * from terminal WHERE terminal_id  =$terminalkey";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    Terminal terminalDat;
    List<Terminal> list =
        res.length > 0 ? res.map((c) => Terminal.fromJson(c)).toList() : [];
    if (list.length > 0) {
      terminalDat = list[0];
    }
    return terminalDat;


  }

  Future<bool> getShift() async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/shifts/current/status';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      return pick(response.data).asBoolOrNull();

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Category>> getAllCategory() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/categories';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Category> list =
        body.isNotEmpty ? body.map((c) => Category.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<ProductDetails>> getProduct(String id) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/categoryproducts';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'categoryid' : id
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<ProductDetails> list =
        body.isNotEmpty ? body.map((c) => ProductDetails.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<ProductDetails>> getAllProduct(String branchID) async {
    /* Database db = DatabaseHelper.dbHelper.getDatabse();
    String query = "SELECT product.product_id, product.name, product.has_inventory, product.price, product.sku, base64, category_attribute.name as attr_cat, product_store_inventory.qty, product_branch.out_of_stock FROM `product` " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " LEFT JOIN product_branch ON product_branch.product_id = product.product_id AND product_branch.status = 1" +
        " LEFT JOIN product_store_inventory ON product_store_inventory.product_id = product.product_id AND product_store_inventory.status = 1 " +
        " LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " AND product_branch.branch_id = " +
        branchID.toString() +
        " GROUP By product.product_id";
    var res = await db.rawQuery(query);
    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    return list; */

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/products';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<ProductDetails> list =
        body.isNotEmpty ? body.map((c) => ProductDetails.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    } 
  }

  Future<bool> updateProductWithStock(
      List<int> idsWithStock, List<int> idsNoStock, String branchID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String updateProductToStock =
        "UPDATE `product_branch` SET out_of_stock = 0 WHERE product_id IN (" +
            idsWithStock.join(',') +
            ") AND product_branch.branch_id = " +
            branchID.toString();
    String updateProductNoStock =
        "UPDATE `product_branch` SET out_of_stock = 1 WHERE product_id IN (" +
            idsNoStock.join(',') +
            ") AND product_branch.branch_id = " +
            branchID.toString();
    /* String updateProductInventory =
        "UPDATE `product_store_inventory` SET qty = 0 WHERE product_id IN (" +
            idsNoStock.join(',') +
            ")"; */
    String selectQuery = "SELECT product.* FROM `product` " +
        " LEFT JOIN product_branch ON product_branch.product_id = product.product_id AND product_branch.status = 1" +
        " WHERE out_of_stock = 1 AND product_branch.branch_id = " +
        branchID.toString();
    if (idsWithStock.length > 0) {
      await db.rawQuery(updateProductToStock);
    }
    if (idsNoStock.length > 0) {
      await db.rawQuery(updateProductNoStock);
    }
    //await db.rawQuery(updateProductInventory);
    /* var res = await db.rawQuery(selectQuery);

    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];
    print(jsonEncode(list)); */
    return true;
  }

  Future<List<ProductDetails>> getSeachProduct(
      String searchText, String branchID) async {
    var query = "SELECT product.*,base64 ,product_store_inventory.qty, price_type.name as price_type_Name FROM `product` " +
        " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
        " LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = product.product_id " +
        " LEFT join product_store_inventory  ON  product_store_inventory.product_id = product.product_id and product_store_inventory.status = 1 " +
        " where product.status = 1 AND product.has_setmeal = 0 AND " +
        " (product.name LIKE '%$searchText%' OR product.sku LIKE '%$searchText%')" +
        " GROUP By product.product_id";

    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<ProductDetails> list = res.isNotEmpty
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<SetMeal>> getSearchSetMealsData(
      String searchText, String branchid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "select setmeal.* ,base64  from setmeal " +
        " LEFT join setmeal_branch on setmeal_branch_id =" +
        branchid +
        " AND setmeal_branch.setmeal_id = setmeal.setmeal_id " +
        " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
        " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id  " +
        " where setmeal.name LIKE '%$searchText%'" +
        "GROUP by setmeal.setmeal_id ";
    var mealList = await db.rawQuery(qry);
    List<SetMeal> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMeal.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Customer>> getCustomers(teminalID) async {
    var query = "SELECT * from customer WHERE customer.status = 1 ";
    teminalID;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];

    return list;
  }

  Future<int> saveCustomersFromServer(Customer customer) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer where app_id =" + customer.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("customer", customer.toJson(),
          where: "app_id =?", whereArgs: [customer.appId]);
    } else {
      result = await db.insert("customer", customer.toJson());
    }
    /* await SyncAPICalls.logActivity("sync customer", "sync customer from server",
        "customer", customer.appId); */
    return result;
  }

  Future<int> addCustomer(Customer customer) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert("customer", customer.toJson());
    return result;
  }

  Future<List<TablesDetails>> getTables(branchid) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tables';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<TablesDetails> list =
        body.isNotEmpty ? body.map((c) => TablesDetails.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<ColorTable>> getTablesColor() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tablecolors';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<ColorTable> list =
        body.isNotEmpty ? body.map((c) => ColorTable.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<int> insertTableOrder(Table_order tableOrder) async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tableorders';

      var tableOrderData = {
        'table_id': tableOrder.table_id,
        'save_order_id': tableOrder.save_order_id,
        'service_charge': tableOrder.service_charge,
      };

      Response response = await Dio().post(
        path,
        data: tableOrderData,
        options: Options(contentType: "application/json")
      );

      return pick(response.data).asIntOrNull();

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<int> updateTablePax(Table_order tableOrder) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    return await db.update("table_order", tableOrder.toJson(),
        where: 'table_id = ?', whereArgs: [tableOrder.table_id]);
  }

  Future<int> mergeTableOrder(Table_order tableOrder) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from tableOrder where table_id =" +
        tableOrder.merged_table_id.toString();
    var res = await db.rawQuery(qry);
    List<Table_order> list =
        res.isNotEmpty ? res.map((c) => Table_order.fromJson(c)).toList() : [];
    if (list.length > 0) {
      if (list[0].save_order_id != 0) {
        List<SaveOrder> cartIDs =
            await localAPI.gettableCartID(list[0].save_order_id);
        if (tableOrder.save_order_id == 0 && list[0].save_order_id != 0) {
          if (cartIDs.length > 0) {
            String qry1 = "UPDATE mst_cart SET table_id = " +
                tableOrder.table_id.toString() +
                " where id = " +
                cartIDs[0].cartId.toString();
            await db.rawQuery(qry1);
            list[0].table_id = tableOrder.table_id;
            String qry2 = "UPDATE tableOrder SET table_id = " +
                tableOrder.table_id.toString() +
                " where table_id = " +
                list[0].table_id.toString();
            await db.rawQuery(qry2);
            String qrysabve = "UPDATE save_order SET cart_id = " +
                cartIDs[0].cartId.toString() +
                " where id = " +
                list[0].save_order_id.toString();
            await db.rawQuery(qrysabve);
            tableOrder.save_order_id = list[0].save_order_id;
          }
        } else {
          if (tableOrder.save_order_id != 0 && cartIDs.length > 0) {
            List<SaveOrder> carts =
                await localAPI.gettableCartID(tableOrder.save_order_id);
            if (carts.length > 0) {
              var detailqry = "UPDATE mst_cart_detail SET cart_id = " +
                  carts[0].cartId.toString() +
                  " where cart_id = " +
                  cartIDs[0].cartId.toString();
              await db.rawQuery(detailqry);
            }
          }
          await deleteTableOrder(list[0].table_id);
          await deleteSaveOrder(list[0].save_order_id);
        }
      } else {
        await deleteTableOrder(list[0].table_id);
        await deleteSaveOrder(list[0].save_order_id);
      }
    }

    await insertTableOrder(tableOrder);
    /* await SyncAPICalls.logActivity("Orders Tables", "Merged table order",
        "tableOrder", tableOrder.table_id); */
    return 1;
  }

  Future deleteTableOrder(tableID) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tableorders';

      Response response = await Dio().delete(
        path,
        queryParameters: {
          'id': tableID
        },
        options: Options(contentType: "application/json")
      );

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future deleteSaveOrder(id) async {
    if (id != 0) {
      Database db = DatabaseHelper.dbHelper.getDatabse();
      await db.delete("save_order", where: 'id  =?', whereArgs: [id]);
      /* await SyncAPICalls.logActivity(
          "delete save Order", "delete save Order", "save_order", id); */
    }
    
  }

  Future updateTableIdInOrder(orderid, tableid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "UPDATE orders SET table_id =" +
        tableid.toString() +
        " where app_id =" +
        orderid.toString();
    await db.rawQuery(qry);
    /* await SyncAPICalls.logActivity(
        "assign table", "assing table to web order", "orders", tableid); */
  }

  Future<int> insertTablePrinter(Printer table_printer) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from printer where printer_ip = 1"; //+
    // table_printer.printerIp.toString();
    var res = await db.rawQuery(qry);
    List<Printer> list =
        res.isNotEmpty ? res.map((c) => Printer.fromJson(c)).toList() : [];
    var result;
    if (list.length > 0) {
      result = await db.update("printer", table_printer.toJson(),
          where: 'printerIp = ?', whereArgs: [table_printer.printerIp]);
    } else {
      result = await db.insert("printer", table_printer.toJson());
    }
    /* await SyncAPICalls.logActivity(
        "Printer",
        list.length > 0 ? "Update table printer" : "Insert table printer",
        "printerId",
        table_printer.printerId); */

    return result;
  }

  Future<List<Printer>> selectPrinterForPrint() async {
    String qry =
        "SELECT * from printer LEFT JOIN product_branch on product_branch.product_id = 1  AND printer.printer_id = product_branch.printer_id";
    // table_printer.printerIp.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Printer> list =
        res.isNotEmpty ? res.map((c) => Printer.fromJson(c)).toList() : [];
    /* await SyncAPICalls.logActivity("Printer",
        list.length > 0 ? "Print KOT" : "Print KOT", "printerId", "1"); */
    return list;
  }

  Future<int> insertShift(Shift shift, shiftId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    if (shiftId != null) {
      String qry = "UPDATE shift set end_amount = " +
          shift.endAmount.toString() +
          " ,updated_at = '" +
          shift.updatedAt +
          "' where app_id = " +
          shift.appId.toString();
      await db.rawQuery(qry);
    } else {
      await db.insert("shift", shift.toJson());
    }
    var dis = shiftId != null ? "Update shift" : "Insert shift";
    /*  await SyncAPICalls.logActivity(
        "shift Opne/close", dis, "shift", shift.appId); */
    return shift.appId;
  }

  Future<List<Shift>> getShiftData(shiftId) async {
    if (shiftId == null) return [];
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query('shift', where: "app_id = ?", whereArgs: [shiftId]);
    List<Shift> list =
        result.isNotEmpty ? result.map((c) => Shift.fromJson(c)).toList() : [];
    /* await SyncAPICalls.logActivity("shift", "shift data", "shift", shiftId); */
    return list;
  }

  Future<List<Attribute_Data>> getProductDetails(productId) async {
    /* String qry = " SELECT product.product_id, category_attribute.name as attr_name,attributes.ca_id, " +
        " group_concat(product_attribute.price) as attr_types_price,group_concat(attributes.name) as attr_types ,group_concat(attributes.attribute_id) as attributeId , group_concat(attributes.is_default) as is_default" +
        " FROM product LEFT JOIN product_attribute on product_attribute.product_id = product.product_id and product_attribute.status = 1" +
        " LEFT JOIN category_attribute on category_attribute.ca_id = product_attribute.ca_id and category_attribute.status = 1" +
        " LEFT JOIN attributes on attributes.attribute_id = product_attribute.attribute_id and attributes.status = 1 " +
        " WHERE product.product_id = " +
        productId.toString() +
        " AND product_attribute.product_id = " +
        productId.toString() +
        " GROUP by category_attribute.ca_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Attribute_Data> list = res.length > 0
        ? res.map((c) => Attribute_Data.fromJson(c)).toList()
        : [];

    return list; */

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/product/details';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'productid': productId
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Attribute_Data> list =
        body.isNotEmpty ? body.map((c) => Attribute_Data.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }

  }

  Future<List<ModifireData>> getProductModifeir(productId) async {
    String qry =
        "SELECT modifier.name,modifier.modifier_id,modifier.is_default,product_modifier.pm_id,product_modifier.price FROM  product_modifier " +
            " LEFT JOIN modifier on modifier.modifier_id = product_modifier.modifier_id " +
            " WHERE product_modifier.product_id = " +
            productId.toString() +
            " AND product_modifier.status = 1" +
            " GROUP by product_modifier.pm_id";
    List<Map> res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ModifireData> list =
        res.isNotEmpty ? res.map((c) => ModifireData.fromJson(c)).toList() : [];

    return list;
  }

  Future<int> insertItemTocart(cartidd, MST_Cart cartData,
      ProductDetails product, SaveOrder orderData, tableiD) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var cartid;
    if (cartidd == null) {
      cartid = await db.insert("mst_cart", cartData.toJson());
      /* await SyncAPICalls.logActivity(
          "cart", "Product add in to cart", "mst_cart", cartid); */
      orderData.cartId = cartid; //cartid
      await insertSaveOrders(orderData, tableiD);
    } else {
      cartData.id = cartidd;
      var res_cartid = await db.update("mst_cart", cartData.toJson(),
          where: 'id = ?', whereArgs: [cartidd]);
      cartid = cartidd;
      /* await SyncAPICalls.logActivity(
          "cart", "Product update in to cart", "mst_cart", res_cartid); */
    }

    return cartid;
  }

  Future<int> insertReservationToCart(MST_Cart cartData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    return await db.insert("mst_cart", cartData.toJson());
  }

  Future<int> insertSaveOrders(orderData, tableiD) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var response = await db.insert("save_order", orderData.toJson());
    /* await SyncAPICalls.logActivity(
        "product", "save item into save order table", "save_order", 1); */
    if (tableiD != null) {
      var rawQuery = 'UPDATE table_order set save_order_id = ' +
          response.toString() +
          " WHERE table_id = " +
          tableiD.toString();
      await db.rawQuery(rawQuery);
      /*  await SyncAPICalls.logActivity("product", "update save_order_id",
          "table_order", response.toString()); */
    }
    return 1;
  }

  Future<int> updateTableidintocart(cartid, tableiD) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var rawQuery = 'UPDATE mst_cart SET table_id = ' +
        tableiD.toString() +
        " WHERE id = " +
        cartid.toString();
    await db.rawQuery(rawQuery);
/* 
    await SyncAPICalls.logActivity(
        "weborder", "update table_id", "mst_cart", tableiD.toString()); */
    return 1;
  }

  Future<int> addintoCartDetails(cartdetails) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var cartdetailid;
    var newObj = cartdetails.toJson();
    newObj.remove("attr_name");
    newObj.remove("modi_name");
    if (cartdetails.id != null) {
      cartdetailid = await db.update("mst_cart_detail", newObj,
          where: 'id = ?', whereArgs: [cartdetails.id]);
      cartdetailid = cartdetails.id;
    } else {
      try {
        cartdetailid = await db.insert("mst_cart_detail", newObj);
      } catch (e) {
        print(e);
      }
    }
    /* 
    await SyncAPICalls.logActivity(
        "product", "insert  cart details", "mst_cart_detail", cartdetailid); */
    return cartdetailid;
  }

  Future<int> deletesubcartDetail(cartdetailsId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.delete("mst_cart_sub_detail",
        where: "cart_details_id =?", whereArgs: [cartdetailsId]);
    /* await SyncAPICalls.logActivity(
        "cart", "delete sub cart Detail", "mst_sub_cart_detail", cartdetailsId); */
    return result;
  }

  Future<int> addsubCartData(MSTSubCartdetails data) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    return await db.insert("mst_cart_sub_detail", data.toJson());
    /* await SyncAPICalls.logActivity(
        "product", "insert sub cart details", "mst_cart_sub_detail", result1); */
  }

  Future<List<MSTSubCartdetails>> itemmodifireList(detailid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT  * from mst_cart_sub_detail WHERE cart_details_id  = " +
            detailid.toString();
    var res = await db.rawQuery(qry);
    List<MSTSubCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    /* await SyncAPICalls.logActivity(
        "product", "get cart modifier list", "mst_cart_sub_detail", detailid); */
    return list;
  }

  Future<List<MSTCartdetails>> getCartItem(cartId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    //var isjoin = await CommunFun.checkIsJoinServer();
    List<MSTCartdetails> list = [];
    /* if (isjoin == true) {
      var apiurl = await Configrations.ipAddress() + Configrations.cart_items;
      var stringParams = {"cart_id": cartId};
      var result = await APICall.localapiCall(null, apiurl, stringParams);
      if (result["status"] == Constant.STATUS200) {
        List<dynamic> data = result["data"];
        list = data.length > 0
            ? data.map((c) => MSTCartdetails.fromJson(c)).toList()
            : [];
      }
    } else { */
    String qry = " SELECT mst_cart_detail.* ,group_concat(attributes.name) as attrName ,group_concat(modifier.name) as modiName from mst_cart_detail " +
        " LEFT JOIN mst_cart_sub_detail on mst_cart_sub_detail.cart_details_id = mst_cart_detail.id AND  (mst_cart_sub_detail.attribute_id != '' OR mst_cart_sub_detail.modifier_id != '' )" +
        " LEFT JOIN attributes on attributes.attribute_id = mst_cart_sub_detail.attribute_id  AND  mst_cart_sub_detail.attribute_id != " +
        " '' " +
        " LEFT JOIN modifier on modifier.modifier_id = mst_cart_sub_detail.modifier_id AND mst_cart_sub_detail.modifier_id != " +
        " '' " +
        " where cart_id =" +
        cartId.toString() +
        " group by mst_cart_detail.id";
    var res = await db.rawQuery(qry);
    list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    return list;
    
  }

  Future<bool> updateItemDiscount(MSTCartdetails product, int cartID,
      String discountAmount, String discountType, String discountRemark) async {
    MST_Cart getCart = await localAPI.getCartData(cartID);

    int discountT = discountType == "%" ? 1 : 2;
    double discountA = double.tryParse(discountAmount);
    double totalPrice = product.productPrice;
    String selectAttribute =
        "SELECT SUM(mst_cart_sub_detail.attr_price) as attr_total, SUM(mst_cart_sub_detail.modifier_price) as modifier_total FROM mst_cart_sub_detail WHERE mst_cart_sub_detail.cart_details_id = " +
            product.id.toString();
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var res = await db.rawQuery(selectAttribute);

    double attributesPrice =
        res.isNotEmpty ? res.map((c) => c['attr_total']).first : 0.00;
    double modifierPrice =
        res.isNotEmpty ? res.map((c) => c['modifier_total']).first : 0.00;
    attributesPrice = attributesPrice == null ? 0.00 : attributesPrice;
    modifierPrice = modifierPrice == null ? 0.00 : modifierPrice;
    totalPrice += attributesPrice + modifierPrice;
    totalPrice = totalPrice * product.productQty;

    if (getCart.voucher_id != null &&
        getCart.voucher_id > 0 &&
        discountType == "%") {
    } else if (discountType == "%") {
      totalPrice = totalPrice * (1 - (discountA / 100));
    } else {
      totalPrice = totalPrice - discountA;
    }
    String updatePrice = "UPDATE `mst_cart_detail` SET discount_amount = '" +
        discountAmount +
        "', discount_type = '" +
        discountT.toString() +
        "', discount_remark = '" +
        discountRemark +
        "', product_detail_amount = '" +
        totalPrice.toString() +
        "' WHERE cart_id = '" +
        cartID.toString() +
        "' AND product_id = '" +
        product.productId.toString() +
        "'";
    await db.rawQuery(updatePrice);
    return true;
  }

  Future<bool> applyBillDiscount(int cartID, String discountAmount,
      String discountType, String discountRemark) async {
    MST_Cart currentCart = await getCartData(cartID);
    int discountT = discountType == "%" ? 1 : 2;
    double totalDiscountAmount = 0;
    double currentDiscountAmount = 0;
    double cartSubTotal = 0;
    List<MSTCartdetails> cartdetails = await getCartItem(cartID);
    /* if (currentCart.voucher_id != null && currentCart.voucher_id > 0) {
      Voucher voucher = await getvoucher(currentCart.voucher_id);
      double voucherAmount = voucher.voucherDiscountType == 2
          ? (currentCart.sub_total * (voucher.voucherDiscount / 100))
          : voucher.voucherDiscount;
      totalDiscountAmount = voucherAmount;
    } */
    if (discountT == 1) {
      currentDiscountAmount =
          (currentCart.sub_total * (double.tryParse(discountAmount) / 100));
    } else {
      currentDiscountAmount = double.tryParse(discountAmount);
    }
    totalDiscountAmount += currentDiscountAmount;
    cartdetails.forEach((cartdetail) {
      cartSubTotal += cartdetail.productDetailAmount != null &&
              cartdetail.productDetailAmount != 0.00
          ? cartdetail.productDetailAmount
          : cartdetail.productPrice;
    });
    currentCart.sub_total = cartSubTotal - totalDiscountAmount;
    currentCart.discountAmount = double.tryParse(discountAmount);
    currentCart.discountType = discountT;
    currentCart.discountRemark = discountRemark;
    Database db = DatabaseHelper.dbHelper.getDatabse();

    await db.update("mst_cart", currentCart.toJson(),
        where: 'id = ?', whereArgs: [cartID]);
    return true;
  }
  /*Future<List<MSTCartdetails>> getSplitBillData(cartId) async {
    String qry =
        "SELECT mst_cart_detail.*, replace(asset.base64,'data:image/jpg;base64,','') as base64  FROM `mst_cart_detail` LEFT join asset on asset.asset_type = 1 AND asset.asset_type_id = mst_cart_detail.product_id  where cart_id =  " +
            cartId.toString();
    ;
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    await SyncAPICalls.logActivity(
        "product", "get split bill data", "mst_cart_detail", cartId);
    return list;
  }*/

  Future<int> deleteCartItemFromSplitBill(
      cartItem, cartID, mainCart, isLast) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db
        .delete("mst_cart_Detail", where: 'id = ?', whereArgs: [cartItem.id]);

    await db.delete("mst_cart_sub_detail",
        where: 'cart_details_id = ?', whereArgs: [cartItem.id]);
    /* await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_Detail",
        "mst_cart_Detail",
        cartItem.id);
    await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_sub_detail",
        "mst_cart_sub_detail",
        cartItem.id); */

    /* if (isLast) {
      await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartID]);
      /*  */
      await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartID]);
      await SyncAPICalls.logActivity(
          "cart", "delete cart all item", "mst_Cart", cartItem.id);
      await SyncAPICalls.logActivity("cart",
          "delete cart all item from save_order", "save_order", cartItem.id);
    } else {
      //Update cart
    } */
    await db.update("mst_cart", mainCart.toJson(),
        where: 'id = ?', whereArgs: [cartID]);
    return cartID;
  }

  Future<int> userCheckInOut(CheckinOut clockinOutData) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/auth/access/pin';

      var clockinOut = {
        'id': clockinOutData.id,
        'user_id': clockinOutData.userId
      };

      Response response = await Dio().post(
        path,
        data: clockinOut,
        options: Options(contentType: "application/json")
      );

      return pick(response.data).asIntOrNull();

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<SaveOrder>> getSaveOrder(id) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/saveorders';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'id': id
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<SaveOrder> list =
        body.isNotEmpty ? body.map((c) => SaveOrder.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<TablesDetails>> getTableData(tableID) async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tables';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'id': tableID
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<TablesDetails> list =
        body.isNotEmpty ? body.map((c) => TablesDetails.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<MST_Cart>> getCurrentCart(cartID) async {
    var query = "SELECT * from mst_cart where id=" + cartID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];

    return list;
  }

  Future<List<MSTCartdetails>> getCurrentCartItems(cartID) async {
    var query =
        "SELECT * from mst_cart_detail where cart_id = " + cartID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Payments>> getPaymentMethods() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/paymentmethods';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Payments> list =
        body.isNotEmpty ? body.map((c) => Payments.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<Orders> getcurrentOrders(orderid, terminalID) async {
    var query =
        "SELECT * from orders WHERE app_id=$orderid AND terminal_id=$terminalID";
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    Orders order;
    List<Orders> list =
        res.length > 0 ? res.map((c) => Orders.fromJson(c)).toList() : [];
    if (list.length > 0) {
      order = list[0];
    }
    return order;
  }

  Future<List<OrderAttributes>> getOrderAttributes(orderid) async {
    var query = "SELECT order_attributes.*,attributes.name from order_attributes " +
        " LEFT join attributes on attributes.attribute_id =  order_attributes.attribute_id WHERE order_attributes.order_app_id = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderAttributes> list = res.isNotEmpty
        ? res.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderModifire>> getOrderModifire(orderid) async {
    var query = "SELECT order_modifier.*,modifier.name  from order_modifier " +
        " LEFT JOIN modifier on modifier.modifier_id = order_modifier.modifier_id" +
        " WHERE order_modifier.order_app_id  = " +
        orderid.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<OrderModifire> list = res.isNotEmpty
        ? res.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Orders>> getLastOrderAppid(terminalid) async {
    var qey = "SELECT orders.app_id from orders where terminal_id =" +
        terminalid +
        " ORDER BY order_date DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Orders> list = checkisExit.length > 0
        ? checkisExit.map((c) => Orders.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderDetail>> getLastOrdeDetailAppid(terminalid) async {
    var qey =
        "SELECT order_detail.app_id from order_detail where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderDetail> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderModifire>> getLastOrderModifireAppid(terminalid) async {
    var qey =
        "SELECT order_modifier.app_id from order_modifier where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderModifire> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderModifire.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderAttributes>> getLastOrderAttrAppid(terminalid) async {
    var qey =
        "SELECT order_attributes.app_id from order_attributes where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderAttributes> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<OrderPayment>> getLastOrderPaymentAppid(terminalid) async {
    var qey =
        "SELECT order_payment.app_id from order_payment where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderPayment> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> placeOrder(Orders orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    if (orderData.order_id != null) {
      orderData.app_id = orderData.order_id;
      await db.delete("orders",
          where: "order_id=? OR app_id=?",
          whereArgs: [orderData.order_id, orderData.order_id]);
    }
    await db.insert("orders", orderData.toJson());
    /*  await SyncAPICalls.logActivity("orders", "place order", "orders", orderid); */
    return orderData.order_id ?? orderData.app_id;
  }

  Future<int> sendOrderDetails(OrderDetail orderDetailData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var data = orderDetailData.toJson();
    data.remove("base64");
    var orderid = await db.insert("order_detail", data);
    /* await SyncAPICalls.logActivity(
        "orders", "Added peoduct items into Orders", "order_detail", orderid); */
    return orderDetailData.app_id;
  }

  Future<int> sendModifireData(OrderModifire orderDetailData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = orderDetailData.toJson();
    newObj.remove("name");
    var orderid = await db.insert("order_modifier", newObj);
    /* await SyncAPICalls.logActivity("orders",
        "Added peoduct modifier into Orders", "order_modifier", orderid); */
    return orderDetailData.app_id;
  }

  Future<int> sendAttrData(OrderAttributes orderDetailData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = orderDetailData.toJson();
    newObj.remove("name");
    var orderid = await db.insert("order_attributes", newObj);
    /* await SyncAPICalls.logActivity("orders",
        "Added peoduct attributes into Orders", "order_attributes", orderid); */
    return orderDetailData.app_id;
  }

  Future<int> getOPIdFromOrderPayment() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("order_payment",
        where: "order_app_id<0 OR order_app_id=''");
    var qey =
        "SELECT order_payment.op_id from order_payment WHERE op_id != '' ORDER BY op_id DESC";
    //where order_app_id =" +paymentData.order_app_id.toString();
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<OrderPayment> list = checkisExit.length > 0
        ? checkisExit.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    return list.length > 0 ? list[0].op_id + 1 : 1;
  }

  Future<int> sendtoOrderPayment(OrderPayment paymentData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    try {
      await db.insert("order_payment", paymentData.toJson());

      var qey = "SELECT order_payment.* from order_payment ";
      //where order_app_id =" +paymentData.order_app_id.toString();
      var checkisExit =
          await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
      List<OrderPayment> list = checkisExit.length > 0
          ? checkisExit.map((c) => OrderPayment.fromJson(c)).toList()
          : [];
    } catch (e) {
      print(e.toString());
    }
    /*  await SyncAPICalls.logActivity(
        "orders", "Order ", "order_payment", orderid); */
    return paymentData.app_id;
  }

  Future<int> sendtoShiftInvoice(ShiftInvoice shiftInvoiceData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var invoiceid = await db.insert("shift_invoice", shiftInvoiceData.toJson());
    /* await SyncAPICalls.logActivity(
        "orders", "insert shift invoice", "shift_invoice", invoiceid); */
    return shiftInvoiceData.invoice_id;
  }

  Future<int> clearCartItem(cartid, tableID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);

    /* await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1); */
    await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);
    String qry = "Update table_order set save_order_id = 0 where table_id =" +
        tableID.toString();
    await db.rawQuery(qry);
    var cartDetail = await db
        .query("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
/*     await SyncAPICalls.logActivity("Delete order",
        "Cashier A clear an order items.", "mst_cart_detail", cartid); */

    List<MSTCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        await db.delete("mst_cart_sub_detail",
            where: 'cart_details_id = ?', whereArgs: [list[i].id]);
      }
/*       await SyncAPICalls.logActivity(
          "Delete order",
          "Cashier A clear an order items modifire and attributes",
          "mst_cart_sub_detail",
          cartid); */
    }
    return cartid;
  }

  Future<int> removeCartItem(cartid, tableID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();

    await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartid]);

/*     await SyncAPICalls.logActivity("orders", "clear cart", "mst_cart", 1); */

    await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartid]);
/* 
    await SyncAPICalls.logActivity(
        "orders", "clear save_order", "save_order", cartid); */

    await db.delete("table_order", where: 'table_id = ?', whereArgs: [tableID]);
/* 
    await SyncAPICalls.logActivity(
        "orders", "clear table_order", "table_order", cartid); */

    var cartDetail = await db
        .query("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);

    List<MSTCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        await db.delete("mst_cart_sub_detail",
            where: 'cart_details_id = ?', whereArgs: [list[i].id]);
      }
    }
/*     await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_sub_detail", cartid); */

    // cart details
    var cartd = await db
        .delete("mst_cart_detail", where: 'cart_id = ?', whereArgs: [cartid]);
/*     await SyncAPICalls.logActivity(
        "orders", "clear cart detail", "mst_cart_detail", cartid); */
    return cartd;
  }

  Future<int> deleteCartItem(cartItem, cartID, mainCart, isLast) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db
        .delete("mst_cart_detail", where: 'id = ?', whereArgs: [cartItem.id]);
    /*  await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_Detail",
        "mst_cart_Detail",
        cartItem.id); */

    await db.delete("mst_cart_sub_detail",
        where: 'cart_details_id = ?', whereArgs: [cartItem.id]);
    /* await SyncAPICalls.logActivity(
        "cart",
        "delete cart item from mst_cart_sub_detail",
        "mst_cart_sub_detail",
        cartItem.id); */

    await db.update("mst_cart", mainCart.toJson(),
        where: 'id = ?', whereArgs: [cartID]);
    /* if (isLast) {
      await db.delete("mst_cart", where: 'id = ?', whereArgs: [cartID]);
      /* await SyncAPICalls.logActivity(
          "cart", "delete cart all item", "mst_Cart", cartItem.id);
      await db.delete("save_order", where: 'cart_id = ?', whereArgs: [cartID]);

      await SyncAPICalls.logActivity("cart",
          "delete cart all item from save_order", "save_order", cartItem.id); */
    } else {
      //Update cart
    } */
    return cartID;
  }

  Future<List<MSTSubCartdetails>> getItemModifire(id) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();

    var cartDetail = await db.query("mst_cart_sub_detail",
        where: 'cart_details_id = ?', whereArgs: [id]);
    List<MSTSubCartdetails> list = cartDetail.isNotEmpty
        ? cartDetail.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];

    return list;
  }

  // Future<List<ProductDetails>> getOrderDetails(orderid, terminalID) async {
  //   Database db = DatabaseHelper.dbHelper.getDatabse();
  //   String qry = "SELECT P.product_id,P.name,P.price, base64" +
  //       " FROM order_detail O " +
  //       " LEFT JOIN product P ON O.product_id = P.product_id" +
  //       " LEFT JOIN asset on asset.asset_type_id = P.product_id " +
  //       " WHERE O.terminal_id = " +
  //       terminalID.toString() +
  //       "  AND O.order_app_id = " +
  //       orderid.toString();
  //   var ordersList = await db.rawQuery(qry);
  //   List<ProductDetails> list = ordersList.isNotEmpty
  //       ? ordersList.map((c) => ProductDetails.fromJson(c)).toList()
  //       : [];
  //   await SyncAPICalls.logActivity(
  //       "Transactions", "get Orders details list", "ProductDetails", orderid);
  //   return list;
  // }

  Future<List<OrderDetail>> getOrderDetailsList(orderid, terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    /* order_detail.* */
    String qry =
        "SELECT DISTINCT order_detail.*, asset.base64 from order_detail LEFT JOIN" +
            " asset on asset.base64 =(SELECT base64 from asset WHERE asset.asset_type_id = order_detail.product_id AND asset.status = 1 AND " +
            " asset.asset_type = CASE WHEN order_detail.issetMeal == 1 THEN 2 ELSE 1 END ORDER By asset.asset_id DESC LIMIT 1) " +
            " WHERE terminal_id =  " +
            terminalid.toString() +
            " AND order_app_id = " +
            orderid.toString() +
            " ORDER By order_detail.app_id ASC";
    var ordersList = await db.rawQuery(qry);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];
    // String qry1 = "SELECT * from order_detail WHERE terminal_id = " +
    //     terminalid.toString() +
    //     " AND order_app_id = " +
    //     orderid.toString();
    // var ordersList1 = await db.rawQuery(qry1);
    // List<OrderDetail> list1 = ordersList1.isNotEmpty
    //     ? ordersList1.map((c) => OrderDetail.fromJson(c)).toList()
    //     : [];
    // print(list1);
    return list;
  }

  Future<List<OrderPayment>> getOrderpaymentData(orderid, terminalid) async {
    //OrderPayment data = new OrderPayment();
    String qry = "SELECT * from order_payment where terminal_id = " +
        terminalid.toString() +
        " AND order_app_id = " +
        orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderPayment> list = ordersList.length > 0
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    // if (list.length > 0) {
    //   data = list[0];
    // }
    return list;
  }

  Future<List<Voucher>> checkVoucherIsExit(code) async {
    String qry = "SELECT * from voucher where voucher_code = '" + code + "'";
//     String qry = "SELECT voucher.*,count(voucher_history.voucher_id) as total_used from voucher "+
// " LEFT JOIN voucher_history on voucher_history.voucher_id = voucher.voucher_id "+
// " where voucher_code = "+ code.toString();

    var voucherList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Voucher> list = voucherList.isNotEmpty
        ? voucherList.map((c) => Voucher.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<ProductCategory>> getProductCategory(ids) async {
    String qry =
        "SELECT * from product_category WHERE product_id =  " + ids.toString();
    var voucherList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<ProductCategory> list = voucherList.isNotEmpty
        ? voucherList.map((c) => ProductCategory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<dynamic> addVoucherIndetail(MSTCartdetails details, voucherId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = details.toJson();
    newObj.remove("attr_name");
    newObj.remove("modi_name");
    var data = await db.update("mst_cart_detail", newObj,
        where: "id =?", whereArgs: [details.id]);

    return data;
  }

  Future<dynamic> addVoucherInOrder(
      MST_Cart details, Voucher voucherDetail) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var data1 = await db.update("mst_cart", details.toJson(),
        where: "id =?", whereArgs: [details.id]);
    return data1;
  }

  Future<double> getCartTotal(cartid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var cartdata =
        await db.query('mst_cart', where: 'id = ?', whereArgs: [cartid]);
    List<MST_Cart> list = cartdata.isNotEmpty
        ? cartdata.map((c) => MST_Cart.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].grand_total;
    } else
      return 0.00;
  }

  Future<MST_Cart> getCartData(cartid) async {

      try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/cart';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'id': cartid
        },
        options: Options(contentType: 'application/json')
      );

      MST_Cart cart =  MST_Cart.fromJson(jsonDecode(response.data));

      return cart;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<Branch> getbranchData() async { 

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/branches/current';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      Branch currentBranch = Branch.fromJson(jsonDecode(response.data));

      return currentBranch;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<Voucher> getvoucher(voucherid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var voucher = await db.query('voucher',
        where: 'voucher_id = ?', whereArgs: [voucherid.toString()]);
    List<Voucher> list = voucher.isNotEmpty
        ? voucher.map((c) => Voucher.fromJson(c)).toList()
        : [];
    return list[0];
  }

  Future<dynamic> getVoucherusecount(voucherid) async {
    String qry =
        "SELECT count(voucher_id) from voucher_history where voucher_id = " +
            voucherid.toString();
    var count = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    int count1 = Sqflite.firstIntValue(count);
    return count1;
  }

  Future<dynamic> saveVoucherHistory(VoucherHistory voucherHis) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var hitid = await db.insert("voucher_history", voucherHis.toJson());
    /* await SyncAPICalls.logActivity(
        "orders", "Added voucher history", "voucher_history", hitid); */
    return hitid;
  }

  Future<List<BranchTax>> getTaxList() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/taxes';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<BranchTax> list =
        body.isNotEmpty ? body.map((c) => BranchTax.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Tax>> getTaxName(taxId) async {
    /* Database db = DatabaseHelper.dbHelper.getDatabse();
    var tax = await db.query('tax');
    List<Tax> list =
        tax.isNotEmpty ? tax.map((c) => Tax.fromJson(c)).toList() : [];
    return list; */

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/taxes';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'id': 'taxId'
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Tax> list =
        body.isNotEmpty ? body.map((c) => Tax.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Payments>> getOrderpaymentmethod(orderid, terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from payment " +
        " LEFT JOIN order_payment on order_payment.op_method_id = payment.payment_id " +
        " WHERE order_payment.terminal_id = " +
        terminalid.toString() +
        " AND order_payment.order_app_id = " +
        orderid.toString();
    var paymentMeth = await db.rawQuery(qry);
    List<Payments> list = paymentMeth.isNotEmpty
        ? paymentMeth.map((c) => Payments.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<User> getPaymentUser(userid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var user = await db
        .query('users', where: 'id = ?', whereArgs: [userid.toString()]);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list[0];
  }

  // Future<dynamic> removePromocode(voucherid) async {
  //   String qry = "SELECT count(voucher_id) from orders where voucher_id = " +
  //       voucherid.toString();
  //   var count = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
  //   return count;
  // }
  Future<List<Orders>> getOrdersList(branchid, terminalid, int offset) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from orders" +
        // " where branch_id = " +
        // branchid.toString() +
        // " AND terminal_id = " +
        // terminalid.toString() +
        " GROUP BY invoice_no ORDER By orders.order_date DESC, isSync DESC LIMIT 10 OFFSET  " +
        offset.toString();
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Orders>> getOrdersListTable(branchid, terminalId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from orders WHERE branch_id = " +
        branchid.toString() +
        " AND order_source = 2 AND terminal_id = " +
        terminalId.toString() +
        " AND (isSync = 0)";
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    List<int> orderIds = [];
    list.forEach((ele) => orderIds.add(ele.order_id));
    //print(orderIds);
    //db.delete('orders', where: 'server_id = ?', whereArgs: [0]);
    return list;
  }

  Future<List<OrderDetail>> getOrderDetailTable(orderid, terminalId) async {
    String qry =
        "SELECT * from order_detail where isSync = 0 AND terminal_id = " +
            terminalId.toString() +
            " AND order_app_id = " +
            orderid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderDetail> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderDetail.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<OrderAttributes>> getOrderAttributesTable(
      detailid, terminalId) async {
    String qry =
        "SELECT * from order_attributes where isSync = 0 AND  terminal_id = " +
            terminalId.toString() +
            " AND detail_app_id = " +
            detailid.toString();

    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderAttributes> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderAttributes.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<OrderModifire>> getOrderModifireTable(
      detailid, terminalId) async {
    String qry =
        "SELECT * from order_modifier where isSync = 0 AND terminal_id = " +
            terminalId.toString() +
            " AND detail_app_id = " +
            detailid.toString();
    var ordersList = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<OrderModifire> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderModifire.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<OrderPayment>> getOrderPaymentTable(orderid, terminalid) async {
    String qry =
        "SELECT * from order_payment where isSync = 0 AND terminal_id = " +
            terminalid.toString() +
            " AND order_app_id = " +
            orderid.toString();
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var ordersList = await db.query("order_payment",
        where: 'isSync = ? AND terminal_id=? AND order_app_id=?',
        whereArgs: [0, terminalid, orderid]);
    List<OrderPayment> list = ordersList.isNotEmpty
        ? ordersList.map((c) => OrderPayment.fromJson(c)).toList()
        : [];

    return list;
  }

  Future updateVoucherHistoryTablegetVoucherHistoryTable(
      orderid, terminalid, userId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    Map<String, dynamic> newUpdate = new Map();
    newUpdate['user_id'] = userId;
    await db.update("voucher_history", newUpdate);
  }

  Future<List<VoucherHistory>> getVoucherHistoryTable(
      orderid, terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var ordersList = await db.query("voucher_history",
        where: 'server_id= ? AND terminal_id=? AND app_order_id=?',
        whereArgs: [0, terminalid, orderid]);
    List<VoucherHistory> list = ordersList.isNotEmpty
        ? ordersList.map((c) => VoucherHistory.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<dynamic> sendToKitched(ids) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "update mst_cart_detail set is_send_kichen = 1 WHERE id in(" +
        ids.toString() +
        ")";
    var ordersList = await db.rawQuery(qry);
    /* await SyncAPICalls.logActivity(
        "Send to kitchen", "Items send to kitchen", "mst_cart_detail", 1); */
    return ordersList;
  }

  Future<List<ProductStoreInventory>> checkItemAvailableinStore(
      productId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [productId]);
    List<ProductStoreInventory> list = inventoryProd.length > 0
        ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<ProductStoreInventory>> removeFromInventory(
      OrderDetail produtdata) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<Product> list = inventoryProd.isNotEmpty
        ? inventoryProd.map((c) => Product.fromJson(c)).toList()
        : [];
    var intupdate = "Update product_store_inventory set qty = (qty - " +
        produtdata.detail_qty.toString() +
        ") WHERE product_id = " +
        produtdata.product_id.toString();
    //var updateed = await db.rawUpdate(intupdate);
    var productitem = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [produtdata.product_id]);
    List<ProductStoreInventory> inventory = productitem.length > 0
        ? productitem.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    /* await SyncAPICalls.logActivity("Order", "update InventoryTable",
        "product_store_inventory", produtdata.product_id); */
    return inventory;
  }

  Future<List<ProductStoreInventory>> getStoreInventoryData(productID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var inventoryProd = await db.query("product_store_inventory",
        where: 'product_id = ?', whereArgs: [productID]);
    List<ProductStoreInventory> list = inventoryProd.length > 0
        ? inventoryProd.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> updateInvetory(List<ProductStoreInventory> data) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    if (data.length > 0) {
      for (var i = 0; i < data.length; i++) {
        await db.update("product_store_inventory", data[i].toJson(),
            where: "inventory_id =?", whereArgs: [data[i].inventoryId]);
        /* await SyncAPICalls.logActivity("Order", "update InventoryTable",
            "product_store_inventory", data[i].productId); */
      }
      return 1;
    }
  }

  Future<int> updateStoreInvetoryLogTable(
      List<ProductStoreInventoryLog> log) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    if (log.length > 0) {
      for (var i = 0; i < log.length; i++) {
        await db.insert("product_store_inventory_log", log[i].toJson());
        /* await SyncAPICalls.logActivity("product_store_inventory_log insert",
            "insert", "product_store_inventory_log", log[i].inventory_id); */
      }
    }
    return 1;
  }

  /* Future<Branch> getBranchData(branchID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.query("branch", where: 'branch_id = ?', whereArgs: [branchID]);
    List<Branch> list =
        result.isNotEmpty ? result.map((c) => Branch.fromJson(c)).toList() : [];

    return list[0];
  } */

  // 1 For New,2 For Ongoing,3 For cancelled,4 For Completed,5 For Refunded
  Future updateOrderStatus(Orders orderdata) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db.update("orders", orderdata.toJson(),
        where: "app_id =?", whereArgs: [orderdata.app_id]);
    /* await SyncAPICalls.logActivity("order staus change", "update order status",
        "order_status", orderdata.app_id); */
  }

  Future<int> updatePaymentStatus(
      orderid, terminalid, status, upDate, userid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result;
    String qry = "UPDATE order_payment SET op_status = " +
        status.toString() +
        " , isSync = 0 ,updated_at = '" +
        upDate.toString() +
        "' ,updated_by =" +
        userid.toString() +
        " where terminal_id = " +
        terminalid.toString() +
        " AND order_app_id = " +
        orderid.toString();
    result = await db.rawUpdate(qry);
    /* await SyncAPICalls.logActivity(
        "order payment", "Refunded Order payment", "order_paymemt", orderid); */
    if (result != null) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> insertCancelOrder(CancelOrder order) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.insert('order_cancel', order.toJson());
    /* await SyncAPICalls.logActivity("cancel transaction",
        "Chasier canceled transaction", "order_cancel", 1); */
    return result;
  }

  Future<List<Table_order>> getTableOrders(tableid) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/tableorders';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'tableid': tableid
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Table_order> list =
        body.isNotEmpty ? body.map((c) => Table_order.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<User>> getUser() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String query = "SELECT * from users";
    List<Map<String, dynamic>> user = await db.rawQuery(query);
    List<User> list =
        user.isNotEmpty ? user.map((c) => User.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<User>> checkUserExit(userpin) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/auth/me';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'pin': userpin.toString()
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<User> list =
        body.isNotEmpty ? body.map((c) => User.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<int> deleteOrderItem(detailid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db
        .rawDelete("DELETE FROM order_detail WHERE app_id = ?", [detailid]);
    /* await SyncAPICalls.logActivity(
        "delete order item", "delete order items", "order_detail", detailid); */
    return result;
  }

  Future<List<MST_Cart>> getCartList(branchid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db.rawQuery(
        "SELECT * FROM mst_cart WHERE branch_id = " + branchid.toString());
    List<MST_Cart> list = result.isNotEmpty
        ? result.map((c) => MST_Cart.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getPrinter(productID) async {
    /* Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT * from printer where printer.printer_id = (Select printer_id from product_branch WHERE product_branch.product_id = $productID)";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list; */

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/printers';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'productid': productID
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Printer> list =
        body.isNotEmpty ? body.map((c) => Printer.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Printer>> getAllPrinter() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from printer where status = 1";
    var result = await db.rawQuery(qry);
    List<Printer> list = result.isNotEmpty
        ? result.map((c) => Printer.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Printer>> getAllPrinterForKOT() async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/kitchenprinters';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Printer> list =
        body.isNotEmpty ? body.map((c) => Printer.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }

  }

  Future<List<Printer>> getAllPrinterForecipt() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/receiptprinters';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Printer> list =
        body.isNotEmpty ? body.map((c) => Printer.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }

  }
  

  Future updateWebCart(MST_Cart cart) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT id from mst_cart where id = " + cart.id.toString();

    var res = await db.rawQuery(qry);
    List<MST_Cart> list =
        res.isNotEmpty ? res.map((c) => MST_Cart.fromJson(c)).toList() : [];
    var result;
    if (list.length > 0) {
      result = await db.update("mst_cart", cart.toJson(),
          where: "id =?", whereArgs: [cart.id]);
    } else {
      result = await db.insert("mst_cart", cart.toJson());
    }
    /* 
    await SyncAPICalls.logActivity(
        "update web cart", "update web cart", "mst_cart", cart.id); */
    return result;
  }

  Future<bool> updateCartListDetails(
      List<MSTCartdetails> detailsList, int cartId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    List<int> originalIdList =
        detailsList.isNotEmpty ? detailsList.map((ele) => ele.id).toList() : [];

    String deleteQry = "DELETE FROM mst_cart_detail WHERE id NOT IN (" +
        originalIdList.join(",") +
        ") AND cart_id = " +
        cartId.toString();
    /* String selectQry =
        "SELECT id from mst_cart_detail where cart_id = " + cartId.toString();
    var selectRes = await db.rawQuery(selectQry);
    List<int> returnList = selectRes.isNotEmpty
        ? selectRes
            .map((ele) => int.tryParse(ele.values.single.toString()))
            .toList()
        : []; */
    //print('Current  Cart detail Id List : ' + returnList.join(', '));
    //print('Original Cart detail Id List : ' + originalIdList.join(', '));

    if (originalIdList.length > 0) {
      for (MSTCartdetails detail in detailsList) {
        if (detail.isSendKichen == 1) {
          await updateWebCartdetails(detail);
        }
      }
      try {
        await db.rawQuery(deleteQry); //action delete new item added
      } catch (e) {
        print(e.toString());
      }
      return true;
    }
    //await db.update("mst_cart_detail");
    return false;
  }

  Future updateWebCartdetails(MSTCartdetails details) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT id from mst_cart_detail where id = " + details.id.toString();

    var res = await db.rawQuery(qry);
    List<MSTCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    var result;
    var newObj = details.toJson();
    newObj.remove("attr_name");
    newObj.remove("modi_name");
    if (list.length > 0) {
      result = await db.update("mst_cart_detail", newObj,
          where: "id =?", whereArgs: [details.id]);
    } else {
      result = await db.insert("mst_cart_detail", newObj);
    }
    /* 
    await SyncAPICalls.logActivity("update Web Cart details",
        "update Web Cart details", "mst_cart_detail", 1); */
    return result;
  }

  Future updateWebCartsubdetails(MSTSubCartdetails subdata) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT id from mst_cart_sub_detail where id = " +
        subdata.id.toString();
    var res = await db.rawQuery(qry);
    List<MSTSubCartdetails> list = res.isNotEmpty
        ? res.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
    var result;
    if (list.length > 0) {
      result = await db.update("mst_cart_sub_detail", subdata.toJson(),
          where: "id =?", whereArgs: [subdata.id]);
    } else {
      result = await db.insert("mst_cart_sub_detail", subdata.toJson());
    }
    /* 
    await SyncAPICalls.logActivity("update Web Cart sub details",
        "update Web Cart sub details", "mst_cart_sub_detail", 1); */
    return result;
  }

  Future<int> updateInvoice(Orders order) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result;
    if (order.order_item_count > 0) {
      result = await db
          .delete("orders", where: "app_id =?", whereArgs: [order.app_id]);
    } else {
      result = await db.update("orders", order.toJson(),
          where: "app_id =?", whereArgs: [order.app_id]);
    }
    /* await SyncAPICalls.logActivity(
        "update orders", "update orders", "orders", order.app_id); */
    return result;
  }

  Future<List<ProductDetails>> productdData(productid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        " SELECT product.*, price_type.name as price_type_Name , base64   from product " +
            " LEFT join price_type on price_type.pt_id = product.price_type_id AND price_type.status = 1 " +
            " LEFT join asset on asset.asset_type_id = product.product_id " +
            " where product_id = " +
            productid.toString();

    var res = await db.rawQuery(qry);
    List<ProductDetails> list = res.length > 0
        ? res.map((c) => ProductDetails.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<SetMeal>> setmealData(mealid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "select setmeal.* ,  base64  from setmeal " +
        " LEFT join setmeal_product on setmeal_product.setmeal_id = setmeal.setmeal_id " +
        " LEFT join asset on asset.asset_type = 2 AND asset.asset_type_id = setmeal.setmeal_id " +
        " WHERE setmeal.setmeal_id = " +
        mealid.toString() +
        " AND setmeal.status = 1 GROUP by setmeal.setmeal_id ";
    var mealList = await db.rawQuery(qry);
    List<SetMeal> list = mealList.isNotEmpty
        ? mealList.map((c) => SetMeal.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Role>> getRoldata(roleID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from role WHERE role_id = " + roleID.toString();
    var res = await db.rawQuery(qry);
    List<Role> list =
        res.isNotEmpty ? res.map((c) => Role.fromJson(c)).toList() : [];
    return list;
  }

  Future saveSyncOrder(Orders orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    /* var checkisExitqry = "SELECT * FROM orders where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND order_id =" +
        orderData.order_id.toString();
        await db.rawQuery(checkisExitqry); */
    var checkisExit = await db.query('orders',
        where: 'app_id =? AND terminal_id =? AND branch_id=?',
        whereArgs: [
          orderData.app_id,
          orderData.terminal_id,
          orderData.branch_id,
        ]);

    if (checkisExit != null && checkisExit.length > 0) {
      await db.update("orders", orderData.toJson(),
          where: "order_id =? AND terminal_id =?",
          whereArgs: [
            orderData.order_id,
            orderData.terminal_id,
          ]);
    } else {
      await db.insert("orders", orderData.toJson());
    }
    /* await SyncAPICalls.logActivity(
        "save Sync Order", "save Sync Order", "orders", orderData.app_id); */
  }

  Future saveSyncOrderDetails(OrderDetail orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_detail where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND order_app_id =" +
        orderData.order_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var newObj = orderData.toJson();
    newObj.remove("base64");
    if (checkisExit != null && checkisExit.length > 0) {
      await db.update("order_detail", newObj,
          where: "order_app_id =?  AND terminal_id =? ",
          whereArgs: [orderData.order_id, orderData.terminal_id]);
    } else {
      await db.insert("order_detail", newObj);
    }
    /* await SyncAPICalls.logActivity("save Sync OrderDetails",
        "save Sync OrderDetails", "orderdetails", orderData.app_id); */
  }

  Future saveSyncOrderPaymet(OrderPayment paymentdata) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExit = await db.query('order_payment',
        where: 'terminal_id =? AND order_app_id =? AND branch_id=?',
        whereArgs: [
          paymentdata.terminal_id,
          paymentdata.order_app_id,
          paymentdata.branch_id
        ]);
    /* "SELECT *  FROM order_payment where terminal_id = " +
        paymentdata.terminal_id.toString() +
        " AND app =" +
        paymentdata.order_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry); */

    if (checkisExit != null && checkisExit.length > 0) {
      await db.update("order_payment", paymentdata.toJson(),
          where: "order_app_id =? AND terminal_id =?",
          whereArgs: [paymentdata.order_id, paymentdata.terminal_id]);
    } else {
      await db.insert("order_payment", paymentdata.toJson());
    }
    /* await SyncAPICalls.logActivity("save Sync order payment",
        "save Sync order payment", "order_payment", paymentdata.app_id); */
  }

  Future saveSyncOrderModifire(OrderModifire orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    /* var checkisExitqry = "SELECT * FROM order_modifier where terminal_id = " +
        orderData.terminal_id.toString() +
        " AND app_id =" +
        orderData.app_id.toString();
        await db.rawQuery(checkisExitqry); */
    var checkisExit = await db.query('order_modifier',
        where: 'terminal_id=? AND app_id=?',
        whereArgs: [
          orderData.terminal_id,
          orderData.app_id,
        ]);
    var newObj = orderData.toJson();
    newObj.remove("name");
    if (checkisExit.length > 0) {
      await db.update("order_modifier", newObj,
          where: "app_id =?  AND terminal_id =?",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      await db.insert("order_modifier", newObj);
    }
    /* await SyncAPICalls.logActivity("save Sync order modifire",
        "save Sync order modifire", "order_modifier", orderData.app_id); */
  }

  Future saveSyncOrderAttribute(OrderAttributes orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM order_attributes where terminal_id = " +
            orderData.terminal_id.toString() +
            " AND app_id =" +
            orderData.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    var newObj = orderData.toJson();
    newObj.remove("name");
    if (checkisExit.length > 0) {
      orderid = await db.update("order_attributes", newObj,
          where: "app_id =? AND  terminal_id =?",
          whereArgs: [orderData.app_id, orderData.terminal_id]);
    } else {
      orderid = await db.insert("order_attributes", newObj);
    }
    /* await SyncAPICalls.logActivity("save Sync order attributes",
        "save Sync order attributes", "order_attributes", orderData.app_id); */
    return orderid;
  }

  Future<List<CancelOrder>> getCancleOrder(terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT * from order_cancel where isSync = 0 AND terminal_id = " +
            terminalid.toString() +
            " AND server_id = 0";
    var ordersList = await db.rawQuery(qry);
    List<CancelOrder> list = ordersList.length > 0
        ? ordersList.map((c) => CancelOrder.fromJson(c)).toList()
        : [];
    /* await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", terminalid); */
    return list;
  }

  Future saveVoucherHistoryTable(VoucherHistory voucher) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM voucher_history where terminal_id = " +
        voucher.terminal_id.toString() +
        " AND app_id =" +
        voucher.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    if (checkisExit.length > 0) {
      await db.update("voucher_history", voucher.toJson(),
          where: "app_id =? AND terminal_id =?",
          whereArgs: [voucher.app_id, voucher.terminal_id]);
    } else {
      await db.insert("voucher_history", voucher.toJson());
    }
    /* await SyncAPICalls.logActivity("save Sync voucher history",
        "save Sync voucher history", "voucher_history", voucher.app_id); */
  }

  Future<List<PosPermission>> getUserPermissions(userid) async {
 
    try {
      var url = await getMasterURL();
      var path = url + '/api/marslab/mine/permissions';

      Response response = await Dio().get(
        path,
        queryParameters: {
          'userid': userid
        },
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<PosPermission> list =
        body.isNotEmpty ? body.map((c) => PosPermission.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }

  }

  Future<List<ProductStoreInventory>> getProductStoreInventoryTable(
      branchid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from product_store_inventory where branch_id = " +
        branchid.toString();
    var ordersList = await db.rawQuery(qry);
    List<ProductStoreInventory> list = ordersList.length > 0
        ? ordersList.map((c) => ProductStoreInventory.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<ProductStoreInventoryLog>> getProductStoreInventoryLogTable(
      inventoryid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT * from product_store_inventory_log where IFNULL(server_id,'') = '' AND inventory_id = " +
            inventoryid.toString();
    var inList = await db.rawQuery(qry);
    List<ProductStoreInventoryLog> list = inList.length > 0
        ? inList.map((c) => ProductStoreInventoryLog.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<int> saveSyncInvStoreTable(
      ProductStoreInventory storeInventory) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM product_store_inventory where inventory_id =" +
            storeInventory.inventoryId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var inveID;
    if (checkisExit.length > 0) {
      inveID = await db.update(
          "product_store_inventory", storeInventory.toJson(),
          where: "inventory_id =?", whereArgs: [storeInventory.inventoryId]);
    } else {
      inveID =
          await db.insert("product_store_inventory", storeInventory.toJson());
    }
    return inveID;
  }

  Future<int> saveSyncInvStoreLogTable(ProductStoreInventoryLog logData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM product_store_inventory_log where il_id =" +
            logData.il_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var orderid;
    if (checkisExit.length > 0) {
      orderid = await db.update("product_store_inventory_log", logData.toJson(),
          where: "il_id =?", whereArgs: [logData.il_id]);
    } else {
      orderid =
          await db.insert("product_store_inventory_log", logData.toJson());
    }
    return orderid;
  }

  Future<int> saveSyncCancelTable(CancelOrder orderData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM order_cancel where order_app_id =" +
        orderData.order_app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var inveID;
    if (checkisExit.length > 0) {
      inveID = await db.update("order_cancel", orderData.toJson(),
          where: "order_app_id =? AND terminal_id =?",
          whereArgs: [orderData.order_app_id, orderData.terminalId]);
    } else {
      inveID = await db.insert("order_cancel", orderData.toJson());
    }
    /* await SyncAPICalls.logActivity("save Sync order cancel",
        "save Sync order cancel", "order_cancel", orderData.order_app_id); */
    return inveID;
  }

  Future<Map<String, String>> getClosingData(String branchID, String terminalID,
      [String filtertime]) async {
    Map<String, String> data = new Map();
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT SUM(rounding_amount) AS rounding, " +
        " SUM(grand_total) AS total," +
        " SUM(sub_total) AS sub_total," +
        " SUM(service_charge) AS service_charge," +
        " SUM(tax_amount) AS tax_amount" +
        " FROM orders WHERE order_status = 4";
    if (branchID != null && branchID.isNotEmpty)
      qry += ' AND branch_id = ' + branchID;
    if (terminalID != null && terminalID.isNotEmpty)
      qry += ' AND terminal_id = ' + terminalID;
    if (filtertime != null && filtertime.isNotEmpty)
      qry += " AND updated_at > '" + filtertime + "'";
    List<Map<String, dynamic>> orderList = await db.rawQuery(qry);
    if (orderList.isNotEmpty) {
      Map<String, dynamic> firstRow = orderList[0];
      data["sales_total"] = double.tryParse((firstRow["total"] ?? 0).toString())
          .toStringAsFixed(2);
      data["net_total"] =
          double.tryParse((firstRow["sub_total"] ?? 0).toString())
              .toStringAsFixed(2);
      data["service_charge"] =
          double.tryParse((firstRow["service_charge"] ?? 0).toString())
              .toStringAsFixed(2);
      data["tax"] = double.tryParse((firstRow["tax_amount"] ?? 0).toString())
          .toStringAsFixed(2);
      data["rounding"] = double.tryParse((firstRow["rounding"] ?? 0).toString())
          .toStringAsFixed(2);
    }
    return data;
  }

  Future<List<Orders>> getShiftInvoiceData(branchid, [filtertime]) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT * from orders where branch_id = " + branchid.toString();
    if (filtertime != null) {
      qry += " AND updated_at > '" + filtertime + "'";
    }
    var ordersList = await db.rawQuery(qry);
    List<Orders> list = ordersList.isNotEmpty
        ? ordersList.map((c) => Orders.fromJson(c)).toList()
        : [];
    /* await SyncAPICalls.logActivity(
        "Order sync", "get Orders list", "Orders", branchid); */
    return list;
  }

  Future<List<SetMeal>> getMealsData(branchid) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/meals';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<SetMeal> list =
        body.isNotEmpty ? body.map((c) => SetMeal.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<SetMealProduct>> getMealsProductData(setmealid) async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/mealproducts';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      print(response.data);
      print(jsonEncode(body));

      List<SetMealProduct> list =
        body.isNotEmpty ? body.map((c) => SetMealProduct.fromJson(c)).toList() : [];

        print(jsonEncode(list));

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<Drawerdata>> getPayinOutammount(shiftid, [filtertime]) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from drawer where shift_id = " + shiftid.toString();
    if (filtertime != null) {
      qry += " AND updated_at > '" + filtertime + "'";
    }
    var mealList = await db.rawQuery(qry);
    List<Drawerdata> list = mealList.isNotEmpty
        ? mealList.map((c) => Drawerdata.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<Map<String, String>> getDrawerData(String terminalID,
      [String filtertime]) async {
    Map<String, String> data = new Map();
    Database db = DatabaseHelper.dbHelper.getDatabse();

    String addQry = "";
    if (terminalID != null && terminalID.isNotEmpty)
      addQry += ' AND terminalid = ' + terminalID;
    if (filtertime != null && filtertime.isNotEmpty)
      addQry += " AND updated_at > '" + filtertime + "'";

    String qry =
        "SELECT SUM(amount) AS amount FROM drawer WHERE is_amount_in = 0";
    qry += addQry;
    List<Map<String, dynamic>> dataList;
    try {
      dataList = await db.rawQuery(qry);
    } catch (e) {
      print(e.toString());
      return data;
    }
    if (dataList.isNotEmpty) {
      Map<String, dynamic> firstRow = dataList[0];
      data["refund"] = double.tryParse((firstRow["amount"] ?? 0).toString())
          .toStringAsFixed(2);
    }
    qry = "SELECT SUM(amount) AS amount FROM drawer WHERE is_amount_in = 1";
    qry += addQry;
    dataList = await db.rawQuery(qry);
    if (dataList.isNotEmpty) {
      Map<String, dynamic> firstRow = dataList[0];
      data["cash_in"] = double.tryParse((firstRow["amount"] ?? 0).toString())
          .toStringAsFixed(2);
    }
    qry = "SELECT SUM(amount) AS amount FROM drawer WHERE is_amount_in = 2";
    qry += addQry;
    dataList = await db.rawQuery(qry);
    if (dataList.isNotEmpty) {
      Map<String, dynamic> firstRow = dataList[0];
      data["cash_out"] = double.tryParse((firstRow["amount"] ?? 0).toString())
          .toStringAsFixed(2);
    }
    print(data);
    return data;
  }

  Future<int> saveInOutDrawerData(Drawerdata drawerData) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var inveID = await db.insert("drawer", drawerData.toJson());
    /* await SyncAPICalls.logActivity(
        "save in out", "in out drawer data", "drawer", drawerData.shiftId); */
    return inveID;
  }

  Future<List<SaveOrder>> gettableCartID(saveorderid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "select save_order.cart_id from table_order " +
        " LEFT join save_order on save_order.id = table_order.save_order_id " +
        " WHERE table_order.save_order_id = " +
        saveorderid.toString();
    var result = await db.rawQuery(qry);
    List<SaveOrder> list = result.length > 0
        ? result.map((c) => SaveOrder.fromJson(c)).toList()
        : [];
    if (list.length > 0 && list[0].cartId != null) {
      return list;
    } else {
      return [];
    }
  }

  Future changeTable(tableID, totableid, cartid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "UPDATE table_order SET table_id= " +
        totableid.toString() +
        " where table_id = " +
        tableID.toString();
    await db.rawQuery(qry);
    if (cartid != null) {
      String qry1 = "UPDATE mst_cart SET table_id = " +
          totableid.toString() +
          " where  id = " +
          cartid.toString();
      await db.rawQuery(qry1);
    }
    /* await SyncAPICalls.logActivity(
        "table selection", "change table", "table_order", cartid); */
  }

  Future makeAsFocProduct(MSTCartdetails focProduct, isUpdate, MST_Cart cart,
      MSTCartdetails cartitem) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var newObj = focProduct.toJson();
    newObj.remove("attr_name");
    newObj.remove("modi_name");
    if (isUpdate) {
      await db.update("mst_cart_detail", newObj,
          where: "id =?", whereArgs: [focProduct.id]);
    } else {
      await db.insert(
        "mst_cart_detail",
        newObj,
      );
      var existObj = cartitem.toJson();
      existObj.remove("attr_name");
      existObj.remove("modi_name");
      await db.update("mst_cart_detail", existObj,
          where: "id =?", whereArgs: [cartitem.id]);
    }
    await db.update("mst_cart", cart.toJson(),
        where: "id =?", whereArgs: [cart.id]);
    /* await SyncAPICalls.logActivity(
        "mst_cart_detail", "Added Foc Product", "mst_cart_detail", cart.id); */
  }

  Future deleteOrderid(orderid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    await db.delete("orders", where: "app_id =?", whereArgs: [orderid]);
    //print(res);
  }

  Future<List<Countrys>> getCountrysList() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var contryList = await db.query("country");
    List<Countrys> list = contryList.isNotEmpty
        ? contryList.map((c) => Countrys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<States>> getStatesList() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var stateList = await db.query("state");
    List<States> list = stateList.isNotEmpty
        ? stateList.map((c) => States.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Citys>> getCitysList() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var cityList = await db.query("city");
    List<Citys> list = cityList.isNotEmpty
        ? cityList.map((c) => Citys.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Customer>> getCustomersforSend(teminalID) async {
    var query =
        "SELECT * from customer WHERE IFNULL(server_id,'')='' AND terminal_id = " +
            teminalID.toString();
    var res = await DatabaseHelper.dbHelper.getDatabse().rawQuery(query);
    List<Customer> list =
        res.isNotEmpty ? res.map((c) => Customer.fromJson(c)).toList() : [];

    return list;
  }

  Future<int> getLastCustomerid(terminalid) async {
    String qry = "SELECT customer.app_id from customer where terminal_id =" +
        terminalid +
        "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<Customer> list = checkisExit.length > 0
        ? checkisExit.map((c) => Customer.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<List<Rac>> getRacList(branchID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from rac where branch_id = " +
        branchID.toString() +
        " AND status = 1";
    var result = await db.rawQuery(qry);
    List<Rac> list =
        result.length > 0 ? result.map((c) => Rac.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Box>> getBoxList(branchID, racID, customerid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from box LEFT JOIN customer_liquor_inventory on" +
        " customer_liquor_inventory.cl_box_id = box.box_id" +
        " where box.branch_id = " +
        branchID.toString() +
        " AND box.rac_id = " +
        racID.toString() +
        " AND box.status = 1 " +
        " AND customer_liquor_inventory.cl_customer_id = " +
        customerid.toString();
    var result = await db.rawQuery(qry);
    List<Box> list =
        result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> getLastCustomerInventory() async {
    var qey = "SELECT app_id from customer_liquor_inventory " +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Customer_Liquor_Inventory> list = checkisExit.length > 0
        ? checkisExit.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> getLastCustomerInventoryLog() async {
    var qey = "SELECT app_id from customer_liquor_inventory_log " +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qey);
    List<Customer_Liquor_Inventory_Log> list = checkisExit.length > 0
        ? checkisExit
            .map((c) => Customer_Liquor_Inventory_Log.fromJson(c))
            .toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> insertWineInventory(
      Customer_Liquor_Inventory data, isUpdate) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var invData = data.toJson();
    await invData.remove("name");
    var result;
    if (isUpdate) {
      result = await db.update("customer_liquor_inventory", invData,
          where: "app_id =?", whereArgs: [data.appId]);
    } else {
      result = await db.insert("customer_liquor_inventory", invData);
    }
    /* await SyncAPICalls.logActivity("customer liquor inventory",
        "insert Wine inventory", "customer_liquor_inventory", data.clBranchId); */
    return result;
  }

  Future<int> insertWineInventoryLog(Customer_Liquor_Inventory_Log data) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result =
        await db.insert("customer_liquor_inventory_log", data.toJson());
    /* await SyncAPICalls.logActivity(
        "customer liquor inventory log",
        "insert Wine inventory log",
        "customer_liquor_inventory_log",
        data.branchId); */
    return result;
  }

  Future<List<Customer_Liquor_Inventory>> getCustomerRedeem(customerid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT customer_liquor_inventory.*,box.name from customer_liquor_inventory" +
            " LEFT JOIN box on box.box_id = customer_liquor_inventory.cl_box_id " +
            " WHERE cl_customer_id = " +
            customerid.toString();
    var result = await db.rawQuery(qry);
    List<Customer_Liquor_Inventory> list = result.length > 0
        ? result.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Customer_Liquor_Inventory>> getCustomersWineInventory(
      branchID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var query =
        "SELECT * from customer_liquor_inventory WHERE IFNULL(server_id,'')='' AND cl_branch_id = " +
            branchID.toString();
    var res = await db.rawQuery(query);
    List<Customer_Liquor_Inventory> list = res.isNotEmpty
        ? res.map((c) => Customer_Liquor_Inventory.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<Customer_Liquor_Inventory_Log>> getCustomersWineInventoryLogs(
      branchID, appid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var query =
        "SELECT * from customer_liquor_inventory_log WHERE IFNULL(server_id,'')='' AND cl_appId = " +
            appid.toString();
    var res = await db.rawQuery(query);
    List<Customer_Liquor_Inventory_Log> list = res.isNotEmpty
        ? res.map((c) => Customer_Liquor_Inventory_Log.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<int> saveSuctomerWineInventory(
      Customer_Liquor_Inventory customerInv) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer_liquor_inventory where app_id =" +
            customerInv.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update(
          "customer_liquor_inventory", customerInv.toJson(),
          where: "app_id =?", whereArgs: [customerInv.appId]);
    } else {
      result =
          await db.insert("customer_liquor_inventory", customerInv.toJson());
    }
    return result;
  }

  Future<int> saveSuctomerWineInventoryLogs(
      Customer_Liquor_Inventory_Log customerInv) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM customer_liquor_inventory_log where app_id =" +
            customerInv.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update(
          "customer_liquor_inventory_log", customerInv.toJson(),
          where: "app_id =?", whereArgs: [customerInv.appId]);
    } else {
      result = await db.insert(
          "customer_liquor_inventory_log", customerInv.toJson());
    }
    return result;
  }

  Future<List<Box>> getBoxForProduct(productId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from box where product_id = " +
        productId.toString() +
        " AND status = 1";
    var result = await db.rawQuery(qry);
    List<Box> list =
        result.length > 0 ? result.map((c) => Box.fromJson(c)).toList() : [];
    return list;
  }

  Future<dynamic> getTotalPayment(terminalid, branchid, [filtertime]) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT *, SUM(op_amount-COALESCE(op_amount_change,0)) AS op_amount from order_payment WHERE terminal_id = " +
            terminalid +
            " AND branch_id = " +
            branchid.toString();
    if (filtertime != null) {
      qry += " AND updated_at > '" + filtertime + "' ";
    }
    /*  result = await db.rawQuery(qry);
    list = result.length > 0
        ? result.map((c) => OrderPayment.fromJson(c)).toList()
        : []; */
    qry += " GROUP by op_method_id";
    var result = await db.rawQuery(qry);
    List<OrderPayment> list = result.length > 0
        ? result.map((c) => OrderPayment.fromJson(c)).toList()
        : [];
    List<Payments> paymentMethods = [];
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        OrderPayment opayment = list[i];
        String qry = "SELECT * FROM payment WHERE payment_id = " +
            opayment.op_method_id.toString();
        var result = await db.rawQuery(qry);
        List<Payments> plist = result.length > 0
            ? result.map((c) => Payments.fromJson(c)).toList()
            : [];
        if (plist.length > 0) {
          paymentMethods.add(plist[0]);
        }
      }
    }
    var data = {"payment_method": paymentMethods, "payments": list};
    return data;
  }

  Future<int> getLastShiftAppID(terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT shift.app_id from shift where terminal_id =" +
        terminalid +
        "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await db.rawQuery(qry);
    List<Shift> list = checkisExit.length > 0
        ? checkisExit.map((c) => Shift.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].appId;
    } else {
      return 0;
    }
  }

  Future<int> getLastShiftInvoiceAppID(terminalid) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT shift_invoice.app_id from shift_invoice where terminal_id =" +
            terminalid +
            "  ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await db.rawQuery(qry);
    List<ShiftInvoice> list = checkisExit.length > 0
        ? checkisExit.map((c) => ShiftInvoice.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].app_id;
    } else {
      return 0;
    }
  }

  Future<List<Shift>> getShiftDatabaseTable(branchid, termianlId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from shift WHERE branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        termianlId.toString() +
        " AND server_id = 0";
    var shiftList = await db.rawQuery(qry);
    List<Shift> list = shiftList.length > 0
        ? shiftList.map((c) => Shift.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<ShiftInvoice>> getShiftInvoiceTable(termianlId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry =
        "SELECT * from shift_invoice WHERE server_id = 0 AND terminal_id = " +
            termianlId.toString();
    var inList = await db.rawQuery(qry);
    List<ShiftInvoice> list = inList.length > 0
        ? inList.map((c) => ShiftInvoice.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<int> saveShiftDatafromSync(Shift shift) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry =
        "SELECT *  FROM shift where app_id =" + shift.appId.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("shift", shift.toJson(),
          where: "app_id =?", whereArgs: [shift.appId]);
    } else {
      result = await db.insert("shift", shift.toJson());
    }
    /* 
    await SyncAPICalls.logActivity(
        "sync shift data", "Save shift data from server", "shift", shift.appId); */
    return result;
  }

  Future<int> saveShiftInvoiceDatafromSync(ShiftInvoice shiftInv) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var checkisExitqry = "SELECT *  FROM shift_invoice where app_id =" +
        shiftInv.app_id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("shift_invoice", shiftInv.toJson(),
          where: "app_id =?", whereArgs: [shiftInv.app_id]);
    } else {
      result = await db.insert("shift_invoice", shiftInv.toJson());
    }
    /* 
    await SyncAPICalls.logActivity("sync shift details",
        "Save shift details from server", "shift_details", shiftInv.app_id); */
    return result;
  }

  Future<int> getLastVoucherHistoryid(terminalid) async {
    String qry = "SELECT app_id from voucher_history where terminal_id =" +
        terminalid +
        " ORDER BY app_id DESC LIMIT 1";
    var checkisExit = await DatabaseHelper.dbHelper.getDatabse().rawQuery(qry);
    List<VoucherHistory> list = checkisExit.length > 0
        ? checkisExit.map((c) => VoucherHistory.fromJson(c)).toList()
        : [];
    if (list.length > 0) {
      return list[0].app_id;
    } else {
      return 0;
    }
  }

  Future<String> getTerminalKey() async {
    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/terminal/id';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      return pick(response.data).asStringOrNull();

    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<List<TerminalLog>> getTerminalLogTables(branchid, termianlId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String qry = "SELECT * from terminal_log  WHERE branch_id = " +
        branchid.toString() +
        " AND terminal_id = " +
        termianlId.toString() +
        " AND is_sync = 0";
    var shiftList = await db.rawQuery(qry);
    List<TerminalLog> list = shiftList.length > 0
        ? shiftList.map((c) => TerminalLog.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<int> saveTerminalLogFromSync(TerminalLog log) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    String checkisExitqry =
        "SELECT *  FROM terminal_log where id =" + log.id.toString();
    var checkisExit = await db.rawQuery(checkisExitqry);
    var result;
    if (checkisExit.length > 0) {
      result = await db.update("terminal_log", log.toJson(),
          where: "id =?", whereArgs: [log.id]);
    }
    /* else {
      result = await db.insert("terminal_log", log.toJson());
    } */
    /* 
    await SyncAPICalls.logActivity("sync terminal log",
        "Save terminal log from server", "terminal_log", log.id); */
    return result;
  }

  Future<int> deleteTerminalLogAfterSync(List<TerminalLog> logList) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    for (TerminalLog log in logList) {
      await db.delete("terminal_log", where: "id =?", whereArgs: [log.id]);
    }
  }

  //Reservation
  Future<int> addReservation(Reservation reservation,
      [int reservationID]) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    try {
      if (reservationID != null) {
        return await db.update("reservation", reservation.toJson(),
            where: "id=?", whereArgs: [reservationID]);
      } else {
        return await db.insert("reservation", reservation.toJson());
      }
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<List<Reservation>> getReservationList() async {

    try {

      var url = await getMasterURL();
      var path = url + '/api/marslab/reservations';

      Response response = await Dio().get(
        path,
        options: Options(contentType: 'application/json')
      );

      List body = jsonDecode(response.data);

      List<Reservation> list =
        body.isNotEmpty ? body.map((c) => Reservation.fromJson(c)).toList() : [];

      return list;

    } catch (error) {
      print(error);
      rethrow;
    }

  }

  Future<List<MSTCartdetails>> getReservationItems(String reservationNo) async {
    reservationNo = reservationNo.trim();
    Database db = DatabaseHelper.dbHelper.getDatabse();
    List<MSTCartdetails> list = [];
    var test = await db.query("mst_cart_detail");
    list = test.isNotEmpty
        ? test.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    String qry = " SELECT mst_cart_detail.* ,group_concat(attributes.name) as attrName ,group_concat(modifier.name) as modiName from mst_cart_detail " +
        " LEFT JOIN mst_cart_sub_detail on mst_cart_sub_detail.cart_details_id = mst_cart_detail.id AND  (mst_cart_sub_detail.attribute_id != '' OR mst_cart_sub_detail.modifier_id != '' )" +
        " LEFT JOIN attributes on attributes.attribute_id = mst_cart_sub_detail.attribute_id  AND  mst_cart_sub_detail.attribute_id != '' " +
        " LEFT JOIN modifier on modifier.modifier_id = mst_cart_sub_detail.modifier_id AND mst_cart_sub_detail.modifier_id != '' " +
        " where mst_cart_detail.res_no ='" +
        reservationNo +
        "' group by mst_cart_detail.id";
    var res = await db.rawQuery(qry);
    list = res.isNotEmpty
        ? res.map((c) => MSTCartdetails.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> removeReservationItems(int reservationId) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    return db.delete("reservation", where: "id=?", whereArgs: [reservationId]);
  }

  Future<int> reservationToCartProduct(List<MSTCartdetails> productList,
      List<MSTSubCartdetails> subDetails, String reservationNo) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    int cartDetailID;
    int result = 0;
    for (MSTCartdetails product in productList) {
      List<MSTSubCartdetails> selectedProductModiferList = subDetails
          .where((ele) => ele.cartdetailsId == product.cartId)
          .toList();
      List<MSTSubCartdetails> selectedProductAttList = subDetails
          .where((ele) => ele.cartdetailsId == product.cartId)
          .toList();
      Map<String, dynamic> jsonDetail = new Map();
      try {
        jsonDetail = product.toJson();
        jsonDetail.remove("attr_name");
        jsonDetail.remove("modi_name");
        cartDetailID = await db.update(
          "mst_cart_detail",
          jsonDetail,
          where: "id=? AND res_no=?",
          whereArgs: [product.id, reservationNo],
        );
        result = 1;
      } catch (e) {
        print(e);
      }
      try {
        for (MSTSubCartdetails productDetail in selectedProductModiferList) {
          productDetail.cartdetailsId = cartDetailID;
          jsonDetail = productDetail.toJson();
          jsonDetail.remove("id");
          result = await db.update(
            "mst_cart_sub_detail",
            productDetail.toJson(),
            where: "id=? AND res_no=?",
            whereArgs: [productDetail.id, reservationNo],
          );
        }
      } catch (e) {
        print(e);
      }
      try {
        for (MSTSubCartdetails productDetail in selectedProductAttList) {
          productDetail.cartdetailsId = cartDetailID;
          jsonDetail = productDetail.toJson();
          jsonDetail.remove("id");
          result = await db.update(
            "mst_cart_sub_detail",
            productDetail.toJson(),
            where: "id=? AND res_no=?",
            whereArgs: [productDetail.id, reservationNo],
          );
        }
      } catch (e) {
        print(e);
      }
    }
    return result;
  }

  Future<List<MSTSubCartdetails>> getSubDetail(String resNo) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    List<Map<String, dynamic>> result = await db
        .query("mst_cart_sub_detail", where: "res_no=?", whereArgs: [resNo]);

    return result.isNotEmpty
        ? result.map((c) => MSTSubCartdetails.fromJson(c)).toList()
        : [];
  }

  Future<int> insertReservationProduct(
      List<MSTCartdetails> productList,
      String resNo,
      List<MSTSubCartdetails> itemModifierList,
      List<MSTSubCartdetails> itemAttributesList,
      [String reservationNo]) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    int cartDetailID;
    Map<String, dynamic> jsonDetail = new Map();
    try {
      for (MSTCartdetails product in productList) {
        List<MSTSubCartdetails> selectedProductModiferList = itemModifierList
            .where((ele) => ele.cartdetailsId == product.cartId)
            .toList();
        List<MSTSubCartdetails> selectedProductAttList = itemAttributesList
            .where((ele) => ele.cartdetailsId == product.cartId)
            .toList();

        if (reservationNo != null) {
          product.resNo = reservationNo;
        } else {
          product.resNo = resNo;
        }
        jsonDetail = product.toJson();
        jsonDetail.remove("attr_name");
        jsonDetail.remove("modi_name");
        jsonDetail.remove("cart_id");
        if (reservationNo != null) {
          jsonDetail.remove("id");
          cartDetailID = await db.update("mst_cart_detail", jsonDetail,
              where: "id=? AND res_no=?", whereArgs: [product.id, resNo]);
        } else {
          cartDetailID = await db.insert("mst_cart_detail", jsonDetail);
        }
        if (cartDetailID > 0) {
          for (MSTSubCartdetails productDetail in selectedProductModiferList) {
            productDetail.cartdetailsId = cartDetailID;
            if (reservationNo != null) {
              jsonDetail = productDetail.toJson();
              jsonDetail.remove("id");
              await db.update("mst_cart_sub_detail", productDetail.toJson(),
                  where: "id=? AND res_no=?",
                  whereArgs: [productDetail.id, resNo]);
            } else {
              await db.insert("mst_cart_sub_detail", productDetail.toJson());
            }
          }
          for (MSTSubCartdetails productDetail in selectedProductAttList) {
            productDetail.cartdetailsId = cartDetailID;
            if (reservationNo != null) {
              jsonDetail = productDetail.toJson();
              jsonDetail.remove("id");
              await db.update("mst_cart_sub_detail", productDetail.toJson(),
                  where: "id=? AND res_no=?",
                  whereArgs: [productDetail.id, resNo]);
            } else {
              await db.insert("mst_cart_sub_detail", productDetail.toJson());
            }
          }
        }
      }
      return 1;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<Customer> getCustomerData(String memberID) async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    var result = await db
        .query("customer", where: "memeber_id=?", whereArgs: [memberID]);
    return Customer.fromJson(result[0]);
  }

  Future<String> getLastReservationID() async {
    Database db = DatabaseHelper.dbHelper.getDatabse();
    List<Map<String, dynamic>> result = await db.query("reservation");
    if (result.length > 0) {
      Reservation res = Reservation.fromJson(result[result.length - 1]);
      return res.resNo;
    }
    return '1';
  }
}
