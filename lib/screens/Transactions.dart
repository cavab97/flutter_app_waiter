import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/cancelOrder.dart';
import 'package:mcncashier/screens/PaymentMethodPop.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';

class TransactionsPage extends StatefulWidget {
  // Transactions list
  TransactionsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  LocalAPI localAPI = LocalAPI();
  ScrollController _scrollController = ScrollController();
  List<Orders> orderLists = [];
  List<Orders> filterList = [];
  Orders selectedOrder = new Orders();
  List taxJson = [];
  List<Printer> printerreceiptList = new List<Printer>();
  List<Printer> printerList = new List<Printer>();
  List<OrderPayment> orderpayment = [];
  User paymemtUser = new User();
  Branch branchData;
  List<ProductDetails> detailsList = [];
  List<OrderDetail> orderItemList = [];
  bool isFiltering = false;
  bool isRefunding = false;
  bool isWeborder = true;
  var permissions = "";
  var orderDate = "";
  double change = 0.00;
  int currentOffset = 0;
  bool isScreenLoad = false;
  Customer customer;
  List<Payments> paymentMethod = new List<Payments>();
  var currency = "RM";

  @override
  void initState() {
    super.initState();
    getTansactionList();
    setPermissons();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    getAllPrinter();
    getbranch();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        if (!isScreenLoad) {
          isScreenLoad = !isScreenLoad;
          // Perform event when user reach at the end of list (e.g. do Api call)
          getTansactionList();
        }
      }
    });
  }

  @override
  void dispose() {
    if (_scrollController != null) _scrollController.dispose();
    super.dispose();
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await localAPI.getbranchData();
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
      branchData = branch;
    });
    return branch;
  }

  getAllPrinter() async {
    List<Printer> printer = await localAPI.getAllPrinterForKOT();
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    setState(() {
      printerList = printer;
      printerreceiptList = printerDraft;
    });
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
    await SyncAPICalls.logActivity("transactions",
        "cashier opened transactions list page", "transactions", 1);
  }

  getTansactionList() async {
    if (this.mounted) {
      setState(() {
        isScreenLoad = true;
      });
    }
    var terminalid = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    List<Orders> orderList =
        await localAPI.getOrdersList(branchid, terminalid, currentOffset);
    // convert each item to a string by using JSON encoding
    final jsonList = orderList.map((item) => jsonEncode(item)).toList();

    // using toSet - toList strategy
    final uniqueJsonList = jsonList.toSet().toList();

    // convert each item back to the original form using JSON decoding
    orderList = uniqueJsonList
        .map((item) => Orders.fromJson(jsonDecode(item)))
        .toList();
    if (orderList.length > 0 && this.mounted) {
      setState(() {
        orderLists.addAll(orderList);
        currentOffset += 10;
      });
      getOrderDetails(orderLists[0]);
    }
    if (this.mounted) {
      setState(() {
        isScreenLoad = false;
      });
    }
  }

  getOrderDetails(Orders order) async {
    var date = await CommunFun.getCurrentDateTime(DateTime.parse(
        order.order_date != null
            ? order.order_date
            : DateTime.now().toString()));
    var orderDateF =
        DateFormat('EEE, MMM d yyyy, hh:mm aaa').format(DateTime.parse(date));
    if (this.mounted) {
      setState(() {
        isScreenLoad = true;
        selectedOrder = order;
        orderDate = orderDateF;
        isWeborder = order.order_source == 1 ? true : false;
        taxJson = json.decode(selectedOrder.tax_json);
      });
    }

    List<OrderDetail> orderItem =
        await localAPI.getOrderDetailsList(order.app_id, order.terminal_id);
    // List<ProductDetails> details =
    //     await localAPI.getOrderDetails(order.app_id, order.terminal_id);
    if (orderItem.length > 0 && this.mounted) {
      setState(() {
        orderItemList = orderItem;
      });
    }

    //  if (order.order_source == 2) {
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(order.app_id, order.terminal_id);
    if (orderpaymentdata.length > 0 && this.mounted) {
      double totalPay = 0.00;
      List<Payments> payMethod =
          await localAPI.getOrderpaymentmethod(order.app_id, order.terminal_id);
      for (OrderPayment paymentData in orderpaymentdata) {
        totalPay += paymentData.op_amount;
      }
      setState(() {
        orderpayment = orderpaymentdata;
        paymentMethod = payMethod;
        change = totalPay - selectedOrder.grand_total;
      });
      User user = await localAPI.getPaymentUser(orderpayment[0].op_by);
      if (user != null) {
        setState(() {
          paymemtUser = user;
        });
      }
    }
    if (this.mounted) {
      setState(() {
        isScreenLoad = false;
        SyncAPICalls.logActivity(
            "transactions", "clicked transaction details", "transactions", 1);
      });
    }

    //}
  }

  startFilter() async {
    setState(() {
      filterList = orderLists;
      isFiltering = true;
    });
    await SyncAPICalls.logActivity(
        "filter", "Filtering transactions", "transactions", 1);
  }

  filterOrders(val) {
    var list = orderLists
        .where((x) =>
            x.invoice_no.toString().toLowerCase().contains(val.toLowerCase()))
        .toList();
    setState(() {
      filterList = list;
    });
  }

  showReasontypePop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChooseReasonType(
            onClose: (reason) {
              Navigator.of(context).pop();
              if (reason == "Other") {
                otherReasonPop();
              } else {
                cancleTransation(reason);
              }
            },
          );
        });
  }

  otherReasonPop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AddOtherReason(
            onClose: (otherText) {
              Navigator.of(context).pop();
              cancleTransation(otherText);
            },
          );
        });
  }

  paymentMethodPop(reason) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: selectedOrder.sub_total,
            grandTotal: selectedOrder.grand_total,
            currentMode: "refund",
            onClose: (mehtod) {
              cancleTransactionWithMethod(mehtod, reason);
            },
          );
        });
  }

  cancleTransactionWithMethod(paymehtod, reason) {
    cancleTransation(reason);
    Navigator.of(context).pop();
  }

  cancleTransation(reason) async {
    //:Cancle Transation Pop // 1 for  cancle

    Orders orderData = Orders();
    User userdata = await CommunFun.getuserDetails();
    orderData = selectedOrder;
    orderData.order_status = 3;
    orderData.isSync = 0;
    orderData.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
    orderData.updated_by = userdata.id;
    await localAPI.updateOrderStatus(orderData);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    await SyncAPICalls.logActivity(
        "Cancel Transaction",
        "Cashier (" +
            userdata.name +
            ') cancel order : ' +
            orderData.invoice_no +
            ' on ' +
            orderData.updated_at,
        "Order",
        1);
    CancelOrder order = new CancelOrder();
    order.orderId = selectedOrder.order_id;
    order.order_app_id = selectedOrder.app_id;
    order.localID = await CommunFun.getLocalID();
    order.reason = reason;
    order.status = 3;
    order.isSync = 0;
    order.serverId = 0;
    order.createdBy = userdata.id;
    order.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    order.terminalId = int.parse(terminalId);
    await localAPI.insertCancelOrder(order);
    // if (paymehtod.length > 0) {
    //   for (var i = 0; i < paymehtod.length; i++) {
    //     OrderPayment orderpayment = paymehtod[i];
    //     if (orderpayment.isCash == 1) {
    //       var shiftid =
    //           await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    //       Drawerdata drawer = new Drawerdata();
    //       drawer.shiftId = int.parse(shiftid);
    //       drawer.amount = orderpayment.op_amount.toDouble();
    //       drawer.isAmountIn = 2;
    //       drawer.reason = "cancelORder";
    //       drawer.status = 1;
    //       drawer.createdBy = userdata.id;
    //       drawer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    //       drawer.localID = uuid;
    //       drawer.terminalid = int.parse(terminalId);
    //       var result = await localAPI.saveInOutDrawerData(drawer);
    //     }
    //   }
    // }
    List<OrderDetail> orderItem = orderItemList;
    if (orderItem.length > 0) {
      for (var i = 0; i < orderItem.length; i++) {
        OrderDetail productDetail = orderItem[i];
        var productData = productDetail.product_detail;
        var jsonProduct = json.decode(productData);
        List<ProductStoreInventory> updatedInt = [];
        List<ProductStoreInventoryLog> updatedIntLog = [];
        if (jsonProduct["has_inventory"] == 1) {
          List<ProductStoreInventory> inventory =
              await localAPI.getStoreInventoryData(productDetail.product_id);
          if (inventory.length > 0) {
            ProductStoreInventory invData;
            invData = inventory[0];
            invData.qty = invData.qty + productDetail.detail_qty;
            invData.updatedAt =
                await CommunFun.getCurrentDateTime(DateTime.now());
            invData.updatedBy = userdata.id;
            updatedInt.add(invData);
            await localAPI.updateInvetory(updatedInt);
            ProductStoreInventoryLog log = new ProductStoreInventoryLog();
            if (inventory.length > 0) {
              log.uuid = uuid;
              log.inventory_id = inventory[0].inventoryId;
              log.branch_id = int.parse(branchid);
              log.product_id = productDetail.product_id;
              log.employe_id = userdata.id;
              log.il_type = 1;
              log.qty = invData.qty;
              log.qty_before_change = invData.qty;
              log.qty_after_change = invData.qty + productDetail.detail_qty;
              log.updated_at =
                  await CommunFun.getCurrentDateTime(DateTime.now());
              log.updated_by = userdata.id;
              updatedIntLog.add(log);
              await localAPI.updateStoreInvetoryLogTable(updatedIntLog);
            }
          }
        }
      }
    }
    //Navigator.of(context).pop();
    getTansactionList();
  }

  refundSelectedammout() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: selectedOrder.sub_total,
            grandTotal: selectedOrder.grand_total,
            currentMode: "refund",
            onClose: (mehtod) {
              Navigator.of(context).pop();
              returnPayment(mehtod);
            },
          );
        });
  }

  requestRefund() async {
    var alertRefund = CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      refundSelectedammout();
      SyncAPICalls.logActivity(
          "payment", "Cashier request reund", "payment", 1);
    }, "Warning", "Do you want to request refund for this transaction?", "Yes",
        "No", true);
    if (permissions.contains(Constant.PAYMENT)) {
      await alertRefund;
    } else {
      await CommonUtils.openPermissionPop(context, Constant.PAYMENT, () async {
        await alertRefund;
        SyncAPICalls.logActivity("payment",
            "Manager given permission for payment while refund", "payment", 1);
      }, () {});
    }
    /* setState(() {
      isRefunding = true;
    });
    SyncAPICalls.logActivity(
        "transactions", "clicked redund button", "transactions", 1); */
  }

  returnPayment(paymentMehtod) async {
    var currentDateTime = await CommunFun.getCurrentDateTime(DateTime.now());
    Orders orderData = Orders();
    User userdata = await CommunFun.getuserDetails();
    orderData = selectedOrder;
    orderData.order_status = 5;
    orderData.isSync = 0;
    orderData.updated_at = currentDateTime;
    orderData.updated_by = userdata.id;

    localAPI.updateOrderStatus(orderData);
    //var upDate = await CommunFun.getCurrentDateTime(DateTime.now());
    //double totalPay = 0;
    var terminalId = await CommunFun.getTeminalKey();
    var uuid = await CommunFun.getLocalID();
    var branchid = await CommunFun.getbranchId();
    if (paymentMehtod.length > 0) {
      for (var i = 0; i < paymentMehtod.length; i++) {
        OrderPayment orderpayment = paymentMehtod[i];
        if (orderpayment.isCash == 1) {
          var shiftid =
              await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
          Drawerdata drawer = new Drawerdata();
          drawer.shiftId = int.parse(shiftid);
          drawer.amount = orderpayment.op_amount.toDouble();
          drawer.isAmountIn = 2;
          drawer.reason = "refundOrder";
          drawer.status = 1;
          drawer.createdBy = userdata.id;
          drawer.createdAt = currentDateTime;
          drawer.localID = uuid;
          drawer.terminalid = int.parse(terminalId);
          localAPI.saveInOutDrawerData(drawer);
        }
        orderpayment.op_status = 5;

        List<OrderPayment> lapPpid =
            await localAPI.getLastOrderPaymentAppid(terminalId);
        if (lapPpid.length > 0) {
          orderpayment.app_id = lapPpid[0].app_id + 1;
        } else {
          orderpayment.app_id = 1;
        }
        //await localAPI.getOPIdFromOrderPayment();
        //orderpayment.op_id = await localAPI.getOPIdFromOrderPayment();
        orderpayment.uuid = uuid;
        orderpayment.order_app_id = orderData.order_id ?? orderData.app_id;
        orderpayment.branch_id = int.parse(branchid);
        orderpayment.terminal_id = int.parse(terminalId);
        orderpayment.updated_by = userdata.id;
        orderpayment.updated_at = currentDateTime;
        orderpayment.isSync = 0;
        orderpayment.op_datetime = currentDateTime;
        orderpayment.op_by = userdata.id;
        orderpayment.reference_number = null;
        orderpayment.remark = null;
        orderpayment.last_digits = null;
        orderpayment.approval_code = null;
        orderpayment.server_id = 0;
        orderpayment.isCash = 1;
        localAPI.sendtoOrderPayment(orderpayment);
        //totalPay += orderpayment.op_amount;
      }
      /* await localAPI.updatePaymentStatus(selectedOrder.app_id,
            selectedOrder.terminal_id, 5, upDate, userdata.id); */

    }
    List<OrderDetail> orderItem = orderItemList;
    if (orderItem.length > 0) {
      for (var i = 0; i < orderItem.length; i++) {
        OrderDetail productDetail = orderItem[i];
        var productData = productDetail.product_detail;
        var jsonProduct = json.decode(productData);
        List<ProductStoreInventory> updatedInt = [];
        List<ProductStoreInventoryLog> updatedIntLog = [];
        if (jsonProduct["has_inventory"] == 1) {
          List<ProductStoreInventory> inventory =
              await localAPI.getStoreInventoryData(productDetail.product_id);
          if (inventory.length > 0) {
            ProductStoreInventory invData;
            invData = inventory[0];
            invData.qty = invData.qty + productDetail.detail_qty;
            invData.updatedAt = currentDateTime;
            invData.updatedBy = userdata.id;
            updatedInt.add(invData);
            localAPI.updateInvetory(updatedInt);
            ProductStoreInventoryLog log = new ProductStoreInventoryLog();
            if (inventory.length > 0) {
              log.uuid = uuid;
              log.inventory_id = inventory[0].inventoryId;
              log.branch_id = int.parse(branchid);
              log.product_id = productDetail.product_id;
              log.employe_id = userdata.id;
              log.il_type = 1;
              log.qty = invData.qty;
              log.qty_before_change = invData.qty;
              log.qty_after_change = invData.qty + productDetail.detail_qty;
              log.updated_at = currentDateTime;
              log.updated_by = userdata.id;
              updatedIntLog.add(log);
              localAPI.updateStoreInvetoryLogTable(updatedIntLog);
            }
          }
        }
      }
    }
    setState(() {
      isRefunding = false;
    });
    Navigator.of(context).pop();
    //getTansactionList();
  }

  deleteItemFormList(product) async {
    Orders order = selectedOrder;
    if (order.order_item_count > 1) {
      OrderDetail details = product;
      var subtotal = order.sub_total - details.product_price;
      var qty = order.order_item_count - details.detail_qty;
      var grandtotal = subtotal;
      order.sub_total = subtotal;
      order.order_item_count = qty.toInt();
      order.grand_total = grandtotal;
      await localAPI.deleteOrderItem(product.app_id);
      await localAPI.updateInvoice(order);
      setState(() {
        isRefunding = false;
      });
      getTansactionList();
      // Updated ORder table data
      // CommunFun.showToast(
      //     context, "Refund table insert data.. work in progress");
    } else {
      setState(() {
        isRefunding = false;
      });
    }
  }

  reprintRecipt() async {
    if (selectedOrder != null) {
      List<OrderPayment> orderpaymentdata = await localAPI.getOrderpaymentData(
          selectedOrder.app_id, selectedOrder.terminal_id);
      List<Payments> paymentMethod = await localAPI.getOrderpaymentmethod(
          selectedOrder.app_id, selectedOrder.terminal_id);
      List<OrderDetail> orderitem = await localAPI.getOrderDetailsList(
          selectedOrder.app_id, selectedOrder.terminal_id);
      Orders order = await localAPI.getcurrentOrders(
          selectedOrder.app_id, selectedOrder.terminal_id);
      List<OrderAttributes> attributes =
          await localAPI.getOrderAttributes(order.app_id);
      List<OrderModifire> modifires =
          await localAPI.getOrderModifire(order.app_id);
      var branchid = await CommunFun.getbranchId();
      List<TablesDetails> tabledata =
          await localAPI.getTableData(order.table_id);
      PrintReceipt printKOT = PrintReceipt();
      printKOT.checkReceiptPrint(
          (order.pax != null ? order.pax.toString() : 0.toString()),
          printerreceiptList[0].printerIp,
          context,
          branchData,
          taxJson,
          orderitem,
          attributes,
          modifires,
          order,
          orderpaymentdata,
          paymentMethod,
          tabledata[0].tableName,
          currency,
          Strings.walkinCustomer,
          true,
          true);
      await SyncAPICalls.logActivity(
          "transactions",
          "clicked reprint button for reprint duplicate bill print",
          "transactions",
          1);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: LoadingOverlay(
          child: SafeArea(
            child: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                setState(() {
                  isFiltering = false;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Table(
                  columnWidths: {
                    0: FractionColumnWidth(.3),
                    1: FractionColumnWidth(.6),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                        // Part 1 white
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: StaticColor.colorWhite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CommunFun.verticalSpace(10),
                                pageTitle(),
                                CommunFun.verticalSpace(10),
                                transationsSearchBox(),
                                CommunFun.verticalSpace(5),
                                orderLists.length > 0
                                    ? searchTransationList()
                                    : Center(
                                        child: Text(Strings.noOrderFound,
                                            style: Styles.darkBlue()))
                              ],
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                          // Part 2 transactions list
                          child: Center(
                              child: orderLists.length > 0
                                  ? SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 50),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    CommunFun.verticalSpace(10),
                                                    reprintRecipet(),
                                                    CommunFun.verticalSpace(10),
                                                    orderDateText(),
                                                    CommunFun.verticalSpace(10),
                                                    grandTotalText(),
                                                    CommunFun.verticalSpace(10),
                                                    userNameText(),
                                                    CommunFun.verticalSpace(10),
                                                    customerBanner(),
                                                    productList(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.2,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 50),
                                              child: SingleChildScrollView(
                                                child:
                                                    Column(children: <Widget>[
                                                  Divider(),
                                                  totalAmountValues(),
                                                  Divider(),
                                                  paymentDetails(),
                                                  changeText(),
                                                  /* isRefunding ? refundButtons(context) : */
                                                  transationsButton()
                                                ]),
                                              ),
                                            )
                                            // ),
                                          ]))
                                  : noOrderFoundText()))
                    ]),
                  ],
                ),
              ),
            ),
          ),
          isLoading: isScreenLoad,
          color: Colors.black87,
          progressIndicator: CommunFun.overLayLoader()),
    );
  }

  Widget noOrderFoundText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CommunFun.verticalSpace(50),
        Text(
          Strings.noOrderFound,
          style: Styles.whiteBold(),
        ),
      ],
    );
  }

  Widget pageTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: SizeConfig.safeBlockVertical * 7,
          ),
        ),
        CommunFun.horisontalSpace(10),
        Text(Strings.transaction, style: Styles.drawerText()),
      ],
    );
  }

  Widget changeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0,
            ),
            child: Text(
              "Change",
              textAlign: TextAlign.end,
              style: Styles.darkGray(),
            ),
          ),
        ),
        new Expanded(
          flex: 3,
          child: Padding(
              padding: EdgeInsets.only(
                top: 0,
              ),
              child: Text(
                change > 0 ? change.toStringAsFixed(2) : "0.00",
                textAlign: TextAlign.end,
                style: Styles.darkGray(),
              )),
        )
      ],
    );
  }

  Widget paymentDetails() {
    return Column(
        children: orderpayment.map((payment) {
      var index = orderpayment.indexOf(payment);
      /* change =
          payment.op_amount_change != null ? payment.op_amount_change : 0.0; */
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.only(
                top: 0,
              ),
              child: Text(
                paymentMethod.length > index
                    ? paymentMethod[index].name.toUpperCase()
                    : "",
                textAlign: TextAlign.end,
                style: Styles.darkGray(),
              ),
            ),
          ),
          new Expanded(
            flex: 3,
            child: Padding(
                padding: EdgeInsets.only(
                  top: 0,
                ),
                child: Text(
                  payment.op_amount != null
                      ? payment.op_amount.toStringAsFixed(2)
                      : "00:00",
                  textAlign: TextAlign.end,
                  style: Styles.darkGray(),
                )),
          )
        ],
      );
    }).toList());
  }

  Widget customerBanner() {
    return Container(
      height: SizeConfig.safeBlockVertical * 8,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text(
          customer != null ? customer.firstName : "Walk-In Customer",
          style: Styles.orangeSmall(),
        ),
      ),
      color: Colors.grey[900].withOpacity(0.4),
    );
  }

  Widget assingTableButton(onPress) {
    return RaisedButton(
      padding: EdgeInsets.all(10),
      onPressed: onPress,
      child: Text("Assign Table", style: Styles.whiteSimpleSmall()),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget transationsSearchBox() {
    return Container(
      padding: EdgeInsets.all(10),
      color: StaticColor.colorGrey400,
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.search,
              color: StaticColor.colorGrey400,
              size: SizeConfig.safeBlockVertical * 5,
            ),
          ),
          hintText: Strings.searchboxHint,
          hintStyle: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3,
              fontWeight: FontWeight.bold,
              color: StaticColor.colorGrey400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          contentPadding: EdgeInsets.only(left: 20),
          fillColor: StaticColor.colorWhite,
        ),
        style: Styles.blackMediumBold(),
        onSubmitted: (e) {
          if (e.length == 0) {
            isFiltering = false;
          }
        },
        onTap: () {
          startFilter();
        },
        onChanged: (e) {
          if (e.length != 0) {
            filterOrders(e);
          }
        },
      ),
    );
  }

  Widget refundButtons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        refundCancelButton(() {
          setState(() {
            isRefunding = false;
          });
        }),
        CommunFun.horisontalSpace(10),
        refundNextButton(() async {
          if (permissions.contains(Constant.PAYMENT)) {
            refundSelectedammout();
          } else {
            await SyncAPICalls.logActivity(
                "payment",
                "chashier has no permission for payment while refund",
                "payment",
                1);
            await CommonUtils.openPermissionPop(context, Constant.PAYMENT,
                () async {
              await refundSelectedammout();
              await SyncAPICalls.logActivity(
                  "payment",
                  "Manager given permission for payment while refund",
                  "payment",
                  1);
            }, () {});
          }
        }),
      ],
    );
  }

  Widget refundCancelButton(_onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Cancel",
          style: TextStyle(
              color: orderpayment[0].op_status == 1
                  ? StaticColor.colorWhite
                  : StaticColor.colorwhite38,
              fontSize: 20),
        ),
        color: StaticColor.deepOrange,
        textColor: StaticColor.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget refundNextButton(_onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Next",
          style: TextStyle(
              color: orderpayment[orderpayment.length - 1].op_status == 1
                  ? StaticColor.colorWhite
                  : StaticColor.colorwhite38,
              fontSize: 20),
        ),
        color: StaticColor.deepOrange,
        textColor: StaticColor.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget transationsButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        refundButton(() async {
          if (orderpayment[orderpayment.length - 1].op_status == 1) {
            if (permissions.contains(Constant.REFUND)) {
              requestRefund();
              SyncAPICalls.logActivity("refund",
                  "chashier has no permission for Refund", "refund", 1);
            } else {
              await CommonUtils.openPermissionPop(context, Constant.REFUND, () {
                requestRefund();
                SyncAPICalls.logActivity("refund",
                    "Manager given permission for Refund", "refund", 1);
              }, () {});
            }
          }
        }),
        CommunFun.horisontalSpace(10),
        cancelButton(
          () async {
            var alertTransaction = CommonUtils.showAlertDialog(context, () {
              Navigator.of(context).pop();
            }, () {
              Navigator.of(context).pop();
              showReasontypePop();
            },
                "Warning",
                "This action can not be undone. Do you want to cancel this transaction?",
                "Yes",
                "No",
                true);
            if (orderpayment[orderpayment.length - 1].op_status == 1) {
              if (permissions.contains(Constant.CANCLE_TRANSACTION)) {
                await alertTransaction;
                SyncAPICalls.logActivity("cancel transaction",
                    "chashier has request for cancel transaction", "order", 1);
              } else {
                await CommonUtils.openPermissionPop(
                    context, Constant.CANCLE_TRANSACTION, () async {
                  SyncAPICalls.logActivity(
                      "cancel transaction",
                      "Manager given permission for cancel transaction",
                      "order",
                      1);
                  await alertTransaction;
                }, () {});
              }
            }
          },
        ),
      ],
    );
  }

  Widget totalAmountValues() {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.subTotal.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 5),
                          child: Text(
                            selectedOrder.sub_total != null
                                ? selectedOrder.sub_total.toStringAsFixed(2)
                                : "00:00",
                            textAlign: TextAlign.end,
                            style: Styles.darkGray(),
                          ))),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.discount.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 2.8,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.voucher_amount != null &&
                                    selectedOrder.voucher_amount.toString() !=
                                        '0.0'
                                ? selectedOrder.voucher_amount
                                    .toStringAsFixed(2)
                                : "0.00",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockVertical * 2.8,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor),
                          ))),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      selectedOrder.serviceChargePercent == null
                          ? Strings.serviceCharge.toUpperCase()
                          : Strings.serviceCharge.toUpperCase() +
                              "(" +
                              selectedOrder.serviceChargePercent.toString() +
                              "%)",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 2.8,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.serviceCharge != null &&
                                    selectedOrder.serviceCharge.toString() !=
                                        '0.0'
                                ? selectedOrder.serviceCharge.toStringAsFixed(2)
                                : "0.00",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockVertical * 2.8,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor),
                          ))),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child:
                  /* taxJson.length != 0
                  ? Column(
                      children: taxJson.map((taxitem) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new Expanded(
                              flex: 7,
                              child: Text(
                                Strings.tax.toUpperCase() +
                                    " " +
                                    taxitem["taxCode"] +
                                    "(" +
                                    taxitem["rate"] +
                                    "%)",
                                textAlign: TextAlign.end,
                                style: Styles.darkGray(),
                              ),
                            ),
                            new Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Text(
                                      double.parse(taxitem["taxAmount"])
                                          .toStringAsFixed(2),
                                      textAlign: TextAlign.end,
                                      style: Styles.darkGray()),
                                ))
                          ]);
                    }).toList())
                  :  */
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                    new Expanded(
                      flex: 7,
                      child: Text(
                        Strings.tax.toUpperCase(),
                        textAlign: TextAlign.end,
                        style: Styles.darkGray(),
                      ),
                    ),
                    new Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                              selectedOrder != null
                                  ? selectedOrder.tax_amount.toStringAsFixed(2)
                                  : 0.00,
                              textAlign: TextAlign.end,
                              style: Styles.darkGray()),
                        ))
                  ]),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.grandTotal,
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.grand_total != null
                                ? selectedOrder.grand_total.toStringAsFixed(2)
                                : "00:00",
                            textAlign: TextAlign.end,
                            style: Styles.darkGray(),
                          ))),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    flex: 7,
                    child: Text(
                      Strings.roundingAmmount.toUpperCase(),
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    ),
                  ),
                  new Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            selectedOrder.rounding_amount != null
                                ? selectedOrder.rounding_amount
                                    .toStringAsFixed(2)
                                : "00:00",
                            textAlign: TextAlign.end,
                            style: Styles.darkGray(),
                          ))),
                ],
              ),
            ),
          ]),
        ]);
  }

  Widget refundButton(Function _onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          "Refund",
          style: TextStyle(
              color: orderpayment.length > 0 &&
                      orderpayment[orderpayment.length - 1].op_status == 1
                  ? StaticColor.colorWhite
                  : StaticColor.colorwhite38,
              fontSize: 20),
        ),
        color: StaticColor.deepOrange,
        textColor: StaticColor.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget cancelButton(Function _onPress) {
    return Expanded(
      child: RaisedButton(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        onPressed: _onPress,
        child: Text(
          Strings.cancelTransaction,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: orderpayment.length > 0 &&
                      orderpayment[orderpayment.length - 1].op_status == 1
                  ? StaticColor.colorWhite
                  : StaticColor.colorwhite38,
              fontSize: 20),
        ),
        color: StaticColor.deepOrange,
        textColor: StaticColor.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget productList() {
    return Container(
      //color: StaticColor.colorWhite,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
      // height: MediaQuery.of(context).size.height / 2,
      child: Column(
          children: orderItemList.map((product) {
        var index = orderItemList.indexOf(product);
        var item = orderItemList[index];
        var producrdata = json.decode(item.product_detail);
        // print(producrdata);
        return InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                //  mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: index,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 8,
                      width: SizeConfig.safeBlockVertical * 9,
                      decoration: new BoxDecoration(
                        color: StaticColor.colorGreenAccent,
                      ),
                      child: product.base64 != ""
                          ? CommonUtils.imageFromBase64String(product.base64)
                          : new Image.asset(
                              Strings.noImageAsset,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                    ),
                  ),
                  CommunFun.horisontalSpace(15),
                  Flexible(
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(producrdata["name"].toString().toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockVertical * 2.8,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(product.detail_qty.toStringAsFixed(0),
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 2.8,
                                  color: Theme.of(context).primaryColor)),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                                product.detail_amount.toStringAsFixed(2),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockVertical * 2.8,
                                    color: Theme.of(context).primaryColor))),
                      ],
                    ),
                  )
                ],
              ),
            ));
      }).toList()),
    );
  }

  Widget reprintRecipet() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      RaisedButton(
        padding: EdgeInsets.only(left: 10, right: 10),
        onPressed: () async {
          if (permissions.contains(Constant.REPRINT_PREVIOS_RECIEPT)) {
            reprintRecipt();
          } else {
            await SyncAPICalls.logActivity(
                "reprint previos receipt",
                "chashier has permission for reprint previos receipt",
                "transaction",
                1);
            CommonUtils.openPermissionPop(
                context, Constant.REPRINT_PREVIOS_RECIEPT, () async {
              await SyncAPICalls.logActivity(
                  "reprint previos receipt",
                  "Manager given permission for reprint previos receipt",
                  "transaction",
                  1);
              reprintRecipt();
            }, () {});
          }
        },
        child: Text(
          Strings.printReciept,
          style: TextStyle(color: StaticColor.deepOrange, fontSize: 15),
        ),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              style: BorderStyle.solid,
              color: StaticColor.deepOrange),
          borderRadius: BorderRadius.circular(50.0),
        ),
      )
    ]);
  }

  Widget orderDateText() {
    return Text(orderDate, style: Styles.whiteMediumBold());
  }

  Widget grandTotalText() {
    return Text(
      selectedOrder.grand_total != null
          ? selectedOrder.grand_total.toStringAsFixed(2)
          : "",
      style: Styles.whiteBold(),
    );
  }

  Widget userNameText() {
    return selectedOrder != null && paymemtUser.username != null
        ? Text(
            selectedOrder.invoice_no +
                " - Processed by " +
                paymemtUser.username,
            style: Styles.whiteBoldsmall(),
          )
        : SizedBox();
  }

  Widget searchTransationList() {
    if (isFiltering) {
      return Expanded(
          child: ListView.builder(
        //+1 for progressbar
        padding: EdgeInsets.only(left: 5, right: 5, bottom: 100),
        physics: BouncingScrollPhysics(),
        itemExtent: 65,
        shrinkWrap: true,
        itemCount: filterList.length,
        itemBuilder: (BuildContext context, int index) {
          return orderitemTile(filterList[index]);
        },
      ));
    } else {
      return Expanded(
          child: ListView.builder(
        //+1 for progressbar
        padding: EdgeInsets.only(left: 5, right: 5, bottom: 100),
        physics: BouncingScrollPhysics(),
        itemExtent: 65,
        shrinkWrap: true,
        itemCount: orderLists.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == orderLists.length) {
            return _buildProgressIndicator();
          } else {
            return orderitemTile(orderLists[index]);
          }
        },
        controller: _scrollController,
      ));
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isScreenLoad ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget orderitemTile(item) {
    return Container(
        height: 100.0,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: new BoxDecoration(
            color: selectedOrder.app_id == item.app_id &&
                    selectedOrder.terminal_id == item.terminal_id
                ? StaticColor.lightGrey100
                : StaticColor.colorWhite),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
          dense: false,
          selected: selectedOrder.app_id == item.app_id,
          onTap: () {
            getOrderDetails(item);
          },
          title: Row(
            children: <Widget>[
              Text(
                  DateFormat('hh:mm aaa')
                      .format(DateTime.parse(item.order_date)),
                  style: Styles.greysmall()),
              CommunFun.horisontalSpace(10),
              item.order_status == 3
                  ? Container(
                      padding: EdgeInsets.all(3),
                      color: StaticColor.colorRed,
                      child: Text(
                        "Cancel",
                        style: Styles.whiteBoldsmall(),
                      ),
                    )
                  : SizedBox(),
              item.order_status == 5
                  ? Container(
                      padding: EdgeInsets.all(3),
                      color: StaticColor.colorRed,
                      child: Text(
                        "Refunded",
                        style: Styles.whiteBoldsmall(),
                      ),
                    )
                  : SizedBox()
            ],
          ),
          subtitle: Text(
              Strings.invoice +
                  item.invoice_no.toString() +
                  "(" +
                  item.terminal_id.toString() +
                  ")",
              style: Styles.greysmall()),
          isThreeLine: true,
          trailing: Text(item.grand_total.toStringAsFixed(2),
              style: Styles.greysmall()),
        ));
  }
}

