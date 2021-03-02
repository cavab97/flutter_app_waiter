import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mcncashier/components/DrawerWidget.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/Category.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/OrderAttributes.dart';
import 'package:mcncashier/models/OrderDetails.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'package:mcncashier/models/Order_Modifire.dart';
import 'package:mcncashier/models/Payment.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/ProductStoreInventoryLog.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/models/ShiftInvoice.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/Voucher.dart';
import 'package:mcncashier/models/Voucher_History.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/CloseShiftPage.dart';
import 'package:mcncashier/screens/DiscountPad.dart';
import 'package:mcncashier/screens/OpningAmountPop.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/screens/ChangeQtyDailog.dart';
import 'package:mcncashier/screens/SetQuantityPad.dart';
import 'package:mcncashier/screens/SplitOrder.dart';
import 'package:mcncashier/screens/VoucherPop.dart';
import 'package:mcncashier/screens/ReprintPopup.dart';
import 'package:mcncashier/screens/payment/PaymentAlertDialog.dart';
import 'package:mcncashier/screens/shift/Closing.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:expandable/expandable.dart';
import '../components/communText.dart';
import '../components/communText.dart';
import '../models/MST_Cart_Details.dart';
import '../models/ProductStoreInventoryLog.dart';
import '../models/Product_Store_Inventory.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/services/allTablesSync.dart';

import '../services/LocalAPIs.dart';

class DashboradPage extends StatefulWidget {
  // main Product list page
  DashboradPage({Key key}) : super(key: key);

  @override
  _DashboradPageState createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  TabController _secondTabController;
  TabController _subtabController;
  var _textController = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey;
  LocalAPI localAPI = LocalAPI();
  PrintReceipt printKOT = PrintReceipt();
  List<Category> allCaterories = new List<Category>();
  List<Category> tabsList = new List<Category>();
  List<Printer> printerList = new List<Printer>();
  List<Printer> printerreceiptList = new List<Printer>();
  List<Category> subCatList = new List<Category>();
  List<ProductDetails> productList = new List<ProductDetails>();
  List<ProductDetails> searchProductList = new List<ProductDetails>();
  List<MSTCartdetails> cartList = new List<MSTCartdetails>();
  List<SetMeal> mealsList = new List<SetMeal>();
  List<Payments> paymentTypeList = [];
  SlidableController slidableController = SlidableController();
  List<BranchTax> taxlist = [];
  MSTCartdetails focusCart = new MSTCartdetails();
  double taxvalues = 0.00;
  bool isDrawerOpen = false;
  bool isShiftOpen = true;
  var userDetails;
  bool isTableSelected = false;
  Branch branchData;
  Table_order selectedTable;
  double subtotal = 0;
  double serviceCharge = 0;
  double serviceChargePer = 0;
  Customer customer;
  String tableName = "";
  bool isWebOrder = false;
  double discount = 0;
  double tax = 0;
  List taxJson = [];
  double grandTotal = 0;
  MST_Cart allcartData = new MST_Cart();
  Voucher selectedvoucher;
  int currentCartID;
  bool isLoading = false;
  User checkInUser;
  var permissions = "";
  var currency = "RM";
  bool isScreenLoad = false;
  Timer timer;
  List quantity = [2, 3, 4, 5, 6, 7, 8, 9];
  List categoryFirstRow = [];
  List categorySecondRow = [];
  List<MSTCartdetails> originalCartList = [];
  var selectedCategory;
  var expandableController;
  int currentQuantity = 0;
  double currentProductQuantity = 0.0;
  MSTCartdetails itemSelected = new MSTCartdetails();
  bool isInit = true;
  String cartListTemp;
  bool isCounting = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isScreenLoad = true;
    });
    checkisInit();
    checkISlogin();
  }

  refreshAfterAction(bool isClearCart) {
    if (isClearCart) {
      clearCart();
    }
    checkidTableSelected();
    checkCustomerSelected();
  }

  checkISlogin() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (loginUser == null) {
      Navigator.pushNamed(context, Constant.PINScreen);
    } else {
      User userdata = User.fromJson(json.decode(loginUser));
      setState(() {
        checkInUser = userdata;
      });
    }
  }

  checkisInit() async {
    await setPermissons();
    //bool databaseExist = await CommunFun.checkDatabaseExit();
    // if (databaseExist == true) {
      await getCategoryList();
      //await checkidTableSelected();
      await getAllPrinter();
    // } else {
    //   await databaseHelper.initializeDatabase();
    //   await getCategoryList();
    //   //await checkidTableSelected();
    // }

    var curre = 'RM'; //await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
    await checkshift();
    await checkidTableSelected();
    setState(() {
      isScreenLoad = false;
    });
    await getUserData();
    await setPermissons();
    await getTaxs();
    await getbranch();
    await getPaymentMethods();

    _textController.addListener(() {
      getSearchList(_textController.text.toString());
    });

    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  getPaymentMethods() async {
    var result = await localAPI.getPaymentMethods();
    List<Payments> mainPaymentList =
        result.where((i) => i.isParent == 0).toList();

    if (result.length != 0) {
      setState(() {
        paymentTypeList = mainPaymentList;
      });
    }
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  checkCustomerSelected() async {
    Customer customerData = await CommunFun.getCustomer();
    setState(() {
      customer = customerData;
    });
  }

  checkidTableSelected() async {
    var constantTableData =
        await Preferences.getStringValuesSF(Constant.TABLE_DATA);
    var branchid = await CommunFun.getbranchId();
    if (constantTableData != null) {
      var tableddata = json.decode(constantTableData);
      Table_order table = Table_order.fromJson(tableddata);
      List<TablesDetails> tabledata =
          await localAPI.getTableData(table.table_id);
      table.save_order_id = tabledata[0].saveorderid;

      setState(() {
        isTableSelected = true;
        selectedTable = table;
        tableName = tabledata[0].tableName;
      });
      if (selectedTable.save_order_id != null &&
          selectedTable.save_order_id != 0) {
        getCurrentCart();
      }
    } else {
      if (Navigator.canPop(context)) {
        Navigator.popAndPushNamed(context, Constant.SelectTableScreen,
            arguments: {"isAssign": false});
      }
    }
  }

  clearCart() {
    setState(() {
      cartList = [];
      selectedTable = null;
      grandTotal = 0.0;
      isWebOrder = false;
      discount = 0.0;
      tax = 0.0;
      subtotal = 0.0;
      serviceCharge = 0.0;
      serviceChargePer = 0;
      isTableSelected = false;
      currentCartID = null;
      allcartData = null;
    });
  }

  getCurrentCart() async {
    List<SaveOrder> currentOrder =
        await localAPI.getSaveOrder(selectedTable.save_order_id);
    if (currentOrder.length != 0 && this.mounted) {
      setState(() {
        currentCartID = currentOrder[0].cartId;
      });
      if (isShiftOpen) {
        await getCartItem(currentCartID);
      }
    }
  }

  checkshift() async {
    var isOpen = await localAPI.getShift();
    setState(() {
      isShiftOpen = isOpen ?? false;
    });
  }

  getCartItem(int cartId) async {
    List<MSTCartdetails> cartItems = await localAPI.getCartItem(cartId);
    if (cartItems.length > 0 && this.mounted) {
      setState(() {
        cartList = cartItems;
      });
      return await countTotals(cartId);
    }
  }

  countTotals(int cartId) async {
    setState(() {
      isCounting = true;
    });
    MST_Cart cart = await localAPI.getCartData(cartId);
    List<MSTCartdetails> cartdetails = await localAPI.getCartItem(cartId);
    if (cart.id == null) {
      cart.id = cartId;
      checkidTableSelected();
      return;
    }
    double currentSubtotal = 0.00;
    double itemDiscount = 0.00;
    Voucher vaocher;
    if (cart.voucher_id != null && cart.voucher_id != 0) {
      var voucherdetail = jsonDecode(cart.voucher_detail);
      vaocher = Voucher.fromJson(voucherdetail);
    }

    cartdetails.forEach((cartdetail) {
      if (isInit) originalCartList.add(cartdetail);
      if (cartdetail.isFocProduct != 1) {
        currentSubtotal += cartdetail.productDetailAmount != null &&
                cartdetail.productDetailAmount != 0.00
            ? cartdetail.productDetailAmount
            : cartdetail.productPrice;
        if (cart.voucher_id != null) {
          if (cart.voucher_id > 0 && cartdetail.discountType == 1) {
            double originalPrice = cartdetail.productDetailAmount;
            // (1 - (cartdetail.discountAmount / 100));
            itemDiscount += originalPrice * (cartdetail.discountAmount / 100);
          } else if (cart.voucher_id > 0) {
            itemDiscount += cartdetail.discountAmount;
          }
        }
      }
    });

    cart.sub_total = currentSubtotal;
    cart.serviceCharge = 0.00;
    if (cart.serviceChargePercent != null) {
      cart.serviceCharge = currentSubtotal * (cart.serviceChargePercent / 100);
    }
    double taxval = 0.00;
    for (BranchTax tax in taxlist) {
      taxval += tax.rate != null
          ? currentSubtotal * (double.tryParse(tax.rate) / 100)
          : 0.00;
    }
    cart.tax = taxval;
    if (this.mounted) {
      setState(() {
        allcartData = cart;
        subtotal = cart.sub_total;
        serviceCharge = cart.serviceCharge == null ? 0.00 : cart.serviceCharge;
        serviceChargePer =
            cart.serviceChargePercent == null ? 0 : cart.serviceChargePercent;
        if (cart.voucher_id != null &&
            cart.voucher_id > 0 &&
            itemDiscount > 0) {
          discount = itemDiscount;
        } else if (cart.discountType == 1) {
          discount = (currentSubtotal * (cart.discountAmount / 100));
        } else {
          discount = cart.discountAmount;
        }
        tax = cart.tax;
        isWebOrder = cart.source == 1 ? true : false;
        grandTotal =
            (subtotal - discount) + tax + serviceCharge; //cart.grand_total;
        selectedvoucher = vaocher;
        if (isInit) isInit = false;
        isCounting = false;
      });
    }
    cart.grand_total = grandTotal;
    cart.grand_total = double.tryParse(
        await CommunFun.checkRoundData(grandTotal.toStringAsFixed(2)));
    await localAPI.updateWebCart(cart);
    return cart;
  }

  removeCutomer() async {
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    setState(() {
      customer = null;
    });
  }

  getUserData() async {
    var user = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    if (user != null) {
      user = json.decode(user);
      setState(() {
        userDetails = user;
      });
    }
  }

  closeTable() async {
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    checkidTableSelected();
    clearCart();
  }

  closeShift() {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return ClosingPage(onClose: () {
            printKOT.testReceiptPrint(
                printerreceiptList[0].printerIp.toString(),
                context,
                "",
                Strings.openDrawer,
                true);
            openOpningAmmountPop(Strings.titleClosingAmount);
          });
        });
  }

  draftreciptPrint() async {
    if (cartList.length > 0) {
      if (printerreceiptList.length > 0) {
        if (permissions.contains(Constant.PRINT_BILL)) {
          printKOT.checkDraftPrint(
              taxJson,
              printerreceiptList[0].printerIp.toString(),
              context,
              cartList,
              tableName,
              subtotal,
              serviceChargePer,
              serviceCharge,
              grandTotal,
              tax,
              branchData,
              currency,
              selectedTable.number_of_pax.toString(),
              customer != null ? customer.name : Strings.walkinCustomer);
        } else {
          await SyncAPICalls.logActivity("print draft receipt",
              "Cashier has no permission for print draft receipt", "Order", 1);
          await CommonUtils.openPermissionPop(context, Constant.PRINT_BILL,
              () async {
            printKOT.checkDraftPrint(
                taxJson,
                printerreceiptList[0].printerIp.toString(),
                context,
                cartList,
                tableName,
                subtotal,
                serviceChargePer,
                serviceCharge,
                grandTotal,
                tax,
                branchData,
                currency,
                selectedTable.number_of_pax.toString(),
                customer != null ? customer.name : Strings.walkinCustomer);
            await SyncAPICalls.logActivity("print draft receipt",
                "Manager given permission for print draft receipt", "Order", 1);
          }, () {});
        }
      } else {
        CommunFun.showToast(context, Strings.printerNotAvailable);
      }
    } else {
      CommunFun.showToast(context, Strings.cartEmpty);
    }
  }

  deleteCurrentCart() async {
    // Delete current order
    Table_order tables = await getTableData();
    await localAPI.clearCartItem(currentCartID, tables.table_id);

    await refreshAfterAction(true);
  }

  Future<void> selectOption(choice) async {
    // Causes the app to rebuild with the new _selectedChoice.
    switch (choice) {
      case 0:
        //selectTable();
        SyncAPICalls.logActivity(
            "menu", "clicked add customer menu item", "menu", 1);
        openShowAddCustomerDailog();
        break;
      case 1:
        if (permissions.contains(Constant.CLOSE_TABLE)) {
          SyncAPICalls.logActivity(
              "menu", "clicked closed table menu item", "menu", 1);
          if (cartList.length > 0) {
            closeTable();
          } else {
            selectTable();
          }
        } else {
          SyncAPICalls.logActivity("Close Table",
              "Cashier has no permission for close table", "Product", 1);
          await CommonUtils.openPermissionPop(context, Constant.CLOSE_TABLE,
              () async {
            SyncAPICalls.logActivity("Close Table",
                "Manager given permission for close table", "Product", 1);
            if (cartList.length > 0) {
              closeTable();
            } else {
              selectTable();
            }
          }, () {});
        }

        break;
      case 2:
        SyncAPICalls.logActivity(
            "menu", "clicked split order menu item", "menu", 1);
        await showDialog(
            // Opning Ammount Popup
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return SplitBillDialog(
                onSelectedRemove: (MSTCartdetails cart) {
                  itememovefromCart(cart);
                },
                onClose: (String isFor) {
                  Navigator.of(context).pop();
                  if (isFor == "clear") {
                    clearCart();
                  }
                },
                currentCartID: currentCartID,
                pax: selectedTable.number_of_pax.toString(),
                customer: customer != null ? customer.name : "",
                printerIP: printerreceiptList.length > 0
                    ? printerreceiptList[0].printerIp
                    : "",
              );
            });
        break;
      case 3:
        SyncAPICalls.logActivity(
            "menu", "clicked close shift menu item", "menu", 1);
        if (permissions.contains(Constant.CLOSING)) {
          closeShift();
        } else {
          SyncAPICalls.logActivity("Close shift",
              "Cashier has no permission for close store", "shift", 1);
          await CommonUtils.openPermissionPop(context, Constant.CLOSING,
              () async {
            SyncAPICalls.logActivity("Close shift",
                "Manager given permission for close store", "shift", 1);
            await closeShift();
          }, () {});
        }
        break;
      case 4:
        SyncAPICalls.logActivity(
            "menu", "clicked delete order menu item", "menu", 1);
        if (permissions.contains(Constant.DELETE_ORDER)) {
          deleteCurrentCart();
        } else {
          SyncAPICalls.logActivity(
              "Delete table Order",
              "Cashier has no permission for delete order from table",
              "Order",
              1);
          await CommonUtils.openPermissionPop(context, Constant.DELETE_ORDER,
              () async {
            deleteCurrentCart();
            SyncAPICalls.logActivity(
                "Deletetable Order",
                "Manager given permission for delete order from table",
                "Order",
                1);
          }, () {});
        }
        break;
      case 5:
        SyncAPICalls.logActivity(
            "menu", "clicked apply promocode menu item", "menu", 1);
        changePromoCode();
        break;
      case 6:
        SyncAPICalls.logActivity(
            "menu", "clicked apply total bill discount", "menu", 1);
        applyDiscount();
        break;
    }
  }

  applyDiscount([Function callback]) async {
    if (this.mounted) {
      setState(() {
        itemSelected = new MSTCartdetails();
      });
    }
    showDialog(
      // Opning Ammount Popup
      context: context,
      builder: (BuildContext context) {
        return DiscountPad(
          selectedProduct: null,
          issetMeal: false,
          cartID: currentCartID,
          onClose: () async {
            if (callback != null) {
              /* MST_Cart cart = await localAPI.getCartData(currentCartID);
              print(cart.grand_total); */
              callback(await getCartItem(currentCartID));
            } else {
              getCartItem(currentCartID);
            }
          },
          discard: callback,
        );
      },
    );
  }

  changePromoCode() async {
    if (selectedvoucher != null) {
      CommonUtils.showAlertDialog(context, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop();
        removePromoCode(selectedvoucher);
        setState(() {
          selectedvoucher = null;
        });
      }, "Alert", "Are you sure you want to remove this promocode?", "Yes",
          "No", true);
    } else {
      if (permissions.contains(Constant.DISCOUNT_ORDER)) {
        openVoucherPop();
      } else {
        CommonUtils.openPermissionPop(context, Constant.DISCOUNT_ORDER, () {
          openVoucherPop();
        }, () {});
      }
    }
  }

  resendToKitchen() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ReprintKitchenPirntPop(
              cartList: cartList,
              onClose: (resendList) async {
                if (resendList.length > 0 && printerreceiptList.length > 0) {
                  Navigator.of(context).pop();
                  if (permissions.contains(Constant.REPRINT_KITECHEN)) {
                    openPrinterPop(resendList, true);
                  } else {
                    await SyncAPICalls.logActivity(
                        "Reprint Kitchen print",
                        "Cashier has no permission for reprint kitchen print",
                        "Order",
                        1);
                    await CommonUtils.openPermissionPop(
                        context, Constant.REPRINT_KITECHEN, () async {
                      await openPrinterPop(resendList, true);
                      await SyncAPICalls.logActivity(
                          "Repritn Kitchen print",
                          "Manager given permission for reprint kitchen print",
                          "Order",
                          1);
                    }, () {});
                  }
                } else {
                  CommunFun.showToast(context, Strings.printerNotAvailable);
                }
              });
        });
  }

  printCheckList() async {
    if (cartList.length > 0) {
      if (printerreceiptList.length > 0) {
        if (permissions.contains(Constant.PRINT_CHECKLIST)) {
          printKOT.checkListReceiptPrint(
              printerreceiptList[0].printerIp.toString(),
              context,
              cartList,
              tableName,
              branchData,
              selectedTable.number_of_pax.toString(),
              customer != null ? customer.name : Strings.walkinCustomer);
        } else {
          await SyncAPICalls.logActivity("check list print",
              "Cashier has no permission for print check list", "Order", 1);
          await CommonUtils.openPermissionPop(context, Constant.PRINT_CHECKLIST,
              () async {
            printKOT.checkListReceiptPrint(
                printerreceiptList[0].printerIp.toString(),
                context,
                cartList,
                tableName,
                branchData,
                selectedTable.number_of_pax.toString(),
                customer != null ? customer.name : Strings.walkinCustomer);
            await SyncAPICalls.logActivity("check list print",
                "Manager given permission for print check list", "Order", 1);
          }, () {});
        }
      } else {
        CommunFun.showToast(context, Strings.printerNotAvailable);
      }
    } else {
      CommunFun.showToast(context, Strings.cartEmpty);
    }
  }

