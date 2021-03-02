import 'dart:convert';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'PaymentMethodPop.dart';

class SplitBillDialog extends StatefulWidget {
  SplitBillDialog(
      {Key key,
      this.onSelectedRemove,
      this.onClose,
      this.currentCartID,
      this.pax,
      this.customer,
      this.printerIP})
      : super(key: key);
  String pax;
  Function onClose;
  Function onSelectedRemove;
  int currentCartID;
  String customer;
  String printerIP;

  @override
  _SplitBillDialog createState() => _SplitBillDialog();
}

class _SplitBillDialog extends State<SplitBillDialog> {
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
  double subTotal = 00.00;
  double taxValues = 00.00;
  double grandTotal = 00.00;
  int totalQty = 0;
  List<BranchTax> taxlist = [];
  List taxJson = [];
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  bool isLoading = false;
  String selectedID = "";
  PrintReceipt _printReceipt = PrintReceipt();
  var currency = "RM";
  var permissions;
  @override
  void initState() {
    super.initState();
    getTaxs();
    getCartItem();
    setPermissons();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
    await SyncAPICalls.logActivity("split payment",
        "open split payment popup for split orders", "split payment", 1);
  }

  getCartItem() async {
    /*this is used for set user data*/
    widget.customer.isEmpty
        ? await Preferences.removeSinglePref(Constant.CUSTOMER_DATA_SPLIT)
        : await Preferences.setStringToSF(
            Constant.CUSTOMER_DATA_SPLIT,
            json.encode(Preferences.getStringValuesSF(Constant.CUSTOMER_DATA)
                .toString()));

    setState(() {
      isLoading = true;
    });
    List<MSTCartdetails> cartItem =
        await localAPI.getCartItem(widget.currentCartID);
    if (cartItem.length > 0) {
      setState(() {
        cartList = cartItem;
        isLoading = false;
      });
    }
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: SizeConfig.safeBlockVertical * 9,
            color: StaticColor.colorBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    widget.customer.isEmpty
                        ? "Walk-in customer"
                        : widget.customer,
                    style: Styles.whiteBoldsmall()),
                SizedBox(
                  width: 10,
                ),
                widget.customer.isEmpty
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          openShowAddCustomerDailog();
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: StaticColor.colorWhite,
                          size: 30,
                        ))
                    : IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          CommonUtils.showAlertDialog(context, () {
                            Navigator.of(context).pop();
                          }, () {
                            Navigator.of(context).pop();
                            removeCustomer();
                          },
                              "Alert",
                              "Are you sure you want remove this customer?",
                              "Yes",
                              "No",
                              true);
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: StaticColor.colorWhite,
                          size: 30,
                        )),
              ],
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: GestureDetector(
              onTap: () async {
                if (tempCart.length > 0) {
                  if (permissions.contains(Constant.PAYMENT)) {
                    openPaymentMethod();
                  } else {
                    await SyncAPICalls.logActivity("payment",
                        "Chasier has no permission for payment", "payment", 1);
                    await CommonUtils.openPermissionPop(
                        context, Constant.PAYMENT, () async {
                      await SyncAPICalls.logActivity("payment",
                          "Manager given permission for payment", "payment", 1);
                      await openPaymentMethod();
                    }, () {});
                  }
                } else {
                  CommunFun.showToast(context, "Please select item for split");
                }
                /*tempCart.forEach((element) {
                  var contain =
                      cartList.where((mainCart) => mainCart.id == element.id);

                  if (contain.isNotEmpty) {
                    setState(() {
                      cartList.remove(element);
                    });
                  }
                  widget.onSelectedRemove(element);
                });*/
              },
              child: Text(
                Strings.pay.toUpperCase(),
                style: Styles.whiteSimpleSmall(),
              ),
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
    );
  }

  openPaymentMethod() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return PaymentMethodPop(
            subTotal: subTotal,
            grandTotal: grandTotal,
            onClose: (mehtod) {
              Navigator.of(context).pop();
              CommunFun.processingPopup(context);
              paymentWithMethod(mehtod);
            },
          );
        });
  }

  paymentWithMethod(mehtod) async {
    sendPaymentByCash(mehtod);
  }

  openShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchCustomerPage(
            onClose: () {
              checkCustomerSelected();
            },
            isFor: Constant.splitbill,
          );
        });
  }

  checkCustomerSelected() async {
    Customer customerData = await getCustomer();
    setState(() {
      widget.customer = customerData.name;
    });
  }

  Future<Customer> getCustomer() async {
    Customer customer;
    var customerData =
        await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA_SPLIT);
    if (customerData != null) {
      var customers = json.decode(customerData);
      customer = Customer.fromJson(customers);
      return customer;
    } else {
      return customer;
    }
  }

  removeCustomer() async {
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA_SPLIT);
    setState(() {
      widget.customer = "";
    });
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
            child: Icon(
              Icons.clear,
              color: StaticColor.colorWhite,
              size: 30,
            ),
          ),
        ));
  }

  setTotalSubTotal() async {
    subTotal = 00.00;
    grandTotal = 00.00;
    totalQty = 0;
    tempCart.forEach((element) {
      subTotal = subTotal + element.productPrice;
      totalQty = totalQty + element.productQty.toInt();
    });
    var tempTaxJSon = await countTax(subTotal);
    setState(() {
      taxJson = tempTaxJSon;
      subTotal = subTotal;
      grandTotal = subTotal + taxValues;
    });
  }

  getTaxs() async {
    var branchid = await CommunFun.getbranchId();
    List<BranchTax> taxlists = await localAPI.getTaxList();
    if (taxlists.length > 0) {
      setState(() {
        taxlist = taxlists;
      });
    }
  }

  countTax(subT) async {
    taxValues = 0.00;
    var totalTax = [];
    double taxvalue = taxValues;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        List<Tax> tax = await localAPI.getTaxName(taxlistitem.taxId);
        var taxval = taxlistitem.rate != null
            ? subT * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        setState(() {
          taxValues = taxvalue;
        });
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toStringAsFixed(2),
          "taxCode": tax.length > 0 ? tax[0].code : "" //tax.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  Widget mainContent() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height / 1.5,
      child: Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: StaticColor.colorWhite,
        child: Stack(children: <Widget>[
          isLoading ? CommunFun.loader(context) : productList(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: StaticColor.colorWhite,
              padding: EdgeInsets.only(right: 0),
              child: Column(children: <Widget>[
                Divider(),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Text(
                        "Sub Total".toUpperCase(),
                        style: Styles.darkGray(),
                      ),
                    ),
                    SizedBox(width: 70),
                    Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                        child: Text(
                          subTotal.toStringAsFixed(2),
                          style: Styles.blackMediumbold(),
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: taxJson.length != 0
                      ? Column(
                          children: taxJson.map((taxitem) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    Strings.tax.toUpperCase() +
                                        " " +
                                        taxitem["taxCode"] +
                                        "(" +
                                        taxitem["rate"] +
                                        "%)",
                                    style: Styles.darkGray(),
                                  ),
                                ),
                                SizedBox(width: 70),
                                Padding(
                                  padding: EdgeInsets.zero,
                                  child: Text(taxitem["taxAmount"].toString(),
                                      style: Styles.blackMediumbold()),
                                )
                              ]);
                        }).toList())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  Strings.tax.toUpperCase(),
                                  style: Styles.darkGray(),
                                ),
                              ),
                              SizedBox(width: 70),
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  taxValues.toStringAsFixed(2),
                                  style: Styles.blackMediumBold(),
                                ),
                              )
                            ]),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0,
                      ),
                      child: Text(
                        "Grand Total".toUpperCase(),
                        style: Styles.darkGray(),
                      ),
                    ),
                    SizedBox(width: 70),
                    Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                        child: Text(
                          grandTotal.toStringAsFixed(2),
                          style: Styles.blackMediumbold(),
                        )),
                  ],
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget productList() {
    return Container(
      color: StaticColor.colorWhite,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 200),
        child: Column(
            children: cartList.map((product) {
          var productdata = json.decode(product.cart_detail);
          return InkWell(
              onTap: () {
                _setSelectUnselect(product);
              },
              child: Container(
                color: tempCart
                        .where((element) => element.id == product.id)
                        .isNotEmpty
                    ? StaticColor.lightGrey100
                    : StaticColor.colorWhite,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                        tag: product.productId,
                        child: GestureDetector(
                          onTap: () {
                            // _setSelectUnselect(product);
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: SizeConfig.safeBlockVertical * 8,
                                width: SizeConfig.safeBlockVertical * 9,
                                child: productdata["base64"] != "" &&
                                        productdata["base64"] != null
                                    ? CommonUtils.imageFromBase64String(
                                        productdata["base64"])
                                    : new Image.asset(
                                        Strings.noImageAsset,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      ),
                              ),
                              tempCart
                                      .where(
                                          (element) => element.id == product.id)
                                      .isNotEmpty
                                  ? Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: SizeConfig.safeBlockVertical * 9,
                                      color: Colors.black54,
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            _setSelectUnselect(product);
                                          },
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: StaticColor.colorWhite,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox()
                            ],
                          ),
                        )),
                    SizedBox(width: 15),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(product.productName.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Styles.smallBlack())
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(product.productQty.toStringAsFixed(0),
                              style: Styles.smallBlack()),
                          SizedBox(width: 90),
                          Text(product.productPrice.toStringAsFixed(2),
                              style: Styles.smallBlack()),
                        ],
                      ),
                    )
                  ],
                ),
              ));
        }).toList()),
      ),
    );
  }

  _setSelectUnselect(MSTCartdetails product) {
    var contain = tempCart.where((element) => element.id == product.id);
    if (contain.isNotEmpty) {
      setState(() {
        tempCart.remove(product);
      });
    } else if (contain.isEmpty) {
      setState(() {
        tempCart.add(product);
      });
    }
    setTotalSubTotal();
  }

  sendPaymentByCash(List<OrderPayment> payment) async {
    var cartData = await getcartData();
    var branchdata = await getbranch();
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    Orders order = new Orders();
    Table_order tables = await getTableData();
    User userdata = await CommunFun.getuserDetails();
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    List<Orders> lastappid = await localAPI.getLastOrderAppid(terminalId);
    int length = branchdata.invoiceStart.length;
    var invoiceNo;
    if (lastappid.length > 0) {
      order.app_id = lastappid[0].app_id + 1;
      invoiceNo =
          branchdata.orderPrefix + order.app_id.toString().padLeft(length, "0");
    } else {
      order.app_id = 1;
      invoiceNo =
          branchdata.orderPrefix + order.app_id.toString().padLeft(length, "0");
    }
    double newgTotal =
        double.parse(CommunFun.checkRoundData(grandTotal.toStringAsFixed(2)));
    double rounding = double.parse(CommunFun.calRounded(newgTotal, grandTotal));
    order.uuid = uuid;
    order.branch_id = int.parse(branchid);
    order.terminal_id = int.parse(terminalId);
    order.table_id = tables.table_id;
    order.pax = tables.number_of_pax;
    order.invoice_no = invoiceNo;
    order.customer_id = cartData.user_id;
    order.sub_total = subTotal;
    order.sub_total_after_discount = subTotal;
    order.grand_total = newgTotal;
    order.rounding_amount = rounding;
    order.order_item_count = totalQty;
    order.tax_amount = taxValues;
    order.tax_json = json.encode(taxJson);
    order.order_date = await CommunFun.getCurrentDateTime(DateTime.now());
    order.order_status = 1;
    order.server_id = 0;
    order.isSync = 0;
    order.order_source = cartData.source;
    order.order_by = userdata.id;
    order.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
    order.updated_by = userdata.id;
    var orderid = await localAPI.placeOrder(order);
    var orderDetailid;
    if (orderid > 0) {
      if (tempCart.length > 0) {
        var orderId = orderid;
        for (var i = 0; i < tempCart.length; i++) {
          OrderDetail orderDetail = new OrderDetail();
          var cartItem = tempCart[i];
          var productdata = await localAPI.productdData(cartItem.productId);
          ProductDetails pdata;
          if (productdata.length > 0) {
            productdata[0].qty = cartItem.productQty;
            productdata[0].price = cartItem.productPrice;
            pdata = productdata[0];
          }
          List<OrderDetail> lappid =
              await localAPI.getLastOrdeDetailAppid(terminalId);
          if (lappid.length > 0) {
            orderDetail.app_id = lappid[0].app_id + 1;
          } else {
            orderDetail.app_id = 1;
          }
          orderDetail.uuid = uuid;
          orderDetail.order_app_id = orderId;
          orderDetail.branch_id = int.parse(branchid);
          orderDetail.terminal_id = int.parse(terminalId);
          orderDetail.product_id = cartItem.productId;
          orderDetail.product_price = cartItem.productPrice;
          orderDetail.detail_amount = cartItem.productDetailAmount;
          orderDetail.product_old_price = cartItem.productNetPrice;
          orderDetail.detail_qty = cartItem.productQty;
          orderDetail.product_discount = cartItem.discountAmount;
          orderDetail.product_detail = json.encode(pdata);
          orderDetail.isSync = 0;
          orderDetail.server_id = 0;
          orderDetail.updated_at =
              await CommunFun.getCurrentDateTime(DateTime.now());
          orderDetail.detail_datetime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          orderDetail.updated_by = userdata.id;
          orderDetail.detail_status = 1;
          orderDetail.detail_by = userdata.id;
          if (cartItem.issetMeal == 1) {
            orderDetail.setmeal_product_detail =
                cartItem.setmeal_product_detail;
          }
          orderDetailid = await localAPI.sendOrderDetails(orderDetail);
          if (cartItem.issetMeal == 0) {
            List<ProductStoreInventory> updatedInt = [];
            List<ProductStoreInventoryLog> updatedIntLog = [];

            if (productdata[0].hasInventory == 1) {
              //update invnotory
              // List<ProductStoreInventory> inventory =
              //     await localAPI.removeFromInventory(orderDetail);
              List<ProductStoreInventory> inventory =
                  await localAPI.getStoreInventoryData(orderDetail.product_id);
              if (inventory.length > 0) {
                ProductStoreInventory invData = new ProductStoreInventory();
                invData = inventory[0];
                var prev = inventory[0];
                var qty = (invData.qty - orderDetail.detail_qty);
                invData.qty = qty;
                invData.updatedAt =
                    await CommunFun.getCurrentDateTime(DateTime.now());
                invData.updatedBy = userdata.id;
                updatedInt.add(invData);
                await localAPI.updateInvetory(updatedInt);

                //Inventory log update
                ProductStoreInventoryLog log = new ProductStoreInventoryLog();
                log.uuid = uuid;
                log.inventory_id = prev.inventoryId;
                log.branch_id = int.parse(branchid);
                log.product_id = cartItem.productId;
                log.employe_id = userdata.id;
                log.qty = prev.qty;
                log.qty_before_change = prev.qty;
                log.qty_after_change = qty;
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
    }
    List<MSTSubCartdetails> modifireList = await getmodifireList();
    if (modifireList.length > 0) {
      var orderId = orderid;
      for (var i = 0; i < modifireList.length; i++) {
        OrderModifire modifireData = new OrderModifire();
        var modifire = modifireList[i];
        var contain =
            tempCart.where((mainCart) => mainCart.id == modifire.cartdetailsId);
        if (contain.isNotEmpty) {
          if (modifire.caId == null) {
            List<OrderModifire> lapMpid =
                await localAPI.getLastOrderModifireAppid(terminalId);
            if (lapMpid.length > 0) {
              modifireData.app_id = lapMpid[0].app_id + 1;
            } else {
              modifireData.app_id = 1;
            }
            modifireData.uuid = uuid;
            modifireData.order_app_id = orderId;
            modifireData.detail_app_id = orderDetailid;
            modifireData.terminal_id = int.parse(terminalId);
            modifireData.product_id = modifire.productId;
            modifireData.modifier_id = modifire.modifierId;
            modifireData.om_amount = modifire.modifirePrice;
            modifireData.om_by = userdata.id;
            modifireData.isSync = 0;
            modifireData.server_id = 0;
            modifireData.om_datetime =
                await CommunFun.getCurrentDateTime(DateTime.now());
            modifireData.om_status = 1;
            modifireData.updated_at =
                await CommunFun.getCurrentDateTime(DateTime.now());
            modifireData.updated_by = userdata.id;
            await localAPI.sendModifireData(modifireData);
          } else {
            OrderAttributes attributes = new OrderAttributes();
            List<OrderAttributes> lapApid =
                await localAPI.getLastOrderAttrAppid(terminalId);
            if (lapApid.length > 0) {
              attributes.app_id = lapApid[0].app_id + 1;
            } else {
              attributes.app_id = 1;
            }
            attributes.uuid = uuid;
            attributes.order_app_id = orderId;
            attributes.detail_app_id = orderDetailid;
            attributes.terminal_id = int.parse(terminalId);
            attributes.product_id = modifire.productId;
            attributes.attribute_id = modifire.attributeId;
            attributes.attr_price = modifire.attrPrice;
            attributes.ca_id = modifire.caId;
            attributes.isSync = 0;
            attributes.server_id = 0;
            attributes.oa_datetime =
                await CommunFun.getCurrentDateTime(DateTime.now());
            attributes.oa_by = userdata.id;
            attributes.oa_status = 1;
            attributes.updated_at =
                await CommunFun.getCurrentDateTime(DateTime.now());
            attributes.updated_by = userdata.id;
            await localAPI.sendAttrData(attributes);
          }
        }
      }
    }
    if (payment.length > 0) {
      for (var i = 0; i < payment.length; i++) {
        OrderPayment orderpayment = payment[i];
        List<OrderPayment> lapPpid =
            await localAPI.getLastOrderPaymentAppid(terminalId);
        if (lapPpid.length > 0) {
          orderpayment.app_id = lapPpid[0].app_id + 1;
        } else {
          orderpayment.app_id = 1;
        }
        orderpayment.uuid = uuid;
        orderpayment.order_app_id = orderid;
        orderpayment.branch_id = int.parse(branchid);
        orderpayment.terminal_id = int.parse(terminalId);
        orderpayment.op_method_id = payment[i].op_method_id;
        orderpayment.op_amount = payment[i].op_amount.toDouble();
        orderpayment.op_amount_change = payment[i].op_amount_change;
        orderpayment.remark = payment[i].remark;
        orderpayment.last_digits = payment[i].last_digits;
        orderpayment.reference_number = payment[i].reference_number;
        orderpayment.approval_code = payment[i].approval_code;
        orderpayment.isCash = payment[i].isCash;
        orderpayment.is_split = payment[i].is_split;
        orderpayment.op_method_response = '';
        orderpayment.op_status = 1;
        orderpayment.isSync = 0;
        orderpayment.server_id = 0;
        orderpayment.op_datetime =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.op_by = userdata.id;
        orderpayment.updated_at =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.updated_by = userdata.id;
        await localAPI.sendtoOrderPayment(orderpayment);

        if (payment[i].isCash == 1) {
          var shiftid =
              await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
          Drawerdata drawer = new Drawerdata();
          drawer.shiftId = shiftid;
          drawer.amount = payment[i].op_amount.toDouble();
          drawer.isAmountIn = 1;
          drawer.reason = "placeOrder";
          drawer.status = 1;
          drawer.createdBy = userdata.id;
          drawer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
          drawer.localID = uuid;
          drawer.terminalid = int.parse(terminalId);
          await localAPI.saveInOutDrawerData(drawer);
        }
      }
    }

    // Shifr Invoice Table
    ShiftInvoice shiftinvoice = new ShiftInvoice();
    int appid = await localAPI.getLastShiftInvoiceAppID(terminalId);
    if (appid != 0) {
      shiftinvoice.app_id = appid + 1;
    } else {
      shiftinvoice.app_id = 1;
    }
    shiftinvoice.shift_app_id = int.parse(shiftid);
    shiftinvoice.invoice_id = orderid;
    shiftinvoice.status = 1;
    shiftinvoice.created_by = userdata.id;
    shiftinvoice.created_at =
        await CommunFun.getCurrentDateTime(DateTime.now());
    shiftinvoice.serverId = 0;
    shiftinvoice.terminal_id = int.parse(terminalId);
    await localAPI.sendtoShiftInvoice(shiftinvoice);

    if (this.cartList.length == tempCart.length) {
      await clearCartAfterSuccess(orderid);
    } else {
      tempCart.forEach((element) {
        var contain =
            this.cartList.where((mainCart) => mainCart.id == element.id);
        if (contain.isNotEmpty) {
          setState(() {
            this.cartList.remove(element);
          });
        }
        widget.onSelectedRemove(element);
      });
    }
    await SyncAPICalls.logActivity("split order", "Splited order", "order", 1);
    await printReceipt(orderid);
  }

  clearSelected() {
    setState(() {
      subTotal = 00.00;
      taxValues = 00.00;
      grandTotal = 00.00;
    });
    Navigator.of(context).pop();
    widget.onClose("yes");
  }

  clearCartAfterSuccess(orderid) async {
    Table_order tables = await getTableData();
    await localAPI.removeCartItem(widget.currentCartID, tables.table_id);
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    Navigator.of(context).pop();
    widget.onClose("clear");
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await localAPI.getbranchData();
    return branch;
  }

  getcartData() async {
    var cartDatalist = await localAPI.getCartData(widget.currentCartID);
    return cartDatalist;
  }

  Future<Table_order> getTableData() async {
    Table_order tables = new Table_order();
    var tabledata = await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    if (tabledata != null) {
      var table = json.decode(tabledata);
      tables = Table_order.fromJson(table);
      return tables;
    } else {
      return tables;
    }
  }

  Future<List<MSTCartdetails>> getcartDetails() async {
    List<MSTCartdetails> list =
        await localAPI.getCartItem(widget.currentCartID);
    return list;
  }

  Future<List<MSTSubCartdetails>> getmodifireList() async {
    List<MSTSubCartdetails> list =
        await localAPI.itemmodifireList(widget.currentCartID);
    return list;
  }

  printReceipt(int orderid) async {
    var branchID = await CommunFun.getbranchId();
    var treminalID = await CommunFun.getTeminalKey();
    Branch branchAddress = await localAPI.getbranchData();
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(orderid, treminalID);
    List<Payments> paymentMethod =
        await localAPI.getOrderpaymentmethod(orderid, treminalID);
    await localAPI.getPaymentUser(orderpaymentdata[0].op_by);
    List<OrderDetail> orderitem =
        await localAPI.getOrderDetailsList(orderid, treminalID);
    Orders order = await localAPI.getcurrentOrders(orderid, treminalID);
    List<OrderAttributes> attributes =
        await localAPI.getOrderAttributes(orderid);
    List<OrderModifire> modifires = await localAPI.getOrderModifire(orderid);

    if (widget.printerIP.isNotEmpty) {
      _printReceipt.checkReceiptPrint(
          widget.pax,
          widget.printerIP,
          context,
          branchAddress,
          taxJson,
          orderitem,
          attributes,
          modifires,
          order,
          orderpaymentdata,
          paymentMethod,
          "", // Add table name here
          "", // Add Currency here
          widget.customer.isEmpty ? "Walk-in customer" : widget.customer,
          false,
          true);
      clearSelected();
    } else {
      CommunFun.showToast(context, Strings.printerNotAvailable);
    }
  }
}