class ChooseReasonType extends StatefulWidget {
  ChooseReasonType({Key key, this.onClose}) : super(key: key);
  Function onClose;

  @override
  ChooseReasonTypeState createState() => ChooseReasonTypeState();
}

class ChooseReasonTypeState extends State<ChooseReasonType> {
  String reason = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
        height: 70,
        color: StaticColor.colorBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Choose Reason", style: Styles.whiteBold()),
            CloseButtonWidget(inputContext: context)
          ],
        ),
      ), // close button
      contentPadding: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 10),
      content: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        child: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              selectedTileColor: Colors.orange[200],
              tileColor: Colors.white10,
              selected: reason == "Incorrect Item",
              onTap: () {
                setState(() {
                  reason = "Incorrect Item";
                });
                // widget.onClose("Incorrect Item");
              },
              title: Text(
                "Incorrect Item",
                style: Styles.communBlacksmall(),
              ),
            ),
            ListTile(
              selected: reason == "Incorrect variant",
              selectedTileColor: Colors.orange[200],
              tileColor: Colors.white10,
              onTap: () {
                setState(() {
                  reason = "Incorrect variant";
                });
              },
              title: Text(
                "Incorrect variant",
                style: Styles.communBlacksmall(),
              ),
            ),
            ListTile(
              selectedTileColor: Colors.orange[200],
              tileColor: Colors.white10,
              selected: reason == "Incorrect payment type",
              onTap: () {
                setState(() {
                  reason = "Incorrect payment type";
                });
              },
              title: Text(
                "Incorrect payment type",
                style: Styles.communBlacksmall(),
              ),
            ),
            ListTile(
              selectedTileColor: Colors.orange[200],
              tileColor: Colors.white10,
              selected: reason == "Incorrect quantity",
              onTap: () {
                setState(() {
                  reason = "Incorrect quantity";
                });
              },
              title: Text(
                "Incorrect quantity",
                style: Styles.communBlacksmall(),
              ),
            ),
            ListTile(
              selectedTileColor: Colors.orange[200],
              tileColor: Colors.white10,
              selected: reason == "Other",
              onTap: () {
                setState(() {
                  reason = "Other";
                });
              },
              title: Text(
                "Other",
                style: Styles.communBlacksmall(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [confirmBtn(context)],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget confirmBtn(context) {
    // Add button header rounded
    return FlatButton(
      // padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      onPressed: () {
        widget.onClose(reason);
        // Navigator.of(context).pop();
      },
      child: Text("Confirm",
          style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: 20,
          )),
      color: StaticColor.deepOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      textColor: StaticColor.colorWhite,
    );
  }

  Widget closeButton(context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: StaticColor.colorRed,
              borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                reason = "";
              });
            },
            icon: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class AddOtherReason extends StatefulWidget {
  AddOtherReason({Key key, this.onClose}) : super(key: key);
  Function onClose;

  @override
  AddOtherReasonState createState() => AddOtherReasonState();
}

class AddOtherReasonState extends State<AddOtherReason> {
  TextEditingController reasonController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      content: Container(
        height: MediaQuery.of(context).size.height / 3.5,
        width: MediaQuery.of(context).size.width / 3.4,
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Reason",
                  style: Styles.communBlack(),
                ),
                CommunFun.verticalSpace(3),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(width: 1, color: StaticColor.colorGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(width: 1, color: StaticColor.colorGrey),
                    ),
                  ),
                ),
              ],
            )),
      ),
      actions: <Widget>[canclebutton(context), confirmBtn(context)],
    );
  }

  Widget confirmBtn(context) {
    // Add button header rounded
    return FlatButton(
      onPressed: () {
        widget.onClose(reasonController.text);
      },
      child: Text("Confirm", style: Styles.whiteMediumBold()),
      textColor: StaticColor.colorWhite,
      color: StaticColor.deepOrange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  Widget canclebutton(context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel", style: Styles.orangeSmall()),
      textColor: StaticColor.colorWhite,
    );
  }
}
