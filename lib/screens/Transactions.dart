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
  double change = 0.0;
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
    var branch = await localAPI.getbranchData(branchid);
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
  }

  getTansactionList() async {
    setState(() {
      isScreenLoad = true;
    });
    var terminalid = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    List<Orders> orderList =
        await localAPI.getOrdersList(branchid, terminalid, currentOffset);
    if (orderList.length > 0) {
      setState(() {
        orderLists.addAll(orderList);
        currentOffset += 10;
      });
      getOrderDetails(orderLists[0]);
    }
    setState(() {
      isScreenLoad = false;
    });
  }

  getOrderDetails(Orders order) async {
    setState(() {
      isScreenLoad = true;
    });
    var date = await CommunFun.getCurrentDateTime(DateTime.parse(
        order.order_date != null
            ? order.order_date
            : DateTime.now().toString()));
    var orderDateF =
        DateFormat('EEE, MMM d yyyy, hh:mm aaa').format(DateTime.parse(date));
    setState(() {
      selectedOrder = order;
      orderDate = orderDateF;
      isWeborder = order.order_source == 1 ? true : false;
      taxJson = json.decode(selectedOrder.tax_json);
    });

    List<OrderDetail> orderItem =
        await localAPI.getOrderDetailsList(order.app_id, order.terminal_id);
    // List<ProductDetails> details =
    //     await localAPI.getOrderDetails(order.app_id, order.terminal_id);
    if (orderItem.length > 0) {
      setState(() {
        orderItemList = orderItem;
      });
    }

    //  if (order.order_source == 2) {
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(order.app_id, order.terminal_id);
    setState(() {
      orderpayment = orderpaymentdata;
    });
    if (orderpayment.length > 0) {
      List<Payments> payMethod =
          await localAPI.getOrderpaymentmethod(order.app_id, order.terminal_id);
      setState(() {
        paymentMethod = payMethod;
      });
      User user = await localAPI.getPaymentUser(orderpayment[0].op_by);
      if (user != null) {
        setState(() {
          paymemtUser = user;
        });
      }
    }
    setState(() {
      isScreenLoad = false;
    });
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

  refundProcessStart() {
    setState(() {
      isRefunding = true;
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
    var addTocancle = await localAPI.insertCancelOrder(order);

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
            var ulog = await localAPI.updateInvetory(updatedInt);
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
              var ulog =
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
            onClose: (mehtod) {
              Navigator.of(context).pop();
              returnPayment(mehtod);
            },
          );
        });
  }

  returnPayment(paymentMehtod) async {
    Orders orderData = Orders();
    User userdata = await CommunFun.getuserDetails();
    orderData = selectedOrder;
    orderData.order_status = 5;
    orderData.isSync = 0;
    orderData.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
    orderData.updated_by = userdata.id;
    await localAPI.updateOrderStatus(orderData);
    var upDate = await CommunFun.getCurrentDateTime(DateTime.now());
    await localAPI.updatePaymentStatus(selectedOrder.app_id,
        selectedOrder.terminal_id, 5, upDate, userdata.id);
    var terminalId = await CommunFun.getTeminalKey();
    var uuid = await CommunFun.getLocalID();
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
          drawer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
          drawer.localID = uuid;
          drawer.terminalid = int.parse(terminalId);
          await localAPI.saveInOutDrawerData(drawer);
        }
      }
    }
    List<OrderDetail> orderItem = orderItemList;
    var branchid = await CommunFun.getbranchId();
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
            var ulog = await localAPI.updateInvetory(updatedInt);
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
              var ulog =
                  await localAPI.updateStoreInvetoryLogTable(updatedIntLog);
            }
          }
        }
      }
    }
    setState(() {
      isRefunding = false;
    });
    Navigator.of(context).pop();
    getTansactionList();
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
      var result = await localAPI.deleteOrderItem(product.app_id);
      var result1 = await localAPI.updateInvoice(order);
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
      PrintReceipt printKOT = PrintReceipt();
      printKOT.checkReceiptPrint(
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
          "",
          currency,
          Strings.walkin_customer,
          true,
          true);
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
                                        child: Text(Strings.no_order_found,
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
                                                  isRefunding
                                                      ? refundButtons(context)
                                                      : transationsButton()
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
          Strings.no_order_found,
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
          padding: EdgeInsets.all(0),
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
    return change != null
        ? Row(
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
                      change.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: Styles.darkGray(),
                    )),
              )
            ],
          )
        : SizedBox();
  }

  Widget paymentDetails() {
    return Column(
        children: orderpayment.map((payment) {
      var index = orderpayment.indexOf(payment);
      change =
          payment.op_amount_change != null ? payment.op_amount_change : 0.0;
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
                paymentMethod.length > 0
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
          hintText: Strings.searchbox_hint,
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

  Widget transationsButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        refundButton(() async {
          if (permissions.contains(Constant.REFUND)) {
            if (orderpayment[0].op_status == 1) {
              refundProcessStart();
            }
          } else {
            await SyncAPICalls.logActivity(
                "refund", "chashier has no permission for Refund", "refund", 1);
            await CommonUtils.openPermissionPop(context, Constant.REFUND,
                () async {
              await refundProcessStart();
              await SyncAPICalls.logActivity(
                  "refund", "Manager given permission for Refund", "refund", 1);
            }, () {});
          }
        }),
        CommunFun.horisontalSpace(10),
        cancelButton(() async {
          if (permissions.contains(Constant.CANCLE_TRANSACTION)) {
            if (orderpayment[0].op_status == 1) {
              CommonUtils.showAlertDialog(context, () {
                Navigator.of(context).pop();
              }, () {
                Navigator.of(context).pop();
                showReasontypePop();
              },
                  "Warning",
                  "This action can not be undone. Do you want to avoid this transaction?",
                  "Yes",
                  "No",
                  true);
            }
          } else {
            await SyncAPICalls.logActivity(
                "cancel transaction",
                "chashier has no permission for cancel transaction",
                "order",
                1);
            await CommonUtils.openPermissionPop(
                context, Constant.CANCLE_TRANSACTION, () async {
              if (orderpayment[0].op_status == 1) {
                await SyncAPICalls.logActivity(
                    "cancel transaction",
                    "Manager given permission for cancel transaction",
                    "order",
                    1);
                await CommonUtils.showAlertDialog(context, () {
                  Navigator.of(context).pop();
                }, () {
                  Navigator.of(context).pop();
                  showReasontypePop();
                },
                    "Warning",
                    "This action can not be undone. Do you want to avoid this transaction?",
                    "Yes",
                    "No",
                    true);
              }
            }, () {});
          }
        }),
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
                      Strings.sub_total.toUpperCase(),
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
                                : "00.00",
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
                          ? Strings.service_charge.toUpperCase()
                          : Strings.service_charge.toUpperCase() +
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
                                : "00.00",
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
              child: taxJson.length != 0
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
                  : Row(
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
                                        ? selectedOrder.tax_amount
                                            .toStringAsFixed(2)
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
                      Strings.grand_total,
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
                      Strings.rounding_ammount.toUpperCase(),
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
              color: orderpayment.length > 0 && orderpayment[0].op_status == 1
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
          Strings.cancel_tansaction,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: orderpayment.length > 0 && orderpayment[0].op_status == 1
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
        print(item.product_detail);
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
                    tag: product.product_id,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 8,
                      width: SizeConfig.safeBlockVertical * 9,
                      decoration: new BoxDecoration(
                        color: StaticColor.colorGreenAccent,
                      ),
                      child: product.base64 != ""
                          ? CommonUtils.imageFromBase64String(product.base64)
                          : new Image.asset(
                              Strings.no_imageAsset,
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
                        // isRefunding
                        //     ? IconButton(
                        //         icon: Icon(
                        //           Icons.remove_circle_outline,
                        //           color: Colors.red,
                        //           size: SizeConfig.safeBlockVertical * 5,
                        //         ),
                        //         onPressed: () {
                        //           CommonUtils.showAlertDialog(context, () {
                        //             Navigator.of(context).pop();
                        //           }, () {
                        //             Navigator.of(context).pop();
                        //             deleteItemFormList(product);
                        //           },
                        //               "Alert",
                        //               "Are you sure you want to delete this item?",
                        //               "Yes",
                        //               "No",
                        //               true);
                        //           //deleteItemFormList(product);
                        //         })
                        //     : SizedBox(),
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
          Strings.print_reciept,
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: StaticColor.colorBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Choose Reason", style: Styles.whiteBold()),
              ],
            ),
          ),
          Positioned(left: 10, top: 15, child: confirmBtn(context)),
          closeButton(context), // close button
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        child: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect Item");
                },
                title: Text(
                  "Incorrect Item",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect variant");
                },
                title: Text(
                  "Incorrect variant",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect payment type");
                },
                title: Text(
                  "Incorrect payment type",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Incorrect quantity");
                },
                title: Text(
                  "Incorrect quantity",
                  style: Styles.communBlacksmall(),
                )),
            ListTile(
                onTap: () {
                  widget.onClose("Other");
                },
                title: Text(
                  "Other",
                  style: Styles.communBlacksmall(),
                )),
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
        widget.onClose();
      },
      child: Text("Confirm",
          style: TextStyle(
            color: StaticColor.colorWhite,
            fontSize: 20,
          )),
      textColor: StaticColor.colorWhite,
    );
  }

  Widget closeButton(context) {
    return Positioned(
      top: -30,
      right: -20,
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
      titlePadding: EdgeInsets.all(0),
      content: Container(
        height: MediaQuery.of(context).size.height / 4,
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
                CommunFun.verticalSpace(10),
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
      child: Text("Confirm", style: Styles.orangeSmall()),
      textColor: StaticColor.colorWhite,
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
