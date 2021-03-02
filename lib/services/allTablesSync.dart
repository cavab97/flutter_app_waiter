import 'dart:convert';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:flutter/cupertino.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/helpers/config.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/TerminalLog.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/services/CommunAPICall.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/services/LocalAPIs.dart';

class SyncAPICalls {
  static getOrderId(context) async {
    var apiurl = Configrations.getOrderId;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var stringParams = {'branch_id': branchid, 'terminal_id': terminalId};
    var orderId = await APICalls.getDataCall(apiurl, context, stringParams);
    var settingOrderId =
        await Preferences.getStringValuesSF(Constant.lastOrderId);
    int order_id = null;
    if (orderId is List || orderId == null) {
      return null;
    } else if (settingOrderId != null) {
      order_id = int.tryParse(settingOrderId) + 1;
      Preferences.setStringToSF(Constant.lastOrderId, order_id.toString());
    } else {
      if (orderId["order_id"] != null) {
        order_id = int.tryParse(orderId["order_id"].toString());
        order_id += 1;
        Preferences.setStringToSF(Constant.lastOrderId, order_id.toString());
      }
    }
    return order_id;
  }

  static getDataServerBulk1(context) async {
    var apiurl = Configrations.appdata1;
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);

    var permission =
        await Preferences.getStringValuesSF(Constant.USER_PERMISSION);
    var stringParams = {
      'datetime': serverTime != null && (permission != null && permission != '')
          ? serverTime
          : '',
      'branch_id': branchid,
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
      'branch_id': branchid,
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
      'branch_id': branchid,
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
      'branch_id': branchid,
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
      'branch_id': branchid,
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
      'branch_id': branchid,
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
      'branch_id': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getDataServerBulkAddressData(context) async {
    var apiurl = Configrations.country_state_city_datatable;
    var branchid = await CommunFun.getbranchId();
    var terminalId = await CommunFun.getTeminalKey();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branch_id': branchid,
      'terminal_id': terminalId
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getWineStorageData(context) async {
    var apiurl = Configrations.rac_box_liquor_inventor_datatable;
    var branchid = await CommunFun.getbranchId();
    var terminalId = await CommunFun.getTeminalKey();
    var serverTime =
        await Preferences.getStringValuesSF(Constant.SERVER_DATE_TIME);
    var stringParams = {
      'datetime': serverTime != null ? serverTime : '',
      'branch_id': branchid,
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
      'branch_id': branchid, // serverTime,
      'terminal_id': terminalId,
      'offset': offset != null ? int.parse(offset) : 0
    };
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static getConfig(context) async {
    var apiurl = Configrations.config;
    var stringParams = {};
    return await APICalls.apiCall(apiurl, context, stringParams);
  }

  static logActivity(String moduleName, String disc, String tablename, eId,
      [int updateBy]) async {
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
    //log.branch_id = int.parse(branchid);
    log.isSync = 0;
    log.module_name = moduleName;
    log.description = (updateBy != null
        ? disc + '\n granted access to ' + userdata.id.toString()
        : disc);
    log.activity_date = date;
    log.activity_time = time;
    log.table_name = tablename;
    log.entity_id = eId is int ? eId : int.parse(eId);
    log.status = 1;
    log.updated_at = datetime;
    log.updated_by = updateBy ?? userdata.id;
    await localAPI.terminalLog(log);
  }

  static syncOrderstoDatabase(context) async {
    try {
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      var apiurl = Configrations.order_sync;
      List<Orders> orders =
          await localAPI.getOrdersListTable(branchid, terminalId);
      if (orders != null && orders.length > 0) {
        List ordersList = [];
        for (var i = 0; i < orders.length; i++) {
          var order = orders[i];
          List<OrderDetail> ordersDetail =
              await localAPI.getOrderDetailTable(order.app_id, terminalId);
          List detailList = [];
          for (var j = 0; j < ordersDetail.length; j++) {
            var details = ordersDetail[j];
            List<OrderAttributes> ordersAttribute = await localAPI
                .getOrderAttributesTable(details.app_id, terminalId);
            List<OrderModifire> ordersModifire = await localAPI
                .getOrderModifireTable(details.app_id, terminalId);
            var productMap = {
              "detail_id": details.detailId,
              "uuid": details.uuid,
              "order_id": details.order_id,
              "order_app_id": details.order_app_id,
              "branch_id": details.branch_id,
              "terminal_id": details.terminal_id,
              "app_id": details.app_id,
              "server_id": details.server_id,
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
              await localAPI.getOrderPaymentTable(order.app_id, terminalId);

          List<VoucherHistory> voucherHistory =
              await localAPI.getVoucherHistoryTable(order.app_id, terminalId);
          var orderMap = {
            "order_id": order.order_id,
            "uuid": order.uuid,
            "branch_id": order.branch_id,
            "terminal_id": order.terminal_id,
            "app_id": order.app_id,
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
            "service_charge_percent": order.serviceChargePercent,
            "service_charge": order.serviceCharge,
            "sub_total_after_discount": order.sub_total_after_discount,
            "rounding_amount": order.rounding_amount,
            "pax": order.pax,
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
            'order_payment': ordersPayment,
            'voucher_history': voucherHistory
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
          //await CommunFun.showToast(context, "All orders upto dates.");
        }
      } else {
        //CommunFun.showToast(context, "All orders upto dates.");
        // Navigator.of(context).pop();
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
      if (orders != null && orders.length > 0) {
        for (var i = 0; i < orders.length; i++) {
          var orderdata = orders[i];
          Orders order = new Orders();
          order.order_id = orderdata["order_id"];
          order.uuid = orderdata["uuid"];
          order.branch_id = orderdata["branch_id"];
          order.terminal_id = orderdata["terminal_id"];
          order.app_id = orderdata["app_id"];
          order.table_id = orderdata["table_id"];
          order.pax = orderdata["pax"];
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
          order.rounding_amount = orderdata["rounding_amount"] is int
              ? (orderdata['rounding_amount'] as int).toDouble()
              : orderdata['rounding_amount'];
          order.server_id = orderdata["server_id"];
          order.order_source = orderdata["order_source"];
          order.order_status = orderdata["order_status"];
          order.order_item_count = orderdata["order_item_count"];
          order.order_date = orderdata["order_date"];
          order.order_by = orderdata["order_by"];
          order.updated_at = orderdata["updated_at"];
          order.updated_by = orderdata["updated_by"];
          order.isSync = 1;
          localAPI.saveSyncOrder(order);

          var orderdetail = orderdata["order_detail"];
          if (orderdetail.length > 0) {
            for (var i = 0; i < orderdetail.length; i++) {
              var detail = orderdetail[i];
              OrderDetail o_details = new OrderDetail();
              o_details.detailId = detail["detail_id"];
              o_details.uuid = detail["uuid"];
              o_details.order_app_id = detail["order_app_id"];
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
              o_details.isSync = 1;
              o_details.server_id = detail["server_id"];
              localAPI.saveSyncOrderDetails(o_details);

              var modifire = detail["order_modifier"];
              if (modifire.length > 0) {
                for (var m = 0; m < modifire.length; m++) {
                  var modifiredata = modifire[m];
                  OrderModifire m_data = new OrderModifire();
                  m_data.om_id = modifiredata["om_id"];
                  m_data.uuid = modifiredata["uuid"];
                  m_data.order_id = modifiredata["order_id"];
                  m_data.detail_id = modifiredata["detail_id"];
                  m_data.order_app_id = modifiredata["order_app_id"];
                  m_data.detail_app_id = modifiredata["detail_app_id"];
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
                  m_data.isSync = 1;
                  m_data.server_id = modifiredata["server_id"];
                  localAPI.saveSyncOrderModifire(m_data);
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
                  attr.order_app_id = attributeDt["order_app_id"];
                  attr.detail_app_id = attributeDt["detail_app_id"];
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
                  attr.isSync = 1;
                  attr.server_id = attributeDt["server_id"];
                  localAPI.saveSyncOrderAttribute(attr);
                }
              }
            }
          }
          var paymentdetail = orderdata["order_payment"];
          if (paymentdetail != null && paymentdetail.length > 0) {
            for (var p = 0; p < paymentdetail.length; p++) {
              var paydat = paymentdetail[p];
              OrderPayment paymentdat = new OrderPayment();
              paymentdat.op_id = paydat["op_id"];
              paymentdat.uuid = paydat["uuid"];
              paymentdat.order_id = paydat["order_id"];
              paymentdat.order_app_id = paydat["order_app_id"];
              paymentdat.branch_id = paydat["branch_id"];
              paymentdat.terminal_id = paydat["terminal_id"];
              paymentdat.app_id = paydat["app_id"];
              paymentdat.op_method_id = paydat["op_method_id"];
              paymentdat.op_amount = paydat["op_amount"] is int
                  ? (paydat['op_amount'] as int).toDouble()
                  : paydat['op_amount'];
              paymentdat.isCash = paydat["is_cash"];
              paymentdat.last_digits = paydat["last_digits"];
              paymentdat.approval_code = paydat["approval_code"];
              paymentdat.reference_number = paydat["reference_number"];
              paymentdat.remark = paydat["remark"];
              paymentdat.op_amount_change = paydat["op_amount_change"] is int
                  ? (paydat['op_amount_change'] as int).toDouble()
                  : paydat['op_amount_change'];
              paymentdat.op_method_response = paydat["op_method_response"];
              paymentdat.op_status = paydat["op_status"];
              paymentdat.op_datetime = paydat["op_datetime"];
              paymentdat.op_by = paydat["op_by"];
              paymentdat.updated_at = paydat["updated_at"];
              paymentdat.updated_by = paydat["updated_by"];
              paymentdat.isSync = 1;
              paymentdat.server_id = paydat["server_id"];
              localAPI.saveSyncOrderPaymet(paymentdat);
            }
          }

          var voucherHistory = orderdata["voucher_history"];
          if (voucherHistory != null && voucherHistory.length > 0) {
            for (var v = 0; v < voucherHistory.length; v++) {
              var voucherH = voucherHistory[v];
              VoucherHistory history = new VoucherHistory();
              history.voucher_history_id = voucherH["voucher_history_id"];
              history.uuid = voucherH["uuid"];
              history.app_order_id = voucherH["app_order_id"];
              history.voucher_id = voucherH["voucher_id"];
              history.order_id = voucherH["order_id"];
              history.user_id = voucherH["user_id"];
              history.amount = double.tryParse(voucherH["amount"].toString());
              history.created_at = voucherH["created_at"];
              history.app_id = voucherH["app_id"];
              history.terminal_id = voucherH["terminal_id"];
              history.server_id = voucherH['server_id'];
              localAPI.saveVoucherHistoryTable(history);
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
      List<CancelOrder> orderdata = await localAPI.getCancleOrder(terminalId);
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
        CommunFun.showToast(context, "Sync sucessfully done.");
      } else {
        //Navigator.of(context).pop();
        //CommunFun.showToast(context, "all cancel tables up to dates.");
      }
    } catch (e) {
      print(e);
      await CommunFun.showToast(context, e.message);
      Navigator.of(context).pop();
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
      } else {
        //  CommunFun.showToast(context, "all cancel tables up to dates.");
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
          inventory.serverid = storeitem["server_id"];
          inventory.warningStockLevel = storeitem['warningStockLevel'];
          inventory.status = storeitem['status'];
          inventory.updatedAt = storeitem['updated_at'];
          inventory.updatedBy = storeitem['updated_by'];
          var storLodGata = storeitem["product_store_inventory_log"];
          await localAPI.saveSyncInvStoreTable(inventory);
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
              log.serverid = storLoditem["server_id"];
              log.qty_before_change = storLoditem["qty_before_change"] is int
                  ? (storLoditem['qty_before_change'] as int).toDouble()
                  : storLoditem['qty_before_change'];
              log.qty_after_change = storLoditem["qty_after_change"] is int
                  ? (storLoditem['qty_after_change'] as int).toDouble()
                  : storLoditem['qty_after_change'];
              log.updated_at = storLoditem["updated_at"];
              log.updated_by = storLoditem["updated_by"];
              await localAPI.saveSyncInvStoreLogTable(log);
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
        cancle_order.order_app_id = order["order_app_id"];
        cancle_order.localID = order['localID'];
        cancle_order.reason = order['reason'];
        cancle_order.status = order['status'];
        cancle_order.createdBy = order['created_by'];
        cancle_order.updatedBy = order['updated_by'];
        cancle_order.createdAt = order['created_at'];
        cancle_order.updatedAt = order['updated_at'];
        cancle_order.serverId = order['server_id'];
        cancle_order.terminalId = order['terminal_id'];
        cancle_order.isSync = 1;
        await localAPI.saveSyncCancelTable(cancle_order);
      }
    }
  }

  static sendCustomerTable(context) async {
    try {
      var apiurl = Configrations.create_customer_data;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<Customer> custstoreData =
          await localAPI.getCustomersforSend(terminalId);
      if (custstoreData.length > 0) {
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'customer': json.encode(custstoreData)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);
        if (res["status"] == Constant.STATUS200) {
          saveCustomerToTable(context, res);
        }
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveCustomerToTable(context, data) {
    LocalAPI localAPI = LocalAPI();
    var customers = data["data"]["customer"];
    if (customers.length > 0) {
      for (var i = 0; i < customers.length; i++) {
        Customer customer = new Customer();
        customer = Customer.fromJson(customers[i]);
        localAPI.saveCustomersFromServer(customer);
      }
    }
  }

  static sendCustomerWineInventory(context) async {
    try {
      var apiurl = Configrations.update_customer_liquor_inventory_data;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<Customer_Liquor_Inventory> custstoreData =
          await localAPI.getCustomersWineInventory(branchid);
      var custData = [];
      if (custstoreData.length > 0) {
        for (var i = 0; i < custstoreData.length; i++) {
          Customer_Liquor_Inventory custInv = custstoreData[i];
          List<Customer_Liquor_Inventory_Log> custLogData = await localAPI
              .getCustomersWineInventoryLogs(branchid, custInv.appId);
          var data = {
            "cl_id": custInv.clId,
            "uuid": custInv.uuid,
            "app_id": custInv.appId,
            "server_id": custInv.serverId,
            "cl_customer_id": custInv.clCustomerId,
            "cl_product_id": custInv.clProductId,
            "cl_branch_id": custInv.clBranchId,
            "cl_rac_id": custInv.clRacId,
            "cl_box_id": custInv.clBoxId,
            "type": custInv.type,
            "cl_total_quantity": custInv.clTotalQuantity,
            "cl_expired_on": custInv.clExpiredOn,
            "cl_left_quantity": custInv.clLeftQuantity,
            "status": custInv.status,
            "updated_at": custInv.updatedAt,
            "updated_by": custInv.updatedBy,
            "customer_liquor_inventory_log": json.encode(custLogData)
          };
          custData.add(data);
        }
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'customer_inventory': json.encode(custData)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);
        if (res["status"] == Constant.STATUS200) {
          saveCustomerWineInventory(context, res);
        }
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveCustomerWineInventory(context, data) async {
    LocalAPI localAPI = LocalAPI();
    var customerWineInv = data["data"]["customer_inventory"];
    if (customerWineInv.length > 0) {
      for (var i = 0; i < customerWineInv.length; i++) {
        var custInv = customerWineInv[i];
        Customer_Liquor_Inventory customerWineInt =
            new Customer_Liquor_Inventory();
        var data = {
          customerWineInt.clId: custInv["cl_id"],
          customerWineInt.uuid: custInv["uuid"],
          customerWineInt.appId: custInv["app_id"],
          customerWineInt.serverId: custInv["server_id"],
          customerWineInt.clCustomerId: custInv["cl_customer_id"],
          customerWineInt.clProductId: custInv["cl_product_id"],
          customerWineInt.clBranchId: custInv["cl_branch_id"],
          customerWineInt.clRacId: custInv["cl_rac_id"],
          customerWineInt.clBoxId: custInv["cl_box_id"],
          customerWineInt.type: custInv["type"],
          customerWineInt.clTotalQuantity: custInv["cl_total_quantity"],
          customerWineInt.clExpiredOn: custInv["cl_expired_on"],
          customerWineInt.clLeftQuantity: custInv["cl_left_quantity"],
          customerWineInt.status: custInv["status"],
          customerWineInt.updatedAt: custInv["updated_at"],
          customerWineInt.updatedBy: custInv["updated_by"],
        };
        await localAPI.saveSuctomerWineInventory(customerWineInt);

        var storLodGata = custInv["product_store_inventory_log"];
        for (var j = 0; j < storLodGata.length; j++) {
          var logint = storLodGata[j];
          Customer_Liquor_Inventory_Log invLog =
              new Customer_Liquor_Inventory_Log();
          var logdata = {
            invLog.liId: logint['li_id'],
            invLog.appId: logint["app_id"],
            invLog.clAppId: logint["cl_appId"],
            invLog.serverId: logint["server_id"],
            invLog.uuid: logint['uuid'],
            invLog.clId: logint['cl_id'],
            invLog.branchId: logint['branch_id'],
            invLog.productId: logint['product_id'],
            invLog.customerId: logint['customer_id'],
            invLog.liType: logint['li_type'],
            invLog.qty: logint['qty'],
            invLog.qtyBeforeChange: logint['qty_before_change'],
            invLog.qtyAfterChange: logint['qty_after_change'],
            invLog.updatedAt: logint['updated_at'],
            invLog.updatedBy: logint['updated_by'],
          };
          await localAPI.saveSuctomerWineInventoryLogs(invLog);
        }
      }
    }
  }

  static sendShiftTable(context) async {
    try {
      var apiurl = Configrations.createShiftdata;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<Shift> storeData =
          await localAPI.getShiftDatabaseTable(branchid, terminalId);
      if (storeData.length > 0) {
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'shift': json.encode(storeData)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);
        if (res.length > 0 && res["status"] == Constant.STATUS200) {
          saveShiftToTable(context, res);
        } else {
          print('sendShiftTable api error');
        }
      } else {
        //  CommunFun.showToast(context, "all cancel tables up to dates.");
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static sendShiftdetails(context) async {
    try {
      var apiurl = Configrations.createShiftdetaildata;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<ShiftInvoice> invoiceData =
          await localAPI.getShiftInvoiceTable(terminalId);
      if (invoiceData.length > 0) {
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'shift_detail': json.encode(invoiceData)
        };
        var res = await APICalls.apiCall(apiurl, context, stringParams);
        if (res.length > 0 && res["status"] == Constant.STATUS200) {
          saveShiftDetailToTable(context, res);
        } else {
          print('sendShiftdetails api error');
        }
      } else {
        print('invoice data is empty');
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveShiftToTable(context, data) async {
    LocalAPI localAPI = LocalAPI();
    var shiftsData = data["data"]["shift"];
    if (shiftsData.length > 0) {
      for (var i = 0; i < shiftsData.length; i++) {
        var shiftitem = shiftsData[i];
        Shift shift = new Shift();
        shift.shiftId = shiftitem['shift_id'];
        shift.uuid = shiftitem['uuid'];
        shift.terminalId = shiftitem['terminal_id'];
        shift.appId = shiftitem['app_id'];
        shift.userId = shiftitem['user_id'];
        shift.branchId = shiftitem['branch_id'];
        shift.startAmount = shiftitem['start_amount'] is int
            ? (shiftitem['start_amount'] as int).toDouble()
            : shiftitem['start_amount'];
        shift.endAmount = shiftitem['end_amount'] is int
            ? (shiftitem['end_amount'] as int).toDouble()
            : shiftitem['end_amount'];
        shift.status = shiftitem['status'];
        shift.updatedAt = shiftitem['updated_at'];
        shift.updatedBy = shiftitem['updated_by'];
        shift.createdAt = shiftitem['created_at'];
        shift.serverId = shiftitem['server_id'];
        await localAPI.saveShiftDatafromSync(shift);
      }
    }
  }

  static saveShiftDetailToTable(context, data) async {
    var invoiceData = data["data"]["shift_detail"];
    if (invoiceData.length > 0) {
      for (var j = 0; j < invoiceData.length; j++) {
        var logint = invoiceData[j];
        ShiftInvoice shiftInvoice = new ShiftInvoice();
        shiftInvoice.id = logint["id"];
        shiftInvoice.shift_id = logint["shift_id"];
        shiftInvoice.shift_app_id = logint["shift_app_id"];
        shiftInvoice.app_id = logint["app_id"];
        shiftInvoice.invoice_id = logint["invoice_id"];
        shiftInvoice.status = logint["status"];
        shiftInvoice.created_by = logint["created_by"];
        shiftInvoice.updated_by = logint["updated_by"];
        shiftInvoice.created_at = logint["created_at"];
        shiftInvoice.updated_at = logint["updated_at"];
        shiftInvoice.serverId = logint["server_id"];
        shiftInvoice.terminal_id = logint["terminal_id"];
        await localAPI.saveShiftInvoiceDatafromSync(shiftInvoice);
      }
    }
  }

  static sendTerminalLogTable(context) async {
    try {
      var apiurl = Configrations.create_terminal_log_data;
      var terminalId = await CommunFun.getTeminalKey();
      var branchid = await CommunFun.getbranchId();
      LocalAPI localAPI = LocalAPI();
      List<TerminalLog> storeData =
          await localAPI.getTerminalLogTables(branchid, terminalId);
      if (storeData.length > 0) {
        var stringParams = {
          'branch_id': branchid,
          'terminal_id': terminalId,
          'terminal_log': json.encode(storeData)
        };
        localAPI.deleteTerminalLogAfterSync(storeData);
        var res = await APICalls.apiCall(apiurl, context, stringParams);
        if (res.length > 0 && res["status"] == Constant.STATUS200) {
          //receive terminal log to app for why?
          //await localAPI.saveTerminalLogFromSync(storeData);
        } else {
          print('sendTerminalLogTable api error');
        }
      } else {
        //  CommunFun.showToast(context, "all cancel tables up to dates.");
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
  }

  static saveTerminalLogTable(context, terminalData) async {
    if (terminalData.length > 0) {
      for (var j = 0; j < terminalData.length; j++) {
        TerminalLog logint = terminalData[j];
        TerminalLog terminalLog = new TerminalLog();
        terminalLog.id = logint.id;
        terminalLog.uuid = logint.uuid;
        terminalLog.terminal_id = logint.terminal_id;
        terminalLog.isSync = 1;
        terminalLog.branch_id = logint.branch_id;
        terminalLog.module_name = logint.module_name;
        terminalLog.description = logint.description;
        terminalLog.activity_date = logint.activity_date;
        terminalLog.activity_time = logint.activity_time;
        terminalLog.table_name = logint.table_name;
        terminalLog.entity_id = logint.entity_id;
        terminalLog.status = logint.status;
        terminalLog.updated_at = logint.updated_at;
        terminalLog.updated_by = logint.updated_by;
        await localAPI.saveTerminalLogFromSync(terminalLog);
      }
    }
  }

  static getCompareTableQuery(context, String packageVersion) async {
    List<Map<String, String>> listMapObject = [];
    try {
      String apiurl = Configrations.getTableUpdate;
      String terminalId = await CommunFun.getTeminalKey();
      String branchid = await CommunFun.getbranchId();
      var stringParams = {
        'branch_id': branchid,
        'terminal_id': terminalId,
        'version': packageVersion
      };
      var res = await APICalls.getDataCall(apiurl, context, stringParams, 10);
      if (res == null) {
        return [];
      } else if (res.length > 0 && res["status"] == Constant.STATUS200) {
        for (var data in res["data"]) {
          Map<String, String> myMap = new Map<String, String>.from(data);
          listMapObject.add(myMap);
        }
      } else {
        print('get Comparing Table api error');
      }
    } catch (e) {
      print(e);
      CommunFun.showToast(context, e.message);
    }
    return listMapObject;
  }

  static getTableData(context, String tableName) async {
    try {
      String apiurl = Configrations.getTableData;
      var result = await CommunFun.getTeminalKey();
      int terminalId = int.tryParse(result);
      result = await CommunFun.getbranchId();
      int branchid = int.tryParse(result);
      User userdata = await CommunFun.getuserDetails();
      Map<String, Object> stringParams = {
        'branch_id': branchid,
        'terminal_id': terminalId,
        'pin': userdata.userPin,
        'user_uuid': userdata.uuid,
        'table': tableName,
        'is_init': (tableName.toLowerCase() == "users" && userdata.uuid == null)
      };
      var res = await APICalls.getDataCall(apiurl, context, stringParams, 15);
      List<Map<String, dynamic>> listMapObject = [];
      if (res == null || res.length == 0) {
        return listMapObject;
      } else if (res.length > 0 &&
          res["status"] is int &&
          res["status"] == Constant.STATUS200) {
        List<Map<String, dynamic>> listMapObject = [];
        for (var data in res["data"]) {
          Map<String, dynamic> myMap = new Map<String, dynamic>.from(data);
          listMapObject.add(myMap);
        }
        return listMapObject;
      } else if (res["status"] is int && res["status"] != 200) {
        CommunFun.showToast(context, res["message"]);
      } else {
        print('get Comparing Table api error');
      }
    } catch (e) {
      if (e["message"] && !e.message is String) {
      } else if (e["message"]) CommunFun.showToast(context, e.message);
      print(e.toString());
    }
  }
}