/*this function used for remove promocode from cart*/
  removePromoCode(Voucher voucher, [Function callback]) async {
    //List<MSTCartdetails> cartListUpdate = [];
    //Voucher voucher = Voucher.fromJson(voucherdata);
    for (int i = 0; i < cartList.length; i++) {
      var cartitem = cartList[i];
      cartitem.discountAmount = 0.0;
      cartitem.discountType = 0;
      await localAPI.addVoucherIndetail(cartitem, voucher.voucherId);
    }
    allcartData.grand_total =
        allcartData.grand_total + allcartData.discountAmount;
    allcartData.voucher_detail = "";
    allcartData.discountRemark =
        allcartData.discountRemark.replaceAll(voucher.voucherName, '');
    allcartData.discountAmount = 0.0;
    allcartData.discountType = 0;
    allcartData.voucher_id = null;
    callback(allcartData);
    await localAPI.addVoucherInOrder(allcartData, voucher);
    await countTotals(currentCartID);
    await SyncAPICalls.logActivity("promocode",
        "Cashier Removed promocode form order", "voucher", voucher.voucherId);
  }

  getCategoryList() async {
    List<Category> categorys = await localAPI.getAllCategory();
    List<Category> catList = categorys.where((i) => i.parentId == 0).toList();
    if (this.mounted) {
      setState(() {
        tabsList = catList;
        allCaterories = categorys;
      });
    }

    for (var i = 0; i < tabsList.length; i++) {
      if (i % 2 == 0) {
        categoryFirstRow.add(tabsList[i]);
      } else {
        categorySecondRow.add(tabsList[i]);
      }
    }

    _tabController =
        TabController(vsync: this, length: categoryFirstRow.length);
    _secondTabController =
        TabController(vsync: this, length: categorySecondRow.length);
    _tabController.addListener(_handleTabSelection);
    _secondTabController.addListener(_handleSecondTabSelection);

    if (tabsList[0].isSetmeal == 1) {
      getMeals();
    } else {
      getProductList(tabsList[0].categoryId);
    }
  }

  getMeals() async {
    var branchid = await CommunFun.getbranchId();
    List<SetMeal> setmeals = await localAPI.getMealsData(branchid);
    setState(() {
      mealsList = setmeals;
      productList = [];
    });
  }

  getAllPrinter() async {
    List<Printer> printer = await localAPI.getAllPrinterForKOT();
    List<Printer> printerDraft = await localAPI.getAllPrinterForecipt();
    if (this.mounted) {
      setState(() {
        printerList = printer;
        printerreceiptList = printerDraft;
      });
    }
  }

  _backtoMainCat() {
    setState(() {
      subCatList = [];
    });
    var cat = tabsList[_tabController.index].categoryId;
    if (tabsList[_tabController.index].isSetmeal == 1) {
      getMeals();
    }
    //  else {
    //   getProductList(cat);
    // }
  }

  getProductList(categoryId) async {
    setState(() {
      isLoading = true;
    });
    var branchid = await CommunFun.getbranchId();

    List<ProductDetails> product =
        await localAPI.getProduct(categoryId.toString());
    if (product.length > 0) {
      setState(() {
        // productList = [];
        productList = product;
        isLoading = false;
        mealsList = [];
      });
    } else {
      setState(() {
        productList = [];
        isLoading = false;
        mealsList = [];
      });
    }
  }

  getSearchList(seachText) async {
    if (seachText != "") {
      var branchid = await CommunFun.getbranchId();
      List<ProductDetails> product =
          await localAPI.getSeachProduct(seachText.toString(), branchid);
      List<SetMeal> setMeal =
          await localAPI.getSearchSetMealsData(seachText.toString(), branchid);

      setMeal.forEach((element) {
        ProductDetails cartItemproduct = new ProductDetails();
        cartItemproduct.price = double.parse(element.price.toStringAsFixed(2));
        cartItemproduct.status = element.status;
        cartItemproduct.productId = element.setmealId;
        cartItemproduct.base64 = element.base64;
        cartItemproduct.name = element.name;
        cartItemproduct.uuid = element.uuid;
        cartItemproduct.isSetMeal = true;
        product.add(cartItemproduct);
      });
      setState(() {
        searchProductList = product.length > 0 ? product : [];
      });
    } else {
      setState(() {
        searchProductList = [];
      });
    }
  }

  Future<void> _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      var cat = categoryFirstRow[_tabController.index].categoryId;
      List<Category> subList =
          allCaterories.where((i) => i.parentId == cat).toList();
      setState(() {
        subCatList = subList;
      });
      _subtabController =
          new TabController(vsync: this, length: subCatList.length);
      _subtabController.addListener(_handleSubTabSelection);
      if (subCatList.length > 0) {
        cat = subCatList[_subtabController.index].categoryId;
      }
      if (categoryFirstRow[_tabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
    }
    await SyncAPICalls.logActivity(
        "select category", "Changed category", "changed category", 1);
  }

  Future<void> _handleSecondTabSelection() async {
    if (_secondTabController.indexIsChanging) {
      var cat = categorySecondRow[_secondTabController.index].categoryId;
      List<Category> subList =
          allCaterories.where((i) => i.parentId == cat).toList();
      setState(() {
        subCatList = subList;
      });
      _subtabController =
          new TabController(vsync: this, length: subCatList.length);
      _subtabController.addListener(_handleSubTabSelection);
      if (subCatList.length > 0) {
        cat = subCatList[_subtabController.index].categoryId;
      }
      if (categorySecondRow[_secondTabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
    }
  }

  Future<void> _handleSubTabSelection() async {
    if (_subtabController.indexIsChanging) {
      var cat = subCatList[_subtabController.index].categoryId;
      if (subCatList[_subtabController.index].isSetmeal == 1) {
        getMeals();
      } else {
        getProductList(cat);
      }
      await SyncAPICalls.logActivity("select sub category",
          "Changed sub category", "changed sub category", 1);
    }
  }

  void _selectedCategory(int index, String row) {
    var selected =
        row == 'first' ? categoryFirstRow[index] : categorySecondRow[index];
    setState(() {
      selectedCategory = selected;
    });
    if ((row == 'first'
            ? categoryFirstRow[index].isSetmeal
            : categorySecondRow[index].isSetmeal) ==
        1) {
      getMeals();
    } else {
      getProductList(row == 'first'
          ? categoryFirstRow[index].categoryId
          : categorySecondRow[index].categoryId);
    }
  }

  Future<void> _selectedQuantity(int quantity) async {
    setState(() {
      currentQuantity = quantity;
    });
    await SyncAPICalls.logActivity(
        "quantity", "Clicked current quantity", "quantity", 1);
  }

  @override
  void dispose() {
    if (_tabController != null) _tabController.dispose();
    if (_secondTabController != null) _secondTabController.dispose();
    super.dispose();
  }

  openOpningAmmountPop(isopning) {
    showDialog(
        // Opning Ammount Popup
        context: context,
        builder: (BuildContext context) {
          return OpeningAmmountPage(
              ammountext: isopning,
              onEnter: (ammountext) {
                if (isopning == Strings.titleOpeningAmount) {
                  if (printerreceiptList.length > 0) {
                    printKOT.testReceiptPrint(
                        printerreceiptList[0].printerIp.toString(),
                        context,
                        "",
                        Strings.openDrawer,
                        true);
                  } else {
                    CommunFun.showToast(context, Strings.printerNotAvailable);
                  }
                }
                sendOpenShft(ammountext);
              });
        });
  }

  openVoucherPop([Function onCloseFunction]) {
    showDialog(
      // Opning Ammount Popup
      context: context,
      builder: (BuildContext context) {
        return VoucherPop(
          cartList: cartList,
          cartData: allcartData,
          cartId: currentCartID,
          taxlist: taxlist,
          onEnter: (voucher) {
            if (voucher != null) {
              setState(() {
                selectedvoucher = voucher;
              });
            }
            getCartItem(currentCartID);
          },
          onClose: onCloseFunction,
        );
      },
    );
  }

/*This method used for print KOT receipt print*/
  openPrinterPop(cartLists, isReprint) {
    for (int i = 0; i < printerList.length; i++) {
      List<MSTCartdetails> tempCart = new List<MSTCartdetails>();
      tempCart.clear();
      for (int j = 0; j < cartLists.length; j++) {
        MSTCartdetails temp = MSTCartdetails();

        if (printerList[i].printerId == cartLists[j].printer_id) {
          temp = cartLists[j];
          tempCart.add(temp);
        }
      }
      if (tempCart.length > 0) {
        printKOT.checkKOTPrint(
            printerList[i].printerIp.toString(),
            tableName,
            context,
            tempCart,
            selectedTable.number_of_pax.toString(),
            isReprint);
      }
    }
  }

  sendTokitched(itemList) async {
    String ids = "";
    var list = [];
    for (var i = 0; i < itemList.length; i++) {
      if (itemList[i].isSendKichen == null || itemList[i].isSendKichen == 0) {
        if (ids == "") {
          ids = itemList[i].id.toString();
        } else {
          ids = ids + "," + itemList[i].id.toString();
        }
        list.add(itemList[i]);
      }
      if (i == itemList.length - 1) {
        if (list.length > 0) {
          await openPrinterPop(list, false);
          await localAPI.sendToKitched(ids);
          await getCartItem(currentCartID);
        }
        return false;
      }
    }
  }

  sendPayment() async {
    if (cartList.length != 0) {
      if (permissions.contains(Constant.PAYMENT)) {
        openPaymentMethod();
        //openPaymentMethod();
      } else {
        await SyncAPICalls.logActivity("Order Payment",
            "Cashier has no permission for make payment", "Order", 1);
        await CommonUtils.openPermissionPop(context, Constant.PAYMENT,
            () async {
          await openPaymentMethod();
          await SyncAPICalls.logActivity("Order Payment",
              "Manager given permission for make payment", "Order", 1);
        }, () {});
      }
    } else {
      CommunFun.showToast(context, Strings.cartEmpty);
    }
  }

  checkoutWebOrder() async {
    if (cartList.length != 0) {
      await CommunFun.processingPopup(context);
      List<OrderPayment> payment = [];
      sendPaymentByCash(payment);
    } else {
      CommunFun.showToast(context, Strings.cartEmpty);
    }
  }

  sendOpenShft(ammount) async {
    setState(() {
      isShiftOpen = true;
    });
    Preferences.setStringToSF(Constant.IS_SHIFT_OPEN, isShiftOpen.toString());
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    User userdata = await CommunFun.getuserDetails();
    Shift shift = new Shift();
    int appid = await localAPI.getLastShiftAppID(terminalId);
    if (shiftid == null && appid != 0) {
      shift.appId = appid + 1;
    } else {
      shift.appId = shiftid == null ? 1 : int.parse(shiftid);
    }
    shift.terminalId = int.parse(terminalId);
    shift.branchId = int.parse(branchid);
    shift.userId = userdata.id;
    shift.uuid = await CommunFun.getLocalID();
    shift.status = 1;
    shift.serverId = 0;
    if (shiftid == null) {
      shift.startAmount = double.parse(ammount);
      shift.updatedAt =
          shift.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    } else {
      shift.endAmount = double.parse(ammount);
      shift.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
    }
    shift.updatedBy = userdata.id;
    var result = await localAPI.insertShift(shift, shiftid);
    if (shiftid == null) {
      await Preferences.setStringToSF(Constant.DASH_SHIFT, result.toString());
    } else {
      await Preferences.removeSinglePref(Constant.DASH_SHIFT);
      await Preferences.removeSinglePref(Constant.IS_SHIFT_OPEN);
      await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
      checkshift();
    }
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false});
  }

  openDrawer() {
    scaffoldKey.currentState.openDrawer();
  }

  checkshiftopen(product) {
    if (isShiftOpen) {
      if (isTableSelected && !isWebOrder) {
        showQuantityDailog(product, false);
      } else if (!isWebOrder) {
        selectTable();
      }
    } else {
      CommunFun.showToast(context, Strings.shiftOpenMessage);
    }
  }

  showQuantityDailog(product, isSetMeal) async {
    if (originalCartList.length == 0 && isInit) {
      isInit = false;
    }
    var selectedProduct = product;
    if (!isSetMeal) {
      if (selectedProduct.isSetMeal != null) {
        isSetMeal = true;
        SetMeal cartItemproduct = new SetMeal();
        cartItemproduct.price =
            double.parse(selectedProduct.price.toStringAsFixed(2));
        cartItemproduct.status = selectedProduct.status;
        cartItemproduct.setmealId = selectedProduct.productId;
        cartItemproduct.base64 = selectedProduct.base64;
        cartItemproduct.name = selectedProduct.name;
        cartItemproduct.uuid = selectedProduct.uuid;
        selectedProduct = cartItemproduct;
      }
    }
    if (currentQuantity > 0) {
      selectedProduct.qty = currentQuantity.toDouble();
      if (this.mounted) {
        setState(() {
          currentQuantity = 0;
        });
      }
    }
    if (isSetMeal ||
        selectedProduct.attrCat != null ||
        selectedProduct.modifireName != null) {
      showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) {
            return ProductQuantityDailog(
                selproduct: selectedProduct,
                issetMeal: isSetMeal,
                cartID: currentCartID,
                onClose: () {
                  getCurrentCart();
                  refreshAfterAction(false);
                  //cartList.add(cartitem);
                });
          });
    } else {
      // Remove item loading
      /* setState(() {
        isScreenLoad = false;
      }); */
      await addTocartItem(selectedProduct);
    }
  }

  editCartItem(cart) async {
    var prod;
    if (cart.issetMeal == 0) {
      List<ProductDetails> productdt =
          await localAPI.productdData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    } else {
      List<SetMeal> productdt = await localAPI.setmealData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    }

    await showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return ProductQuantityDailog(
              selproduct: prod,
              issetMeal: cart.issetMeal == 1 ? true : false,
              cartID: currentCartID,
              cartItem: cart,
              onClose: () {
                getCurrentCart();
                refreshAfterAction(false);
              });
        });
    //     return false;
    //   }
    // }
  }

  addTocartItem(selectedProduct) async {
    await CommunFun.addItemToCart(
      selectedProduct,
      cartList,
      allcartData,
      (MSTCartdetails addedProduct) {
        if (selectedTable.save_order_id != null &&
            selectedTable.save_order_id != 0) {
          getCurrentCart();
        } else {
          checkidTableSelected();
        }
        setState(() {
          isScreenLoad = false;
        });
      },
      context,
    );
  }

  openShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchCustomerPage(
              onClose: () {
                //refreshAfterAction();
                checkCustomerSelected();
              },
              isFor: Constant.dashboard);
        });
  }

  openPaymentMethod() async {
    var roundingTotal =
        await CommunFun.checkRoundData(grandTotal.toStringAsFixed(2));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PaymentAlertDialog(
            totalAmount: double.tryParse(roundingTotal),
            selectedVoucher: selectedvoucher,
            voucherFunction: (Function onCloseFunction) =>
                openVoucherPop(onCloseFunction),
            removeVoucherFunction: removePromoCode,
            applyDiscount: applyDiscount,
            permissions: permissions,
            currentCartID: currentCartID,
            taxlists: taxlist,
            onClose: (bool isContinue, List<OrderPayment> mehtod) {
              if (isContinue) {
                countTotals(currentCartID);
                openPaymentMethod();
              } else {
                CommunFun.processingPopup(context);
                paymentWithMethod(mehtod);
              }
            },
          );
        });
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

  Future<List<MSTSubCartdetails>> getmodifireList(detailid) async {
    List<MSTSubCartdetails> list = await localAPI.getItemModifire(detailid);
    return list;
  }

  Future<List<MSTCartdetails>> getcartDetails(cartid) async {
    List<MSTCartdetails> list = await localAPI.getCartItem(currentCartID);
    return list;
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await localAPI.getbranchData();
    setState(() {
      branchData = branch;
    });
    return branch;
  }

  getcartData() async {
    var cartDatalist = await localAPI.getCartData(currentCartID);
    return cartDatalist;
  }

  paymentWithMethod(mehtod) async {
    sendPaymentByCash(mehtod);
  }

  sendPaymentByCash(List<OrderPayment> payment) async {
    MST_Cart cartData = await getcartData();
    if (cartData.id == null) {
      await clearCartAfterSuccess(0);
      return;
    }
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    Orders order = new Orders();
    /* VoucherHistory history = new VoucherHistory();
    List<OrderModifire> orderModifires = new List<OrderModifire>();
    List<OrderPayment> orderPaymentList = new List<OrderPayment>();
    ShiftInvoice shiftinvoice = new ShiftInvoice(); */
    List<OrderAttributes> orderAttributes = new List<OrderAttributes>();
    Table_order tables = await getTableData();
    User userdata = await CommunFun.getuserDetails();
    List<MSTCartdetails> cartList = await getcartDetails(currentCartID);
    sendTokitched(cartList);
    var terminalId = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    var uuid = await CommunFun.getLocalID();
    List<Orders> lastappid = await localAPI.getLastOrderAppid(terminalId);
    int length = branchData.invoiceStart.length;
    var invoiceNo;
    order.app_id = await SyncAPICalls.getOrderId(context);
    if (order.app_id != null) {
    } else if (lastappid.length > 0) {
      order.app_id = lastappid[0].app_id + 1;
      Preferences.setStringToSF(Constant.lastOrderId, order.app_id.toString());
    } else {
      order.app_id = 1;
      Preferences.setStringToSF(Constant.lastOrderId, 1.toString());
    }
    invoiceNo = branchData.orderPrefix +
        order.app_id.toString().padLeft(
            order.app_id.toString().length < 5
                ? 5 - order.app_id.toString().length
                : 1,
            "0");
    grandTotal = (subtotal - discount) + tax + serviceCharge;
    var convertGrand = await CommunFun.checkRoundData(
        (cartData.grand_total ?? 0).toStringAsFixed(2));
    double newGtotal = double.parse(convertGrand);
    var roundingVal = await CommunFun.calRounded(newGtotal, grandTotal);
    double rounding = double.parse(roundingVal.toStringAsFixed(2));
    order.uuid = uuid;
    order.branch_id = int.parse(branchid);
    order.terminal_id = int.parse(terminalId);
    order.table_id = tables.table_id;
    order.invoice_no = invoiceNo;
    order.customer_id = cartData.user_id;
    order.sub_total = cartData.sub_total;
    order.serviceCharge = cartData.serviceCharge;
    order.serviceChargePercent = cartData.serviceChargePercent;
    order.sub_total_after_discount = cartData.sub_total;
    order.grand_total = newGtotal;
    order.rounding_amount = rounding;
    order.order_item_count = cartData.total_qty.toInt();
    order.tax_amount = cartData.tax;
    order.tax_json = cartData.tax_json;
    order.order_date = await CommunFun.getCurrentDateTime(DateTime.now());
    order.order_status = 4;
    order.server_id = 0;
    order.isSync = 0;
    order.pax = selectedTable.number_of_pax;
    order.order_source = cartData.source;
    order.order_by = userdata.id;
    order.voucher_detail = cartData.voucher_detail;
    order.voucher_id = cartData.voucher_id;
    order.voucher_amount = cartData.discountAmount;
    order.updated_at = await CommunFun.getCurrentDateTime(DateTime.now());
    order.updated_by = userdata.id;
    int orderId = await localAPI.placeOrder(order);
    List<OrderDetail> detaislist = [];
    if (cartData.voucher_id != 0 && cartData.voucher_id != null) {
      int lastappid = await localAPI.getLastVoucherHistoryid(terminalId);
      VoucherHistory history = new VoucherHistory();
      if (lastappid != 0) {
        history.app_id = lastappid + 1;
      } else {
        history.app_id = 1;
      }
      history.voucher_id = cartData.voucher_id;
      history.amount = cartData.discountAmount;
      history.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
      history.app_order_id = orderId;
      history.uuid = uuid;
      history.server_id = 0;
      history.terminal_id = int.parse(terminalId);
      history.user_id = userdata.id;
      await localAPI.saveVoucherHistory(history);
    }
    var orderDetailid;
    if (orderId > 0) {
      if (cartList.length > 0) {
        List<ProductStoreInventory> updatedInt = [];
        List<ProductStoreInventoryLog> updatedLog = [];
        for (var i = 0; i < cartList.length; i++) {
          OrderDetail orderDetail = new OrderDetail();
          var cartItem = cartList[i];
          var productdata = cartItem.cart_detail != null
              ? json.decode(cartItem.cart_detail)
              : "";
          List<ProductStoreInventory> cartval =
              await localAPI.checkItemAvailableinStore(cartItem.productId);
          if (productdata["has_inventory"] == 1 && cartval.length > 0) {
            double storeqty = cartval[0].qty;
            if (storeqty < cartItem.productQty) {
              CommunFun.showToast(
                  context,
                  productdata["name"] +
                      " Product is out of stock.Please check store.");
              await localAPI.deleteOrderid(orderId);
              Navigator.of(context).pop();
              return false;
            }
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
          orderDetail.product_old_price = cartItem.productNetPrice;
          orderDetail.detail_amount = cartItem.productDetailAmount;
          orderDetail.detail_qty = cartItem.productQty;
          orderDetail.product_discount = cartItem.discountAmount;
          orderDetail.product_detail = json.encode(productdata);
          orderDetail.updated_at =
              await CommunFun.getCurrentDateTime(DateTime.now());
          orderDetail.detail_datetime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          orderDetail.updated_by = userdata.id;
          orderDetail.detail_status = 1;
          orderDetail.isSync = 0;
          orderDetail.server_id = 0;
          orderDetail.detail_by = userdata.id;
          orderDetail.issetMeal = cartItem.issetMeal;
          orderDetail.hasRacManagemant = cartItem.hasRacManagemant;
          orderDetail.discountAmount = cartItem.discountAmount;
          orderDetail.discountType = cartItem.discountType;
          orderDetail.discountRemark = cartItem.discountRemark;
          if (cartItem.issetMeal == 1) {
            orderDetail.setmeal_product_detail =
                cartItem.setmeal_product_detail;
          }
          orderDetailid = await localAPI.sendOrderDetails(orderDetail);
          /*  if (orderDetailid != null) {
            detaislist.add(orderDetail);
            } */
          List<MSTSubCartdetails> modifireList =
              await getmodifireList(cartItem.id);
          if (modifireList.length > 0) {
            for (var i = 0; i < modifireList.length; i++) {
              OrderModifire modifireData = new OrderModifire();
              var modifire = modifireList[i];
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
                  attributes.app_id = int.parse(terminalId);
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
                orderAttributes.add(attributes);
                await localAPI.sendAttrData(attributes);
              }
            }
            if (cartItem.issetMeal == 0 || cartItem.hasRacManagemant == 0) {
              if (productdata["has_inventory"] == 1) {
                List<ProductStoreInventory> inventory = await localAPI
                    .getStoreInventoryData(orderDetail.product_id);
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
                  //Inventory log update
                  ProductStoreInventoryLog log = new ProductStoreInventoryLog();
                  log.uuid = uuid;
                  log.inventory_id = prev.inventoryId;
                  log.branch_id = int.parse(branchid);
                  log.product_id = cartItem.productId;
                  log.employe_id = userdata.id;
                  log.qty = prev.qty;
                  log.il_type = 2; //1 for add 2 for deduct
                  log.qty_before_change = prev.qty;
                  log.qty_after_change = qty;
                  log.updated_at =
                      await CommunFun.getCurrentDateTime(DateTime.now());
                  log.updated_by = userdata.id;
                  updatedLog.add(log);
                }
              }
            }
            if (cartItem.hasRacManagemant == 1) {
              insertRacInv(userdata, cartItem, cartData.user_id);
            }
          }
          var ulog = await localAPI.updateInvetory(updatedInt);
          var inventoryLog =
              await localAPI.updateStoreInvetoryLogTable(updatedLog);
        }
      }

      await localAPI.getOrderDetailsList(orderId, terminalId);
      if (payment.length > 0) {
        for (var i = 0; i < payment.length; i++) {
          OrderPayment orderpayment = payment[i];
          if (isWebOrder) {
            payment[i].op_method_id = cartData.cart_payment_id;
          }
          List<OrderPayment> lapPpid =
              await localAPI.getLastOrderPaymentAppid(terminalId);
          if (lapPpid.length > 0) {
            orderpayment.app_id = lapPpid[0].app_id + 1;
          } else {
            orderpayment.app_id = 1;
          }
          orderpayment.uuid = uuid;
          orderpayment.order_app_id = orderId;
          orderpayment.branch_id = int.parse(branchid);
          orderpayment.terminal_id = int.parse(terminalId);
          orderpayment.op_method_id = payment[i].op_method_id;
          orderpayment.remark = payment[i].remark;
          orderpayment.last_digits = payment[i].last_digits;
          orderpayment.reference_number = payment[i].reference_number;
          orderpayment.approval_code = payment[i].approval_code;
          orderpayment.isCash = payment[i].isCash ?? 0;
          orderpayment.op_amount = payment[i].op_amount.toDouble();
          orderpayment.op_amount_change = payment[i].op_amount_change;
          orderpayment.op_method_response = '';
          orderpayment.op_status = 1;
          /* orderpayment.is_split = 0;
          orderpayment.op_datetime =
              await CommunFun.getCurrentDateTime(DateTime.now()); */
          orderpayment.op_by = userdata.id;
          orderpayment.isSync = 0;
          orderpayment.server_id = 0;
          orderpayment.updated_by = userdata.id;
          orderpayment.op_datetime =
              await CommunFun.getCurrentDateTime(DateTime.now());
          orderpayment.updated_at =
              await CommunFun.getCurrentDateTime(DateTime.now());
          await localAPI.sendtoOrderPayment(orderpayment);
          if (payment[i].isCash == 1) {
            var shiftid =
                await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
            Drawerdata drawer = new Drawerdata();
            drawer.shiftId = int.parse(shiftid);
            drawer.amount = payment[i].op_amount;
            drawer.isAmountIn = 1;
            drawer.reason = "placeOrder";
            drawer.status = 1;
            drawer.createdBy = userdata.id;
            drawer.createdAt =
                await CommunFun.getCurrentDateTime(DateTime.now());
            drawer.localID = uuid;
            drawer.terminalid = int.parse(terminalId);
            await localAPI.saveInOutDrawerData(drawer);
          }
        }
      } else if (isWebOrder) {
        OrderPayment orderpayment = new OrderPayment();
        List<OrderPayment> lapPpid =
            await localAPI.getLastOrderPaymentAppid(terminalId);
        if (lapPpid.length > 0) {
          orderpayment.app_id = lapPpid[0].app_id + 1;
        } else {
          orderpayment.app_id = 1;
        }
        orderpayment.uuid = uuid;
        orderpayment.order_app_id = orderId;
        orderpayment.branch_id = int.parse(branchid);
        orderpayment.terminal_id = int.parse(terminalId);
        orderpayment.op_method_id = cartData.cart_payment_id;
        orderpayment.op_amount = cartData.grand_total;
        orderpayment.isCash = 0;
        orderpayment.op_status = 1;
        orderpayment.isSync = 0;
        orderpayment.server_id = 0;
        orderpayment.is_split = 0;
        orderpayment.op_datetime =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.op_by = userdata.id;
        orderpayment.updated_at =
            await CommunFun.getCurrentDateTime(DateTime.now());
        orderpayment.updated_by = userdata.id;
        await localAPI.sendtoOrderPayment(orderpayment);
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
      shiftinvoice.invoice_id = orderId;
      shiftinvoice.status = 1;
      shiftinvoice.created_by = userdata.id;
      shiftinvoice.created_at =
          await CommunFun.getCurrentDateTime(DateTime.now());
      shiftinvoice.serverId = 0;
      shiftinvoice.terminal_id = int.parse(terminalId);
      await localAPI.sendtoShiftInvoice(shiftinvoice);

      String isPausePrint =
          await Preferences.getStringValuesSF(Constant.isPausePrint);
      if (isPausePrint == null) {
        await printReceipt(orderId);
      } else {
        await clearCartAfterSuccess(orderId);
      }
    }
  }

  insertRacInv(user, cartItem, customer) async {
    Customer_Liquor_Inventory inventory = new Customer_Liquor_Inventory();
    var orderDateF;

    var appid = await localAPI.getLastCustomerInventory();
    if (appid != 0) {
      inventory.appId = appid + 1;
    } else {
      inventory.appId = 1;
    }
    var branchid = await CommunFun.getbranchId();
    var now = DateTime.now();
    var newDate = new DateTime(now.year, now.month + 1, now.day);
    orderDateF = DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate);
    List<Box> boxList = await localAPI.getBoxForProduct(cartItem.productId);
    if (boxList.length > 0) {
      inventory.uuid = await CommunFun.getLocalID();
      inventory.clCustomerId = customer;
      inventory.clProductId = cartItem.productId;
      inventory.clBranchId = int.parse(branchid);
      inventory.clRacId = boxList[0].racId;
      inventory.clBoxId = boxList[0].boxId;
      inventory.type = boxList[0].boxFor;
      inventory.clTotalQuantity = boxList[0].wineQty;
      inventory.clExpiredOn = orderDateF;
      inventory.clLeftQuantity = boxList[0].wineQty != null
          ? (boxList[0].wineQty - cartItem.productQty)
          : 0;
      inventory.status = 1;
      inventory.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
      inventory.updatedBy = user.id;
      await localAPI.insertWineInventory(inventory, false);
      Customer_Liquor_Inventory_Log log = new Customer_Liquor_Inventory_Log();
      var lastappid = await localAPI.getLastCustomerInventoryLog();
      if (lastappid != 0) {
        log.appId = lastappid + 1;
      } else {
        log.appId = 1;
      }
      log.uuid = await CommunFun.getLocalID();
      log.clAppId = inventory.appId;
      log.branchId = int.parse(branchid);
      log.productId = cartItem.productId;
      log.customerId = customer;
      log.liType = boxList[0].boxFor;
      log.qty = cartItem.productQty;
      log.qtyBeforeChange = boxList[0].wineQty;
      log.qtyAfterChange = boxList[0].wineQty != null
          ? (boxList[0].wineQty - cartItem.productQty)
          : 0;
      log.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
      log.updatedBy = user.id;
      await localAPI.insertWineInventoryLog(log);
    }
  }

  printReceipt(int orderid) async {
    var terminalid = await CommunFun.getTeminalKey();
    List<OrderPayment> orderpaymentdata =
        await localAPI.getOrderpaymentData(orderid, terminalid);
    List<Payments> paymentMethod =
        await localAPI.getOrderpaymentmethod(orderid, terminalid);
    List<OrderDetail> orderitem =
        await localAPI.getOrderDetailsList(orderid, terminalid);
    Orders order = await localAPI.getcurrentOrders(orderid, terminalid);
    List<OrderAttributes> attributes =
        await localAPI.getOrderAttributes(orderid);
    List<OrderModifire> modifires = await localAPI.getOrderModifire(orderid);

    Function asyncFunc = (currentContext) {
      printKOT.checkReceiptPrint(
          selectedTable.number_of_pax.toString(),
          printerreceiptList[0].printerIp,
          currentContext,
          branchData,
          taxJson,
          orderitem,
          attributes,
          modifires,
          order,
          orderpaymentdata,
          paymentMethod,
          tableName,
          currency,
          customer != null ? customer.name : Strings.walkinCustomer,
          false,
          true); //"  ? :"
    };
    //temporary print receipt, cannot print if no permission, pop out dirently close
    //asyncFunc();
    await clearCartAfterSuccess(orderid, asyncFunc);
  }

  clearCartAfterSuccess(orderid, [Function callback]) async {
    Table_order tables = await getTableData();
    await localAPI.removeCartItem(currentCartID, tables.table_id);
    await Preferences.removeSinglePref(Constant.TABLE_DATA);
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    await Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {"isAssign": false, "callbackFunction": callback});
  }

  getTaxs() async {
    // List<BranchTax> taxlist = [];
    var branchid = await CommunFun.getbranchId();
    List<BranchTax> taxlists = await localAPI.getTaxList();

    if (taxlists.length > 0) {
      setState(() {
        taxlist = taxlists;
      });
      taxlist = taxlists;
      //print(taxlist);
    }
    // return taxlist;
  }

  countTax(subT) async {
    await getTaxs();
    MST_Cart cart = new MST_Cart();
    var subtNServ = subT +
        await CommunFun.countServiceCharge(cart.serviceChargePercent, subT);
    var totalTax = [];
    double taxvalue = 0.00;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        var taxval = taxlistitem.rate != null
            ? subtNServ * double.parse(taxlistitem.rate) / 100
            : 0.0;
        taxval = double.parse(taxval.toStringAsFixed(2));
        taxvalue += taxval;
        setState(() {
          taxvalues = taxvalue;
        });
        var taxmap = {
          "id": taxlistitem.id,
          "tax_id": taxlistitem.taxId,
          "branch_id": taxlistitem.branchId,
          "rate": taxlistitem.rate,
          "status": taxlistitem.status,
          "updated_at": taxlistitem.updatedAt,
          "updated_by": taxlistitem.updatedBy,
          "taxAmount": taxval.toString(),
          "taxCode": taxlistitem.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  itememovefromCart(cartitem) async {
    try {
      MST_Cart cart = new MST_Cart();
      //bool isSetMeal = cartitem is SetMeal;
      MSTCartdetails cartitemdata = cartitem;
      var subt = allcartData.sub_total - cartitemdata.productPrice ??
          cartitemdata.productDetailAmount;
      var taxjson = await countTax(subt);
      var disc = allcartData.discountAmount != null
          ? allcartData.discountAmount - cartitemdata.discountAmount
          : 0;
      if (cartList.length == 1) {
        cart = allcartData;
        cart.sub_total = 0.0;
        cart.serviceCharge = 0.0;
        cart.discountAmount = 0.0;
        cart.total_qty = 0.0;
        cart.grand_total = 0.0;
        cart.tax_json = "";
        cart.voucher_id = 0;
        cart.voucher_detail = "";
      } else {
        cart = allcartData;
        cart.sub_total = subt;
        cart.discountAmount = disc;
        cart.serviceCharge =
            await CommunFun.countServiceCharge(cart.serviceChargePercent, subt);
        cart.total_qty = allcartData.total_qty - cartitemdata.productQty;
        cart.grand_total = (subt - disc) + taxvalues;
        cart.tax_json = json.encode(taxjson);
      }
      await localAPI.deleteCartItem(
          cartitem, currentCartID, cart, cartList.length == 1);
      if (cartitem.isSendKichen == 1) {
        var deletedlist = [];
        deletedlist.add(cartitem);
        if (permissions.contains(Constant.SEND_KITCHEN)) {
          openPrinterPop(deletedlist, false);
        } else {
          await SyncAPICalls.logActivity(
              "send to kitchen",
              "Cashier has no permission for send items to kitchen",
              "order",
              1);
          await CommonUtils.openPermissionPop(context, Constant.SEND_KITCHEN,
              () async {
            openPrinterPop(deletedlist, false);
            await SyncAPICalls.logActivity("send to kitchen",
                "Items to kitchen with manager permissions.", "voucher", 1);
          }, () {});
        }
      }
      if (cartList.length > 1) {
        await getCartItem(currentCartID);
      } else {
        if (this.mounted) {
          setState(() {
            cartList = [];
            grandTotal = 0.0;
            discount = 0.0;
            tax = 0.0;
            subtotal = 0.0;
            serviceCharge = 0.0;
            serviceChargePer = 0;
          });
        }
      }
      if (this.mounted) {
        setState(() {
          itemSelected = new MSTCartdetails();
        });
      }
    } catch (e) {
      CommunFun.showToast(context, e.message.toString());
    }
  }

  applyforFocProduct(cartitem) {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      openSelectQtyPop(cartitem);
    }, Strings.warning, Strings.warningMsg, Strings.yes, Strings.no, true);
  }

  openSelectQtyPop(cartitem) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChangeQtyDailog(
              type: null,
              qty: cartitem.productQty,
              onClose: (qty, remark) {
                Navigator.of(context).pop();
                splitproductfromItem(qty, cartitem, remark);

                countTotals(currentCartID);
              });
        });
  }

  splitproductfromItem(qty, MSTCartdetails cartitem, remark) async {
    MSTCartdetails focProduct = new MSTCartdetails();
    User userdata = await CommunFun.getuserDetails();
    bool isupdate = false;
    if (qty == cartitem.productQty) {
      isupdate = true;
      focProduct.id = cartitem.id;
    }
    focProduct.isFocProduct = 1;
    focProduct.cartId = cartitem.cartId;
    focProduct.productId = cartitem.productId;
    focProduct.productName = cartitem.productName;
    focProduct.productSecondName = cartitem.productSecondName;
    focProduct.productPrice = cartitem.productPrice;
    focProduct.productDetailAmount = 0.0;
    focProduct.productQty = qty;
    focProduct.productNetPrice = cartitem.productNetPrice;
    focProduct.createdBy = userdata.id;
    focProduct.cart_detail = cartitem.cart_detail;
    focProduct.discountAmount = 0.0;
    focProduct.remark = remark;
    focProduct.issetMeal = cartitem.issetMeal;
    focProduct.taxValue = 0.0;
    focProduct.printer_id = cartitem.printer_id;
    focProduct.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    focProduct.setmeal_product_detail = cartitem.setmeal_product_detail;
    var realprice = (cartitem.productDetailAmount / cartitem.productQty);
    var dis = (cartitem.discountAmount / cartitem.productQty);
    cartitem.productQty = cartitem.productQty - qty;
    cartitem.productDetailAmount = (realprice * cartitem.productQty);
    cartitem.discountAmount = (realprice * dis);
    MST_Cart cart = new MST_Cart();
    cart = allcartData;

    //here price no correct, checkpoint
    var subt = allcartData.sub_total - (realprice * qty);
    var taxjson = await countTax(subt);
    var disc = allcartData.discountAmount != null
        ? allcartData.discountAmount - (dis * qty)
        : 0;
    cart.sub_total = subt;
    cart.discountAmount = disc;
    //cart.total_qty = allcartData.total_qty - qty;
    cart.grand_total = (cart.sub_total - disc) + taxvalues;
    cart.tax_json = json.encode(taxjson);
    await localAPI.makeAsFocProduct(focProduct, isupdate, cart, cartitem);

    await getCartItem(currentCartID);
  }

  discountItem(MSTCartdetails selectedItem) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiscountPad(
          selectedProduct: selectedItem,
          issetMeal: selectedItem.issetMeal == 1 ? true : false,
          cartID: currentCartID,
          onClose: () {
            // CommunFun.processingPopup(context);
            refreshAfterAction(false);
            setState(() {
              itemSelected = new MSTCartdetails();
            });
          },
        );
      },
    );
  }

  setQuantityPad(cart) async {
    var prod;

    if (cart.issetMeal == 0) {
      List<ProductDetails> productdt =
          await localAPI.productdData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    } else {
      List<SetMeal> productdt = await localAPI.setmealData(cart.productId);
      if (productdt.length > 0) {
        prod = productdt[0];
      }
    }

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SetQuantityPad(
              selproduct: prod,
              cartID: currentCartID,
              cartItem: cart,
              focusCart: focusCart,
              onClose: (cartID) {
                countTotals(cartID);
                refreshAfterAction(false);
                Navigator.of(context).pop();
              });
        });
    //     return false;
    //   }
    // }
  }

  selectTable() async {
    //print(DateTime.now());
    if (originalCartList.length == 0) {
      if (cartList.length > 0) {
        localAPI.removeCartItem(cartList[0].cartId, selectedTable.table_id);
      }
      localAPI.deleteTableOrder(selectedTable.table_id);
      Preferences.removeSinglePref(Constant.TABLE_DATA);
    } else {
      await localAPI.updateCartListDetails(
          originalCartList, originalCartList[0].cartId);
      await countTotals(currentCartID);
    }
    //print(DateTime.now());
    goToTableScreen(selectedTable.table_id, originalCartList);
  }

  goToTableScreen([
    int updatedTableId = 0,
    List<MSTCartdetails> cartLists,
  ]) async {
    Navigator.pushNamedAndRemoveUntil(
        context, Constant.SelectTableScreen, (Route<dynamic> route) => false,
        arguments: {
          "isAssign": false,
          "updatedTableId": updatedTableId,
          'cartLists': cartLists,
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Future<bool> _willPopCallback() async {
      return false;
    }

    final itemEditScreen = GridView.count(
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(10),
      children: <Widget>[
        /* GestureDetector(
            onTap: itemSelected.isFocProduct == 1
                ? null
                : () {
                    if (permissions.contains(Constant.DISCOUNT_ITEM)) {
                      applyforFocProduct(itemSelected);
                      setState(() {
                        itemSelected = new MSTCartdetails();
                      });
                    } else {
                      CommonUtils.openPermissionPop(
                          context, Constant.DISCOUNT_ITEM, () {
                        applyforFocProduct(itemSelected);
                        setState(() {
                          itemSelected = new MSTCartdetails();
                        });
                      }, () {});
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: itemSelected.isFocProduct == 1
                    ? Colors.grey[400]
                    : Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.free_breakfast,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Text(Strings.makeFoc,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))
                ],
              ),
            )), */
        GestureDetector(
          onTap: () {
            if (permissions.contains(Constant.EDIT_ITEM)) {
              editCartItem(itemSelected);
              setState(() {
                itemSelected = new MSTCartdetails();
              });
            } else {
              CommonUtils.openPermissionPop(context, Constant.EDIT_ITEM, () {
                editCartItem(itemSelected);
                setState(() {
                  itemSelected = new MSTCartdetails();
                });
              }, () {});
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.white,
                ),
                SizedBox(height: 6),
                Text(Strings.editDetail,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white))
              ],
            ),
          ),
        ),
        GestureDetector(
            onTap: () {
              if (currentQuantity > 0) {
                currentProductQuantity = itemSelected.productQty;
                itemSelected.productQty = currentQuantity.toDouble();

                itemSelected.productDetailAmount =
                    currentQuantity * itemSelected.productPrice;
                localAPI.addintoCartDetails(itemSelected);
                countTotals(itemSelected.cartId);
                //print(jsonEncode(cart));
                currentQuantity = 0;
              } else {
                setQuantityPad(itemSelected);
                setState(() {
                  itemSelected = new MSTCartdetails();
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.library_add,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Text(Strings.setQuantity,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))
                ],
              ),
            )),
        /* GestureDetector(
            onTap: () {
              discountItem(itemSelected);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.percent,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Text(Strings.discount,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))
                ],
              ),
            )), */
        GestureDetector(
            onTap: () {
              if (permissions.contains(Constant.DELETE_ITEM)) {
                itememovefromCart(itemSelected);
                setState(() {
                  itemSelected = new MSTCartdetails();
                });
              } else {
                CommonUtils.openPermissionPop(context, Constant.DELETE_ITEM,
                    () {
                  itememovefromCart(itemSelected);
                  setState(() {
                    itemSelected = new MSTCartdetails();
                  });
                }, () {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6),
                  Text('Delete',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))
                ],
              ),
            )),
        /* GestureDetector(
          onTap: () {
            print(itemSelected);
            setState(() {
              itemSelected = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.ac_unit),
              SizedBox(height: 2),
              Text(
                'Global Modifier',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            print(itemSelected);
            setState(() {
              itemSelected = new MSTCartdetails();
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.room_service),
              SizedBox(height: 2),
              Text(
                'Service Type',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ) */
      ],
    );
    // Categrory Tabs
    final _tabs = TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: StaticColor.colorWhite,
        labelColor: StaticColor.colorWhite,
        isScrollable: true,
        labelPadding: EdgeInsets.all(2),
        indicatorPadding: EdgeInsets.all(2),
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: StaticColor.deepOrange),
        tabs: List<Widget>.generate(categoryFirstRow.length, (int index) {
          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabsList[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));

    final _secondTabs = TabBar(
        controller: _secondTabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        isScrollable: true,
        labelPadding: EdgeInsets.all(2),
        indicatorPadding: EdgeInsets.all(2),
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.deepOrange),
        tabs: List<Widget>.generate(categorySecondRow.length, (int index) {
          //index = (tabsList.length/2).ceil() + index;

          return new Tab(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  categorySecondRow[index].name.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                )),
          );
        }));
    /* final _subtabs = TabBar(
      controller: _subtabController,
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: StaticColor.colorWhite,
      labelColor: StaticColor.colorWhite,
      labelPadding: EdgeInsets.all(1),
      indicatorPadding: EdgeInsets.zero,
      isScrollable: true,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: StaticColor.deepOrange),
      tabs: List<Widget>.generate(subCatList.length, (int index) {
        return new Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockVertical * 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              subCatList[index].name.toUpperCase(),
              style: Styles.whiteBoldsmall(),
            ),
          ),
        );
      }),
    ); */

    return Scaffold(
      key: scaffoldKey,
      drawer: DrawerWid(),
      body: LoadingOverlay(
          child: SafeArea(
            child: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                slidableController.activeState?.close();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Table(
                  border: TableBorder.all(
                      color: StaticColor.colorWhite, width: 0.6),
                  columnWidths: {
                    0: FractionColumnWidth(.3),
                    1: FractionColumnWidth(.6),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(child: tableHeader2()),
                      TableCell(child: tableHeader1()),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child:  cartITems(),
                      ),
                      // TableCell(
                      //   child: Container()
                      // ),

                      TableCell(
                        child: Container(
                          height: MediaQuery.of(context).size.height * .9,
                          padding:
                              EdgeInsets.all(SizeConfig.safeBlockVertical * 1),
                          child: itemSelected.productQty != null &&
                                  itemSelected.productQty > 0
                              ? itemEditScreen
                              : Column(
                                  children: <Widget>[
                                    /* subCatList.length == 0?  */
                                    /* Container(
                                      //margin: EdgeInsets.only(left: 5, right: 5),
                                      width: MediaQuery.of(context).size.width,
                                      height: SizeConfig.safeBlockVertical * 8,
                                      color: Colors.black26,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1.2),
                                      child: DefaultTabController(
                                          initialIndex: 0,
                                          length: categoryFirstRow.length,
                                          child: _tabs),
                                    ),
                                    Container(
                                      //margin: EdgeInsets.only(left: 5, right: 5),
                                      width: MediaQuery.of(context).size.width,
                                      height: SizeConfig.safeBlockVertical * 8,
                                      color: Colors.black26,
                                      padding: EdgeInsets.all(
                                          SizeConfig.safeBlockVertical * 1.2),
                                      child: DefaultTabController(
                                          initialIndex: 0,
                                          length: categorySecondRow.length,
                                          child: _secondTabs),
                                    ), */
                                    //Category Row 1
                                    Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black26,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categoryFirstRow.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: FlatButton(
                                                onPressed: () {
                                                  _selectedCategory(
                                                      index, 'first');
                                                },
                                                //color: Colors.black,  //Colors.grey.shade800,
                                                color: categoryFirstRow[index]
                                                            .name ==
                                                        selectedCategory?.name
                                                    ? Colors.deepOrange
                                                    : Colors.black26,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  //side: BorderSide(color: Colors.black)
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: SizeConfig
                                                          .safeBlockHorizontal *
                                                      3,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  categoryFirstRow[index]
                                                      .name
                                                      .toUpperCase(),
                                                  style:
                                                      Styles.whiteBoldsmall(),
                                                )),
                                              ),
                                            );
                                          }),
                                    ),
                                    Container(
                                      height: SizeConfig.safeBlockVertical * 8,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black26,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categorySecondRow.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: FlatButton(
                                                onPressed: () {
                                                  _selectedCategory(
                                                      index, 'second');
                                                },
                                                //color: Colors.black,  //Colors.grey.shade800,
                                                color: categorySecondRow[index]
                                                            .name ==
                                                        selectedCategory?.name
                                                    ? Colors.deepOrange
                                                    : Colors.black26,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  //side: BorderSide(color: Colors.black)
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: SizeConfig
                                                          .safeBlockHorizontal *
                                                      3,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  categorySecondRow[index]
                                                      .name
                                                      .toUpperCase(),
                                                  style:
                                                      Styles.whiteBoldsmall(),
                                                )),
                                              ),
                                            );
                                          }),
                                    ),
                                    Container(
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .7,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              mealsList.length > 0
                                                  ? Expanded(
                                                      flex: 1,
                                                      child: setMealsList())
                                                  : SizedBox(),
                                              isLoading
                                                  ? CommunFun.loader(context)
                                                  : productList.length > 0
                                                      ? Expanded(
                                                          flex: 1,
                                                          child: porductsList())
                                                      : SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          isLoading: isScreenLoad,
          color: Colors.black87,
          progressIndicator: CommunFun.overLayLoader()),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * .1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          color: Color(0xFF434449), //scaffold color
        ),
        child: paybutton(context),
      ),
    );
  }

  Widget tableHeader1() {
    // products Header part 1
    return Container(
      height: MediaQuery.of(context).size.height * .1,
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width / 3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quantity.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 6.0, right: 6.0, top: 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: FlatButton(
              onPressed: () {
                _selectedQuantity(quantity[index]);
              },
              color: currentQuantity == quantity[index]
                  ? Colors.deepOrange
                  : Colors.grey.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 2,
              ),
              child: Center(
                  child: Text(
                'x ' + quantity[index].toString(),
                style: Styles.whiteBoldsmall(),
              )),
            ),
          );
        },
      ),
    );
  }

  Widget tableHeader2() {
    // products Header part 2
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      height: MediaQuery.of(context).size.height * .1,
      // color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          selectedTable != null
              ? Row(
                  children: <Widget>[
                    /* menubutton(() {}), */
                    SizedBox(width: 10),
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: SizeConfig.safeBlockVertical * 4,
                    ),
                    SizedBox(width: 5),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        tableName +
                            " (" +
                            selectedTable.number_of_pax.toString() +
                            ")",
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: Styles.whiteBoldsmall(),
                      ),
                    ),
                    SizedBox(width: 15)
                  ],
                )
              : SizedBox(),
          Expanded(
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textController,
                style: Styles.communBlacksmall(),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 20, top: 15, bottom: 15),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.safeBlockVertical * 3),
                      child: Icon(
                        Icons.search,
                        color: StaticColor.deepOrange,
                        size: SizeConfig.safeBlockVertical * 5,
                      ),
                    ),
                    hintText: Strings.searchBarText,
                    hintStyle: Styles.communGrey(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true,
                    fillColor: StaticColor.colorWhite),
              ),
              suggestionsCallback: (pattern) async {
                return searchProductList;
              },
              itemBuilder: (context, ProductDetails searchProductList) {
                // var image_Arr = searchProductList.base64
                //     .replaceAll("data:image/jpg;base64,", '');
                return ListTile(
                    leading: Container(
                      color: StaticColor.colorGrey,
                      width: 40,
                      height: 40,
                      child: searchProductList.base64 != ""
                          ? CommonUtils.imageFromBase64String(
                              searchProductList.base64)
                          : new Image.asset(
                              Strings.noImageAsset,
                              gaplessPlayback: true,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(
                      searchProductList.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                        searchProductList.price.toStringAsFixed(2) ?? "0.00"),
                    trailing: searchProductList.outOfStock == 1 ||
                            (searchProductList.qty != null &&
                                searchProductList.hasInventory == 1 &&
                                searchProductList.qty <= 0)
                        ? Text(Strings.outOfStoke,
                            style: Styles.orangesimpleSmall())
                        : SizedBox());
              },
              onSuggestionSelected: (suggestion) {
                if (suggestion.outOfStock != 1 ||
                    suggestion.qty == null ||
                    suggestion.hasInventory != 1 ||
                    suggestion.qty > 0.0) {
                  if (isShiftOpen) {
                    if (isTableSelected && !isWebOrder) {
                      showQuantityDailog(suggestion, false);
                    } else {
                      if (!isWebOrder) {
                        selectTable();
                      }
                    }
                  } else {
                    CommunFun.showToast(context, Strings.shiftOpenMessage);
                  }
                } else {
                  CommunFun.showToast(context, Strings.outOfStokeMsg);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addCustomerBtn(context) {
    return customer == null
        ? RaisedButton(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            onPressed: () async {
              if (isShiftOpen) {
                if (permissions.contains(Constant.ADD_CUSTOMER)) {
                  openShowAddCustomerDailog();
                } else {
                  await SyncAPICalls.logActivity(
                      "Add customer ",
                      "Cashier has no permission for add customer",
                      "customer",
                      1);
                  await CommonUtils.openPermissionPop(
                      context, Constant.ADD_CUSTOMER, () async {
                    await SyncAPICalls.logActivity(
                        "Add customer",
                        "Manager given permission for a customer",
                        "customer",
                        1);
                    openShowAddCustomerDailog();
                  }, () {});
                }
              } else {
                CommunFun.showToast(context, Strings.shiftOpenMessage);
              }
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add_circle_outline,
                  color: StaticColor.colorWhite,
                  size: SizeConfig.safeBlockVertical * 3,
                ),
                SizedBox(width: 5),
                Text(
                  Strings.btnAddCustomer.toUpperCase(),
                  style: Styles.whiteBoldsmall(),
                ),
              ],
            ),
            color: StaticColor.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          )
        : SizedBox();
  }

  Widget menubutton(Function _onPress) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.arrow_drop_down,
          color: Colors.white, size: SizeConfig.safeBlockVertical * 5),
      offset: Offset(0, MediaQuery.of(context).size.height * .1), //100
      // onSelected: 0,
      onSelected: selectOption,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          enabled: true,
          value: 0,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.person_add,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(child: SizedBox(width: 15)),
                Expanded(
                  child: Text(
                    Strings.btnAddCustomer,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          enabled: isTableSelected ? true : false,
          value: 1,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(child: SizedBox(width: 15)),
                Expanded(
                  child: Text(
                    Strings.closeTable,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                )
              ],
            ),
          ),
        ),
        PopupMenuItem(
          enabled: cartList.length > 1 ? true : false,
          value: 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.call_split,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(child: SizedBox(width: 15)),
                Expanded(
                  child: Text(
                    Strings.splitOrder,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          enabled: isShiftOpen ? true : false,
          value: 3,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.alarm_off,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(child: SizedBox(width: 15)),
                Expanded(
                  child: Text(
                    Strings.closeShift,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ),
        /* PopupMenuItem(
          enabled: cartList.length > 0 ? true : false,
          value: 4,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    Icons.delete,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  child: Text(
                    Strings.deleteOrder,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ), */
        /* PopupMenuItem(
          enabled: (cartList.length > 0 &&
              (!(selectedvoucher == null && allcartData.discountAmount > 0)) &&
              permissions.contains(Constant.DISCOUNT_ORDER)),
          value: 5,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    selectedvoucher == null
                        ? FontAwesomeIcons.gift
                        : Icons.remove_circle_outline,
                    color: Colors.black,
                    size: selectedvoucher == null
                        ? SizeConfig.safeBlockVertical * 4
                        : SizeConfig.safeBlockVertical * 5,
                  ),
                  flex: 2,
                ),
                Expanded(
                  child: SizedBox(),
                  flex: 1,
                ),
                Expanded(
                  child: Text(
                    selectedvoucher == null
                        ? Strings.applyPromocode
                        : Strings
                            .removePromocode, //selectedvoucher.voucherName,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ), */
       /*  PopupMenuItem(
          enabled: permissions.contains(Constant.DISCOUNT_ORDER) &&
              cartList.length > 0,
          value: 6,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Icon(
                    FontAwesomeIcons.percentage,
                    color: Colors.black,
                    size: SizeConfig.safeBlockVertical * 4,
                  ),
                  flex: 2,
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Expanded(
                  child: Text(
                    Strings.totalDiscount, //selectedvoucher.voucherName,
                    style: Styles.communBlacksmall(),
                  ),
                  flex: 10,
                ),
              ],
            ),
          ),
        ), */
      ],
    );
  }

  Widget setMealsList() {
    // products List
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemHeight = size.width / 4.2;
    final double itemWidth = size.width / 4.2;
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: GridView.count(
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: mealsList.map((meal) {
          var proprice = meal.price.toStringAsFixed(2);
          return InkWell(
            onTap: () {
              if (isShiftOpen) {
                if (isTableSelected && !isWebOrder) {
                  showQuantityDailog(meal, true);
                } else {
                  if (!isWebOrder) {
                    selectTable();
                  }
                }
              } else {
                CommunFun.showToast(context, Strings.shiftOpenMessage);
              }
            },
            child: Container(
              height: itemHeight,
              margin: EdgeInsets.all(5),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Hero(
                      tag: meal.setmealId != null ? meal.setmealId : 0,
                      child: Container(
                        color: StaticColor.colorGrey,
                        width: MediaQuery.of(context).size.width,
                        height: itemHeight / 2.2,
                        child: meal.base64 != ""
                            ? CommonUtils.imageFromBase64String(meal.base64)
                            : new Image.asset(
                                Strings.noImageAsset,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      )),
                  Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(top: itemHeight / 2.2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: StaticColor.colorGrey600,
                    ),
                    child: Center(
                      child: Text(
                        meal.name.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.whiteSmall(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: itemHeight / 2.2 - SizeConfig.safeBlockVertical * 5,
                    left: 0,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 5,
                      // width: 50,
                      padding: EdgeInsets.all(5),
                      color: StaticColor.deepOrange,
                      child: Center(
                        child: Text(
                            currency != null
                                ? currency + ' ' + proprice.toString()
                                : proprice.toString(),
                            style: Styles.whiteSimpleSmall()),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget porductsList() {
    // products List
    Size size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemHeight = size.width / 4.2;
    final double itemWidth = size.width / 4.2;
    return Container(
      //color: Colors.lightBlue,
      height: size.height * .7
      //- (SizeConfig.safeBlockVertical * 7)
      ,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 10, bottom: 20, left: 0, right: 0),
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 4,
        crossAxisSpacing: 9.0,
        mainAxisSpacing: 9.0,
        children: productList.map((product) {
          final prodprice = product.price.toStringAsFixed(2);
          try {
            CommonUtils.imageFromBase64String(product.base64);
          } catch (e) {
            print(e);
          }
          return InkWell(
            onTap: () async {
              if (product.outOfStock == 1) {
                CommunFun.showToast(context, Strings.outOfStokeMsg);
              } else if ((product.hasRacManagemant == 1 &&
                      product.box_pId != null) ||
                  (product.qty == null ||
                      product.hasInventory != 1 ||
                      product.qty > 0.0)) {
                await SyncAPICalls.logActivity(
                    "product", "Clicked product item", "product", 1);
                checkshiftopen(product);
              } else {
                CommunFun.showToast(context, Strings.outOfStokeMsg);
              }
            },
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: StaticColor.colorBlack,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.zero,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Hero(
                    tag: product.productId != null ? product.productId : 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: StaticColor.colorGrey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      height: itemHeight / 2.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
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
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(top: itemHeight / 2.2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: product.outOfStock == 1 ||
                              (product.qty != null &&
                                  product.hasInventory == 1 &&
                                  product.qty <= 0)
                          ? StaticColor.colorGrey400
                          : StaticColor.colorGrey600,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        product.name.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.whiteSmall(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: itemHeight / 2.2 - SizeConfig.safeBlockVertical * 5,
                    left: 0,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 5,
                      // width: 50,
                      padding: EdgeInsets.all(5),
                      color: StaticColor.deepOrange,
                      child: Center(
                        child: Text(
                            currency != null
                                ? currency + ' ' + prodprice.toString()
                                : prodprice.toString(),
                            style: Styles.whiteSimpleSmall()),
                      ),
                    ),
                  ),
                  product.outOfStock == 1 ||
                          (product.qty != null &&
                              product.hasInventory == 1 &&
                              product.qty <= 0)
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: SizeConfig.safeBlockVertical * 4,
                            // width: 50,
                            padding: EdgeInsets.all(2),
                            color: StaticColor.deepOrange,
                            child: Center(
                              child: Text(Strings.outOfStoke,
                                  style: Styles.whiteSimpleSmall()),
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget paybutton(context) {
    // Payment button
    return Row(
        mainAxisAlignment: !isWebOrder
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 20),
          !isWebOrder
              ? Container(
                  //margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 1.3),
                  height: SizeConfig.safeBlockVertical * 7,
                  width: MediaQuery.of(context).size.width / 7,
                  child: RaisedButton.icon(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    onPressed: () async {
                      if (cartList.length == 0) {
                        CommunFun.showToast(context, Strings.cartEmpty);

                        return false;
                      }
                      await SyncAPICalls.logActivity("send to kitchen",
                          "Clicked sent to kitchen", "send to kitchen", 1);
                      if (permissions.contains(Constant.SEND_KITCHEN)) {
                        await countTotals(currentCartID);
                        //sendTokitched(cartList);
                        goToTableScreen(selectedTable.table_id, cartList);
                      } else {
                        await CommonUtils.openPermissionPop(
                            context, Constant.SEND_KITCHEN, () async {
                          await countTotals(currentCartID);
                          //sendTokitched(cartList);
                          await SyncAPICalls.logActivity(
                              "send to kitchen",
                              "Manager given permission for send items to kitchen",
                              "send to kitchen",
                              1);
                          goToTableScreen(selectedTable.table_id, cartList);
                        }, () {});
                      }
                    },
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: SizeConfig.safeBlockVertical * 3,
                    ),
                    label: Text(
                      originalCartList.length > 0
                          ? Strings.send.toUpperCase()
                          : Strings.confirmOrder.toUpperCase(),
                      style: Styles.whiteBoldsmall(),
                    ),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                )
              : SizedBox(),
          /* Container(
            /* margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 1.3 + 10),*/
            height: SizeConfig.safeBlockVertical * 7,
            width: MediaQuery.of(context).size.width / 7,
            child: RaisedButton.icon(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: isCounting
                  ? null
                  : () async {
                      if (!isWebOrder) {
                        sendPayment();
                      } else {
                        checkoutWebOrder();
                      }
                      await SyncAPICalls.logActivity("payment",
                          "Clicked pay and perform payment", "voucher", 1);
                    },
              icon: Icon(
                Icons.payment,
                color: Colors.white,
                size: SizeConfig.safeBlockVertical * 3,
              ),
              label: Text(
                !isWebOrder ? Strings.titlePay : Strings.checkout,
                style: Styles.whiteBoldsmall(),
              ),
              disabledColor: StaticColor.deepOrange,
              color: StaticColor.deepOrange,
              textColor: StaticColor.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ), */
          SizedBox(width: 20),
          Container(
            height: SizeConfig.safeBlockVertical * 7,
            width: MediaQuery.of(context).size.width / 7,
            child: RaisedButton.icon(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () async {
                printCheckList();
                await SyncAPICalls.logActivity("print check list",
                    "Cashier clicked print check list", "print check list", 1);
              },
              icon: Icon(
                Icons.check_circle_outline_outlined,
                color: Colors.white,
              ),
              label: Text(
                Strings.checkList.toUpperCase(),
                style: Styles.whiteBoldsmall(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            height: SizeConfig.safeBlockVertical * 7,
            width: MediaQuery.of(context).size.width / 7,
            child: RaisedButton.icon(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              onPressed: () async {
                draftreciptPrint();
                await SyncAPICalls.logActivity("print draft",
                    "Cashier clicked print draft reciept", "print draft", 1);
              },
              icon: Icon(
                Icons.print,
                color: Colors.white,
              ),
              label: Text(
                Strings.draftReport.toUpperCase(),
                style: Styles.whiteBoldsmall(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            height: SizeConfig.safeBlockVertical * 7,
            width: MediaQuery.of(context).size.width / 5,
            child: RaisedButton.icon(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () async {
                if (cartList.length == 0) {
                  CommunFun.showToast(context, Strings.cartEmpty);
                  return false;
                }
                resendToKitchen();
                await SyncAPICalls.logActivity("reprint kitchen",
                    "Clicked  resend to kitchen button", "reprint kitchen", 1);
              },
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              label: Text(
                Strings.reprintOrder.toUpperCase(),
                style: Styles.whiteBoldsmall(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            height: SizeConfig.safeBlockVertical * 7,
            width: MediaQuery.of(context).size.width / 7,
            child: RaisedButton.icon(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () async {
                await SyncAPICalls.logActivity(
                    "select table", "Clicked select table", "select table", 1);
                selectTable();
              },
              icon: Icon(
                Icons.select_all,
                color: Colors.white,
                size: SizeConfig.safeBlockVertical * 3,
              ),
              label: Text(
                Strings.selectTable.toUpperCase(),
                style: Styles.whiteBoldsmall(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ]);
  }

  Widget openShiftButton(context) {
    // Payment button
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          color: Colors.white70.withOpacity(0.9),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Strings.shiftTextLable,
                style: TextStyle(fontSize: SizeConfig.safeBlockVertical * 4),
              ),
              SizedBox(height: 15),
              Text(
                Strings.closed,
                style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 6,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              shiftbtn(() async {
                if (permissions.contains(Constant.OPENING)) {
                  openOpningAmmountPop(Strings.titleOpeningAmount);
                } else {
                  await SyncAPICalls.logActivity("opening",
                      "Cashier has no permission for open store", "shift", 1);
                  await CommonUtils.openPermissionPop(context, Constant.OPENING,
                      () async {
                    openOpningAmmountPop(Strings.titleOpeningAmount);
                    await SyncAPICalls.logActivity("opening",
                        "Manager given permission for open store", "shift", 1);
                  }, () {});
                }
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget shiftbtn(Function onPress) {
    return RaisedButton(
      padding: EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 15),
      onPressed: onPress,
      child: Text(
        Strings.openShift,
        style: TextStyle(
            color: StaticColor.deepOrange,
            fontSize: SizeConfig.safeBlockVertical * 4),
      ),
      color: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, style: BorderStyle.solid, color: StaticColor.deepOrange),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget cartITems() {
    // selected item list and total price calculations
    final customerdatawidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(
          Icons.account_circle,
          color: StaticColor.colorGrey,
          size: SizeConfig.safeBlockVertical * 4,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Text(customer != null ? customer.name : ""),
            Text(customer != null ? customer.email : ""),
          ],
        ),
        IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: SizeConfig.safeBlockVertical * 4,
            ),
            onPressed: () {
              removeCutomer();
            })
      ],
    );

    final carttitle = Row(
      children: [
        Expanded(
          child: Text(
            Strings.headerName,
            style: Styles.darkBlue(),
          ),
          flex: 6,
        ),
        Expanded(
          child: Text(
            Strings.qty,
            style: Styles.darkBlue(),
            textAlign: TextAlign.end,
          ),
          flex: 1,
        ),
        Expanded(
          child: Text(
            Strings.amount,
            style: Styles.darkBlue(),
            textAlign: TextAlign.end,
          ),
          flex: 2,
        ),
        Expanded(
          child: Icon(Icons.delete_forever),
          flex: 1,
        ),
      ],
    );
    Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            horizontalInside: BorderSide(
                width: 1,
                color: StaticColor.colorGrey,
                style: BorderStyle.solid)),
        columnWidths: {
          0: FractionColumnWidth(.6),
          1: FractionColumnWidth(.2),
          2: FractionColumnWidth(.2),
          3: FractionColumnWidth(.2)
        },
        children: [
          TableRow(children: [
            Text(Strings.headerName, style: Styles.darkBlue()),
            Text(Strings.qty, style: Styles.darkBlue()),
            Text(Strings.amount, style: Styles.darkBlue()),
            Text(''),
          ])
        ]);

    final cartTable = ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,

      //itemExtent: 30,
      padding: EdgeInsets.only(bottom: 0), //50
      children: cartList.map((cart) {
        return Slidable(
          key: Key(cart.id.toString()),
          enabled: false,
          controller: slidableController,
          actionPane: SlidableDrawerDismissal(),
          actionExtentRatio: 0.15,
          direction: Axis.horizontal,
          child: GestureDetector(
            onTap: () => setState(() {
              // cartListTemp = ;
              focusCart = cart;
              if (currentQuantity > 0) {
                currentProductQuantity = cart.productQty;
                cart.productQty = currentQuantity.toDouble();

                cart.productDetailAmount = currentQuantity * cart.productPrice;
                localAPI.addintoCartDetails(cart);
                countTotals(cart.cartId);
                //print(jsonEncode(cart));
                currentQuantity = 0;
              } else if (cart.id == itemSelected.id) {
                itemSelected = new MSTCartdetails();
              } else {
                itemSelected = cart;
              }
            }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              color: cart.id == itemSelected.id
                  ? Colors.deepOrange[200]
                  : Colors.transparent,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            cart.productName.toUpperCase() +
                                (cart.discountAmount != null && cart.discountAmount > 0
                                    ? ' ' +
                                        (cart.discountType == 1
                                            ? '(' +
                                                cart.discountAmount
                                                    .toStringAsFixed(2) +
                                                '% OFF)'
                                            : '( -' +
                                                cart.discountAmount
                                                    .toStringAsFixed(2) +
                                                ')')
                                    : ''),
                            maxLines: 3,
                            overflow: TextOverflow.clip,
                            style: Styles.greysmall()),
                        cart.attrName != null
                            ? Text(" (" + cart.attrName + ") ",
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: Styles.greysmall())
                            : SizedBox(),
                        cart.modiName != null
                            ? Text(" (" + cart.modiName + ") ",
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: Styles.greysmall())
                            : SizedBox(),
                      ],
                    ),
                    flex: 6,
                  ),
                  Expanded(
                    child: Text(
                      cart.productQty.toInt().toString(),
                      style: Styles.greysmall(),
                      textAlign: TextAlign.end,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      cart.productDetailAmount.toStringAsFixed(2),
                      style: Styles.greysmall(),
                      textAlign: TextAlign.end,
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (permissions.contains(Constant.DELETE_ITEM)) {
                          itememovefromCart(cart);
                        } else {
                          CommonUtils.openPermissionPop(
                              context, Constant.DELETE_ITEM, () {
                            itememovefromCart(cart);
                            setState(() {
                              itemSelected = new MSTCartdetails();
                            });
                          }, () {});
                        }
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ), /* Text('x',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: SizeConfig.safeBlockVertical * 4,
                          ),
                          textAlign: TextAlign.center), */
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
          secondaryActions: isWebOrder
              ? <Widget>[
                  cart.issetMeal == 0
                      ? IconSlideAction(
                          color: Colors.blueAccent,
                          icon: Icons.free_breakfast,
                          onTap: () async {
                            if (permissions.contains(Constant.FREE_ITEM)) {
                              applyforFocProduct(cart);
                            } else {
                              await SyncAPICalls.logActivity(
                                  "FOC Product",
                                  "Cashier has no permission for make Foc product",
                                  "Order",
                                  1);
                              await CommonUtils.openPermissionPop(
                                  context, Constant.FREE_ITEM, () async {
                                applyforFocProduct(cart);
                                await SyncAPICalls.logActivity(
                                    "FOC Product",
                                    "Manager given permission for make Foc product",
                                    "Order",
                                    1);
                              }, () {});
                            }
                          },
                        )
                      : SizedBox(),
                ]
              : <Widget>[
                  cart.issetMeal == 0
                      ? IconSlideAction(
                          color: Colors.blueAccent,
                          icon: Icons.free_breakfast,
                          onTap: () async {
                            if (permissions.contains(Constant.FREE_ITEM)) {
                              applyforFocProduct(cart);
                            } else {
                              await SyncAPICalls.logActivity(
                                  "FOC Product",
                                  "Cashier has no permission for make Foc product",
                                  "Order",
                                  1);
                              await CommonUtils.openPermissionPop(
                                  context, Constant.FREE_ITEM, () async {
                                applyforFocProduct(cart);
                                await SyncAPICalls.logActivity(
                                    "FOC Product",
                                    "Manager given permission for make Foc product",
                                    "Order",
                                    1);
                              }, () {});
                            }
                          },
                        )
                      : SizedBox(),
                  IconSlideAction(
                    color: Colors.black45,
                    icon: Icons.edit,
                    onTap: () {
                      if (cart.isFocProduct != 1) {
                        editCartItem(cart);
                      } else {
                        CommunFun.showToast(context, Strings.focProductMsg);
                      }
                    },
                  ),
                  /*  IconSlideAction(
                    color: Colors.red,
                    icon: Icons.delete_outline,
                    onTap: () async {
                      if (permissions.contains(Constant.DELETE_ITEM)) {
                        itememovefromCart(cart);
                      } else {
                        await SyncAPICalls.logActivity(
                            "Delete Product",
                            "Cashier has no permission for delete product from cart",
                            "Order",
                            1);
                        await CommonUtils.openPermissionPop(
                            context, Constant.DELETE_ITEM, () async {
                          itememovefromCart(cart);
                          await SyncAPICalls.logActivity(
                              "Delete Product",
                              "Cashier has no permission for delete product from cart",
                              "Order",
                              1);
                        }, () {});
                      }
                    },
                  ) */
                ],
        );
      }).toList(),
    );

    final totalPriceTable = Column(
      children: <Widget>[
        Divider(
          color: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Strings.subTotal.toUpperCase(),
                style: Styles.darkBlue(),
              ),
              Text(
                (subtotal ?? 0).toStringAsFixed(2),
                style: Styles.darkBlue(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Strings.discount.toUpperCase() +
                    (selectedvoucher == null
                        ? ''
                        : ' (' + selectedvoucher.voucherName + ')'),
                style: Styles.orangeDis(),
              ),
              Text(
                (discount ?? 0).toStringAsFixed(2),
                style: Styles.orangeDis(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Strings.serviceCharge.toUpperCase() +
                    (serviceChargePer > 0 ? " ($serviceChargePer%)" : " (0%)"),
                style: Styles.darkBlue(),
              ),
              Text(
                serviceCharge.toStringAsFixed(2),
                style: Styles.darkBlue(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
          child: taxJson.length != 0
              ? Column(
                  children: taxJson.map((taxitem) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          Strings.tax.toUpperCase() +
                              " " +
                              taxitem["taxCode"] +
                              " (" +
                              taxitem["rate"] +
                              "%)",
                          style: Styles.darkBlue(),
                        ),
                        Text(
                            double.tryParse(taxitem["taxAmount"])
                                .toStringAsFixed(2),
                            style: Styles.darkBlue()),
                      ],
                    );
                  }).toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.tax.toUpperCase(),
                      style: Styles.darkBlue(),
                    ),
                    Text(
                      (tax ?? 0).toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
        ),
        Divider(
          color: Colors.black,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(Strings.grandTotal, style: Styles.darkBlue()),
              Text(
                CommunFun.checkRoundData(grandTotal.toStringAsFixed(2)),
                style: Styles.darkBlue(),
              ),
            ],
          ),
        ),
      ],
    );
    final expandable_totalPriceTable = Padding(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: ExpandablePanel(
        header: Builder(
          builder: (context) {
            expandableController = ExpandableController.of(context);
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Icon(
                    expandableController.expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 40,
                  ),
                  onTap: () {
                    expandableController.toggle();
                  },
                ),
              ],
            );
          },
        ),
        collapsed: ExpandableButton(
          child: Column(
            children: <Widget>[
              Divider(
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Strings.total, style: Styles.darkBlue()),
                    Text(
                      grandTotal.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        expanded: ExpandableButton(
          child: Column(
            children: <Widget>[
              Divider(
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.subTotal.toUpperCase(),
                      style: Styles.darkBlue(),
                    ),
                    Text(
                      (subtotal ?? 0).toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.discount.toUpperCase() +
                          (selectedvoucher == null
                              ? ''
                              : ' (' + selectedvoucher.voucherName + ')'),
                      style: Styles.orangeDis(),
                    ),
                    Text(
                      (discount ?? 0).toStringAsFixed(2),
                      style: Styles.orangeDis(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Strings.serviceCharge.toUpperCase() +
                          " ($serviceChargePer%)",
                      style: Styles.darkBlue(),
                    ),
                    Text(
                      serviceCharge.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: taxJson.length != 0
                    ? Column(
                        children: taxJson.map((taxitem) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                Strings.tax.toUpperCase() +
                                    " " +
                                    taxitem["taxCode"] +
                                    " (" +
                                    taxitem["rate"] +
                                    "%)",
                                style: Styles.darkBlue(),
                              ),
                              Text(taxitem["taxAmount"].toString(),
                                  style: Styles.darkBlue()),
                            ],
                          );
                        }).toList(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            Strings.tax.toUpperCase(),
                            style: Styles.darkBlue(),
                          ),
                          Text(
                            (tax ?? 0).toStringAsFixed(2),
                            style: Styles.darkBlue(),
                          )
                        ],
                      ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Strings.grandTotal, style: Styles.darkBlue()),
                    Text(
                      grandTotal.toStringAsFixed(2),
                      style: Styles.darkBlue(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        theme: const ExpandableThemeData(
          tapBodyToCollapse: true,
          tapBodyToExpand: true,
          tapHeaderToExpand: true,
          expandIcon: Icons.arrow_drop_up,
          collapseIcon: Icons.arrow_drop_down,
          iconSize: 35.0,
          hasIcon: false,
        ),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height * .9,
      //- SizeConfig.safeBlockVertical * 3,

      color: Colors.grey[300],
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * .12),
      child: Stack(
        children: <Widget>[
          customer != null
              ? Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: 80,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: customerdatawidget)
              : SizedBox(),
          cartList.length != 0
              ? Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  margin: EdgeInsets.only(top: customer != null ? 50 : 0),
                  color: StaticColor.colorWhite,
                  padding: EdgeInsets.all(5),
                  child: carttitle,
                )
              : SizedBox(),
          Container(
              //  color: Colors.amber,
              //color: Colors.red,
              height:
                  /* expandableController != null &&
                          expandableController.expanded
                      ? MediaQuery.of(context).size.height * .8 / 2
                      :  */
                  MediaQuery.of(context).size.height * .5,
              margin: EdgeInsets.only(top: customer != null ? 85 : 35),
              child: cartTable),
          cartList.length != 0
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: StaticColor.colorGrey300,
                    child: totalPriceTable,
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                )
              : Center(
                  child: Text(
                    Strings.itemNotAvailable,
                    style: Styles.communBlacksmall(),
                  ),
                )
        ],
      ),
    );
  }
}
