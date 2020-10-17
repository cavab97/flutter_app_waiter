import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/services/CommunAPICall.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SyncAPICalls {
  static getDataServerBulk1(context) async {
    var apiurl = Configrations.appdata1;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_1(context) async {
    var apiurl = Configrations.appdata2_1;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);

    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_2(context) async {
    var apiurl = Configrations.appdata2_2;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk2_3(context) async {
    var apiurl = Configrations.appdata2_3;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk3(context) async {
    var apiurl = Configrations.appdata3;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_1(context) async {
    var apiurl = Configrations.appdata4_1;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulk4_2(context) async {
    var apiurl = Configrations.appdata4_2;
    var branchid = await CommunFun.getbranchId();
    var terminalId = await CommunFun.getTeminalKey();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);

    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getAssets(context) async {
    var apiurl = Configrations.product_image;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var offset = await Preferences.getStringValuesSF(Constant.OFFSET);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branchId': branchid, // serverTime,
      'terminal_id': terminalId,
      'offset': offset != null ? int.parse(offset) : 10
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getConfig(context) async {
    var apiurl = Configrations.config;
    var stringParams = {};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static logActivity(moduleName, disc, tablename, eId) async {
    TerminalLog log = new TerminalLog();
    LocalAPI localAPI = LocalAPI();
    var uuid = await CommunFun.getLocalID();
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    User userdata = await CommunFun.getuserDetails();
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyy-MM-dd').format(now);
    final String time = DateFormat('HH:mm').format(now);
    var datetime = await CommunFun.getCurrentDateTime(DateTime.now());
    log.uuid = uuid;
    log.terminal_id = int.parse(terminalId);
    log.branch_id = int.parse(branchid);
    log.module_name = moduleName;
    log.discription = disc;
    log.activity_date = date;
    log.activity_time = time;
    log.table_name = tablename;
    log.entity_id = eId is int ? eId : int.parse(eId);
    log.status = 1;
    log.updated_at = datetime;
    log.updated_by = userdata.id;
    var logid = await localAPI.terminalLog(log);
  }

  static syncOrderstoDatabase(context) async {
    try {
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      var apiurl = Configrations.order_sync;
      List<Orders> orders = await localAPI.getOrdersListTable(branchid);
      if (orders.length > 0) {
        List ordersList = [];
        for (var i = 0; i < orders.length; i++) {
          var order = orders[i];
          List<OrderDetail> ordersDetail =
              await localAPI.getOrderDetailTable(order.app_id);
          List detailList = [];
          for (var j = 0; j < ordersDetail.length; j++) {
            var details = ordersDetail[j];
            List<OrderAttributes> ordersAttribute =
                await localAPI.getOrderAttributesTable(details.app_id);
            List<OrderModifire> ordersModifire =
                await localAPI.getOrderModifireTable(details.app_id);
            var productMap = {
              "detailId": details.detailId,
              "uuid": details.uuid,
              "order_id": details.order_id,
              "branch_id": details.branch_id,
              "terminal_id": details.terminal_id,
              "app_id": details.app_id,
              "product_id": details.product_id,
              "product_price": details.product_price,
              "product_old_price": details.product_old_price,
              "product_discount": details.product_discount,
              "product_detail": details.product_detail,
              "detail_datetime": details.detail_datetime,
              "category_id": details.category_id,
              "detail_amount": details.detail_amount,
              "detail_qty": details.detail_qty,
              "issetMeal": details.issetMeal,
              "setmeal_product_detail": details.setmeal_product_detail,
              "detail_status": details.detail_status,
              "detail_by": details.detail_by,
              "updated_at": details.updated_at,
              "updated_by": details.updated_by,
              "order_modifier": ordersModifire,
              "order_attributes": ordersAttribute,
            };
            detailList.add(productMap);
          }
          List<OrderPayment> ordersPayment =
              await localAPI.getOrderPaymentTable(order.app_id);
          var orderMap = {
            "order_id": order.order_id,
            "uuid": order.uuid,
            "branch_id": order.branch_id,
            "terminal_id": order.terminal_id,
            "app_id": order.app_id,
            // "table_no": order.table_no,
            "table_id": order.table_id,
            "invoice_no": order.invoice_no,
            "customer_id": order.customer_id,
            "tax_json": order.tax_json,
            "tax_percent": order.tax_percent,
            "tax_amount": order.tax_amount,
            "voucher_detail": order.voucher_detail,
            "voucher_id": order.voucher_id,
            "voucher_amount": order.voucher_amount,
            "sub_total": order.sub_total,
            "sub_total_after_discount": order.sub_total_after_discount,
            "grand_total": order.grand_total,
            "order_source": order.order_source,
            "order_status": order.order_status,
            "order_item_count": order.order_item_count,
            "order_date": order.order_date,
            "order_by": order.order_by,
            "server_id": order.server_id,
            "updated_at": order.updated_at,
            "updated_by": order.updated_by,
            "order_detail": detailList,
            'order_payment': ordersPayment
          };
          ordersList.add(orderMap);
        }
        var stringParams = {
          'terminal_id': terminalId,
          'branch_id': branchid,
          'orders': json.encode(ordersList)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);

        if (res["status"] == Constant.STATUS200) {
          await savesyncORderData(res["data"]);
          await CommunFun.showToast(context, "All orders upto dates.");
        }
      } else {
        CommunFun.showToast(context, "All orders upto dates.");
        Navigator.of(context).pop();
      }
      await SyncAPICalls.sendCancledOrderTable(context);
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static savesyncORderData(data) async {
    LocalAPI localAPI = LocalAPI();
    try {
      var orders = data["orders"];
      if (orders.length > 0) {
        for (var i = 0; i < orders.length; i++) {
          var orderdata = orders[i];
          Orders order = new Orders();
          order.order_id = orderdata["order_id"];
          order.uuid = orderdata["uuid"];
          order.branch_id = orderdata["branch_id"];
          order.terminal_id = orderdata["terminal_id"];
          order.app_id = orderdata["app_id"];
          order.table_id = orderdata["table_id"];
          order.invoice_no = orderdata["invoice_no"];
          order.customer_id = orderdata["customer_id"];
          order.tax_json = orderdata["tax_json"];
          order.tax_percent = orderdata["tax_percent"];
          order.tax_amount = orderdata["tax_amount"] is int
              ? (orderdata['tax_amount'] as int).toDouble()
              : orderdata['tax_amount'];
          order.voucher_detail = orderdata["voucher_detail"];
          order.voucher_id = orderdata["voucher_id"];
          order.voucher_amount = orderdata["voucher_amount"] is int
              ? (orderdata['voucher_amount'] as int).toDouble()
              : orderdata['voucher_amount'];
          order.sub_total = orderdata["sub_total"] is int
              ? (orderdata['sub_total'] as int).toDouble()
              : orderdata['sub_total'];
          order.sub_total_after_discount =
              orderdata["sub_total_after_discount"] is int
                  ? (orderdata['sub_total_after_discount'] as int).toDouble()
                  : orderdata['sub_total_after_discount'];
          order.grand_total = orderdata["grand_total"] is int
              ? (orderdata['grand_total'] as int).toDouble()
              : orderdata['grand_total'];
          order.server_id = orderdata["server_id"];
          order.order_source = orderdata["order_source"];
          order.order_status = orderdata["order_status"];
          order.order_item_count = orderdata["order_item_count"];
          order.order_date = orderdata["order_date"];
          order.order_by = orderdata["order_by"];
          order.updated_at = orderdata["updated_at"];
          order.updated_by = orderdata["updated_by"];
          var result = await localAPI.saveSyncOrder(order);

          var orderdetail = orderdata["order_detail"];
          if (orderdetail.length > 0) {
            for (var i = 0; i < orderdetail.length; i++) {
              var detail = orderdetail[i];
              OrderDetail o_details = new OrderDetail();
              o_details.detailId = detail["detailId"];
              o_details.uuid = detail["uuid"];
              o_details.order_id = detail["order_id"];
              o_details.branch_id = detail["branch_id"];
              o_details.terminal_id = detail["terminal_id"];
              o_details.app_id = detail["app_id"];
              o_details.product_id = detail["product_id"];
              o_details.issetMeal = detail["issetMeal"];
              o_details.setmeal_product_detail =
                  detail["setmeal_product_detail"];
              o_details.product_price = detail["product_price"] is int
                  ? (detail["product_price"] as int).toDouble()
                  : detail["product_price"];
              o_details.product_old_price = detail["product_old_price"] is int
                  ? (detail["product_old_price"] as int).toDouble()
                  : detail["product_old_price"];
              o_details.product_discount = detail["product_discount"] is int
                  ? (detail["product_discount"] as int).toDouble()
                  : detail["product_discount"];
              o_details.product_detail = detail["product_detail"];
              o_details.detail_datetime = detail["detail_datetime"];
              o_details.category_id = detail["category_id"];
              o_details.detail_amount = detail["detail_amount"] is int
                  ? (detail["detail_amount"] as int).toDouble()
                  : detail["detail_amount"];
              o_details.detail_qty = detail["detail_qty"] is int
                  ? (detail["detail_qty"] as int).toDouble()
                  : detail["detail_qty"];
              o_details.detail_status = detail["detail_status"];
              o_details.detail_by = detail["detail_by"];
              o_details.updated_at = detail["updated_at"];
              o_details.updated_by = detail["updated_by"];
              var result1 = await localAPI.saveSyncOrderDetails(o_details);

              var modifire = detail["order_modifier"];
              if (modifire.length > 0) {
                for (var m = 0; m < modifire.length; m++) {
                  var modifiredata = modifire[m];
                  OrderModifire m_data = new OrderModifire();
                  m_data.om_id = modifiredata["om_id"];
                  m_data.uuid = modifiredata["uuid"];
                  m_data.order_id = modifiredata["order_id"];
                  m_data.detail_id = modifiredata["detail_id"];
                  m_data.terminal_id = modifiredata["terminal_id"];
                  m_data.app_id = modifiredata["app_id"];
                  m_data.product_id = modifiredata["product_id"];
                  m_data.modifier_id = modifiredata["modifier_id"];
                  m_data.om_amount = modifiredata["om_amount"] is int
                      ? (modifiredata["om_amount"] as int).toDouble()
                      : modifiredata["om_amount"];
                  m_data.om_status = modifiredata["om_status"];
                  m_data.om_datetime = modifiredata["om_datetime"];
                  m_data.om_by = modifiredata["om_by"];
                  m_data.updated_at = modifiredata["updated_at"];
                  m_data.updated_by = modifiredata["updated_by"];
                  var datres = await localAPI.saveSyncOrderModifire(m_data);
                }
              }
              var attribute = detail["order_attributes"];
              if (attribute.length > 0) {
                for (var a = 0; a < attribute.length; a++) {
                  var attributeDt = attribute[a];
                  OrderAttributes attr = new OrderAttributes();
                  attr.oa_id = attributeDt["oa_id"];
                  attr.uuid = attributeDt["uuid"];
                  attr.order_id = attributeDt["order_id"];
                  attr.detail_id = attributeDt["detail_id"];
                  attr.terminal_id = attributeDt["terminal_id"];
                  attr.app_id = attributeDt["app_id"];
                  attr.product_id = attributeDt["product_id"];
                  attr.attribute_id = attributeDt["attribute_id"];
                  attr.attr_price = attributeDt["attr_price"] is int
                      ? (attributeDt["attr_price"] as int).toDouble()
                      : attributeDt["attr_price"];
                  attr.ca_id = attributeDt["ca_id"];
                  attr.oa_datetime = attributeDt["oa_datetime"];
                  attr.oa_by = attributeDt["oa_by"];
                  attr.oa_status = attributeDt["oa_status"];
                  attr.updated_at = attributeDt["updated_at"];
                  attr.updated_by = attributeDt["updated_by"];
                  var attrres = await localAPI.saveSyncOrderAttribute(attr);
                }
              }
            }
          }
          var paymentdetail = orderdata["order_payment"];
          if (paymentdetail.length > 0) {
            for (var p = 0; p < paymentdetail.length; p++) {
              var paydat = paymentdetail[p];
              OrderPayment paymentdat = new OrderPayment();
              paymentdat.op_id = paydat["op_id"];
              paymentdat.uuid = paydat["uuid"];
              paymentdat.order_id = paydat["order_id"];
              paymentdat.branch_id = paydat["branch_id"];
              paymentdat.terminal_id = paydat["terminal_id"];
              paymentdat.app_id = paydat["app_id"];
              paymentdat.op_method_id = paydat["op_method_id"];
              paymentdat.op_amount = paydat["op_amount"];
              paymentdat.op_method_response = paydat["op_method_response"];
              paymentdat.op_status = paydat["op_status"];
              paymentdat.op_datetime = paydat["op_datetime"];
              paymentdat.op_by = paydat["op_by"];
              paymentdat.updated_at = paydat["updated_at"];
              paymentdat.updated_by = paydat["updated_by"];
              // paymentdat.serverId = paydat["serverId"];
              var paymentres = await localAPI.saveSyncOrderPaymet(paymentdat);
            }
          }
        }
      }
    } catch (e) {
      print(e);
      //CommunFun.showToast(context, e.message);
    }
  }

  static getWebOrders(context) async {
    try {
      var apiurl = Configrations.web_orders;
      var terminalId = await CommunFun.getTeminalKey();
      var serverTime =
          await Preferences.getStringValuesSF(Constant.ORDER_SERVER_DATE_TIME);
      var stringParams = {
        'datetime': serverTime != null ? serverTime : '',
        'terminal_id': terminalId
      };
      return await APICalls.apiCall(apiurl, context, stringParams);
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static sendCancledOrderTable(context) async {
    try {
      var apiurl = Configrations.cancle_order;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<CancelOrder> orderdata = await localAPI.getCancleOrder(terminalId);
      if (orderdata.length > 0) {
        if (orderdata.length > 0) {
          var stringParams = {
            'branch_id': branchid,
            'terminal_id': terminalId,
            'order_cancel': json.encode(orderdata)
          };
          var res = await APICalls.apiCall(apiurl, context, stringParams);

          if (res["status"] == Constant.STATUS200) {
            saveCancleORderTable(res);
          }
          Navigator.of(context).pop();
          CommunFun.showToast(context, "Sync sucessfully done.");
        }
      } else {
        Navigator.of(context).pop();
       // CommunFun.showToast(context, "all cancel tables up to dates.");
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      CommunFun.showToast(context, e.message);
    }
  }

  static sendInvenotryTable(context) async {
    try {
      var apiurl = Configrations.update_inventory_table;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<ProductStoreInventory> storeData =
          await localAPI.getProductStoreInventoryTable(branchid);
      if (storeData.length > 0) {
        var invData = [];
        for (var i = 0; i < storeData.length; i++) {
          var storeitem = storeData[i];
          List<ProductStoreInventoryLog> logData = await localAPI
              .getProductStoreInventoryLogTable(storeitem.inventoryId);
          var invstoreItme = {
            'inventory_id': storeitem.inventoryId,
            'uuid': storeitem.uuid,
            'product_id': storeitem.productId,
            'branch_id': storeitem.branchId,
            'qty': storeitem.qty,
            'warningStockLevel': storeitem.warningStockLevel,
            'status': storeitem.status,
            'updated_at': storeitem.updatedAt,
            'updated_by': storeitem.updatedBy,
            'product_store_inventory_log': logData
          };
          invData.add(invstoreItme);
        }
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'store_inventory': json.encode(invData)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);

        if (res["status"] == Constant.STATUS200) {
          saveInvToTable(context, res);
        }
        Navigator.of(context).pop();
        CommunFun.showToast(context, "Sync sucessfully done.");
      } else {
        CommunFun.showToast(context, "all cancel tables up to dates.");
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveInvToTable(context, data) async {
    try {
      LocalAPI localAPI = LocalAPI();
      var storeData = data["data"]["product_store_inventory"];
      if (storeData.length > 0) {
        for (var i = 0; i < storeData.length; i++) {
          var storeitem = storeData[i];
          ProductStoreInventory inventory = new ProductStoreInventory();
          inventory.inventoryId = storeitem['inventory_id'];
          inventory.uuid = storeitem['uuid'];
          inventory.productId = storeitem['product_id'];
          inventory.branchId = storeitem['branch_id'];
          inventory.qty = storeitem['qty'] is int
              ? (storeitem['qty'] as int).toDouble()
              : storeitem['qty'];
          inventory.warningStockLevel = storeitem['warningStockLevel'];
          inventory.status = storeitem['status'];
          inventory.updatedAt = storeitem['updated_at'];
          inventory.updatedBy = storeitem['updated_by'];
          var storLodGata = storeitem["product_store_inventory_log"];
          var result1 = await localAPI.saveSyncInvStoreTable(inventory);
          if (storLodGata.length > 0) {
            for (var j = 0; j < storLodGata.length; j++) {
              var storLoditem = storLodGata[j];
              ProductStoreInventoryLog log = new ProductStoreInventoryLog();
              log.il_id = storLoditem["il_id"];
              log.uuid = storLoditem["uuid"];
              log.inventory_id = storLoditem["inventory_id"];
              log.branch_id = storLoditem["branch_id"];
              log.product_id = storLoditem["product_id"];
              log.employe_id = storLoditem["employe_id"];
              log.il_type = storLoditem["il_type"];
              log.qty = storLoditem["qty"] is int
                  ? (storLoditem['qty'] as int).toDouble()
                  : storLoditem['qty'];
              log.qty_before_change = storLoditem["qty_before_change"] is int
                  ? (storLoditem['qty_before_change'] as int).toDouble()
                  : storLoditem['qty_before_change'];
              log.qty_after_change = storLoditem["qty_after_change"] is int
                  ? (storLoditem['qty_after_change'] as int).toDouble()
                  : storLoditem['qty_after_change'];
              log.updated_at = storLoditem["updated_at"];
              log.updated_by = storLoditem["updated_by"];
              var result2 = await localAPI.saveSyncInvStoreLogTable(log);
            }
          }
        }
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveCancleORderTable(data) async {
    LocalAPI localAPI = LocalAPI();
    var orderdata = data["data"]["order_cancel"];
    if (orderdata.length > 0) {
      for (var i = 0; i < orderdata.length; i++) {
        var order = orderdata[i];
        CancelOrder cancle_order = new CancelOrder();
        cancle_order.id = order['id'];
        cancle_order.orderId = order['order_id'];
        cancle_order.localID = order['localID'];
        cancle_order.reason = order['reason'];
        cancle_order.status = order['status'];
        cancle_order.createdBy = order['created_by'];
        cancle_order.updatedBy = order['updated_by'];
        cancle_order.createdAt = order['created_at'];
        cancle_order.updatedAt = order['updated_at'];
        cancle_order.serverId = order['server_id'];
        cancle_order.terminalId = order['terminal_id'];
        var result2 = await localAPI.saveSyncCancelTable(cancle_order);
      }
    }
  }
}
