import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Attribute_data.dart';
import 'package:mcncashier/models/MST_Cart.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/ModifireData.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Product_Store_Inventory.dart';
import 'package:mcncashier/models/BranchTax.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/SetMealProduct.dart';
import 'package:mcncashier/models/Table_order.dart';
import 'package:mcncashier/models/Tax.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/models/saveOrder.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/services/allTablesSync.dart';
import 'package:mcncashier/widget/CloseButtonWidget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProductQuantityDailog extends StatefulWidget {
  // quantity Dailog
  ProductQuantityDailog(
      {Key key,
      this.selproduct,
      this.issetMeal,
      this.cartID,
      this.cartItem,
      this.onClose,
      this.addReservation,
      this.extraSubDetail})
      : super(key: key);
  final bool issetMeal;
  final selproduct;
  final int cartID;
  final MSTCartdetails cartItem;
  final List<MSTSubCartdetails> extraSubDetail;
  Function onClose;
  Function addReservation;

  @override
  _ProductQuantityDailogState createState() => _ProductQuantityDailogState();
}

class _ProductQuantityDailogState extends State<ProductQuantityDailog> {
  List<dynamic> obj = [];
  TextEditingController productController = new TextEditingController();
  TextEditingController extraNotes = new TextEditingController();
  LocalAPI localAPI = LocalAPI();
  List<Attribute_Data> attributeList = [];
  Map<int, List<Attribute_Data>> setMealAttributeList = new Map();
  Map<int, double> selectedAttrPrice = new Map();
  ProductDetails productItem = new ProductDetails();
  SetMeal setmeal;
  MSTCartdetails cartitem;
  List<SetMealProduct> tempCart = new List<SetMealProduct>();
  List<ModifireData> modifireList = [];
  List selectedAttr = [];
  List selectedSetMealAttr = [];
  MST_Cart currentCart = new MST_Cart();
  List<MSTCartdetails> cartItems = [];
  List<SetMealProduct> mealProducts = [];
  List<ModifireData> selectedModifier = [];
  double productQty = 1.0;
  double price = 0.00;
  Printer printer;
  bool isEditing = false;
  List<BranchTax> taxlist = [];
  double taxvalues = 0.00;
  int isSelectedAttr = -1;
  bool isSetMeal = false;
  var productnetprice = 0.00;
  var currency = "MYR";
  String attributeTitle = "";
  var permissions = "";
  bool isFirstMod = false;
  bool isFirstAttr = false;
  bool isFirstAttrSet = true;
  bool isLoading = false;
  List<dynamic> attrdata;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSetMeal = widget.issetMeal;
      isEditing = widget.cartItem != null;
      cartitem = widget.cartItem;
    });
    if (!isSetMeal &&
        widget.selproduct.qty != null &&
        widget.selproduct.qty > 0) {
      setState(() {
        productQty = widget.selproduct.qty;
      });
    } else if (!isSetMeal &&
        widget.cartItem != null &&
        cartitem.productQty != null &&
        cartitem.productQty > 0) {
      setState(() {
        productQty = widget.cartItem.productQty;
      });
    }
    setInitstate();
    setPermissons();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
    /* await SyncAPICalls.logActivity(
        "product details", "Opened product details popup", "product", 1); */
  }

  setInitstate() async {
    if (isSetMeal) {
      setState(() {
        setmeal = widget.selproduct;
        price = setmeal.price;
        productnetprice = setmeal.price;
      });
      getMealProducts();
    } else {
      setState(() {
        productItem = widget.selproduct;
        price = productItem.price;
        productnetprice = productItem.price;
      });
      getAttributes(productItem.productId);
    }

    setPrice();
    getTaxs();
    getPrinter();

    if (widget.cartID != null) {
      getCartData();
      getcartItemList();
    }
    var curre = await Preferences.getStringValuesSF(Constant.CURRENCY);
    setState(() {
      currency = curre;
    });
  }

  getCartData() async {
    List<MST_Cart> cartval = await localAPI.getCurrentCart(widget.cartID);
    if (cartval.length != 0) {
      setState(() {
        currentCart = cartval[0];
      });
    }
  }

  getcartItemList() async {
    List<MSTCartdetails> cartItemslist =
        await localAPI.getCurrentCartItems(widget.cartID);
    if (cartItemslist.length != 0) {
      setState(() {
        cartItems = cartItemslist;
      });
    }
  }

  getMealProducts() async {
    List<SetMealProduct> mealCartList = [];
    List<SetMealProduct> mealProductList =
        await localAPI.getMealsProductData(setmeal.setmealId);
    List<MSTSubCartdetails> subCartDetails = [];
    if (isEditing) {
      subCartDetails = await localAPI.getItemModifire(cartitem.id);
    }
    if (mealProductList.length > 0) {
      setState(() {
        mealProducts = isEditing ? mealCartList : mealProductList;
      });
      getSetMealAttributeList(mealProductList, subCartDetails);
      //await setSetMealData();
    }
  }

  getPrinter() async {
    List<Printer> printerlist = await localAPI.getPrinter(
        !isSetMeal ? productItem.productId.toString() : setmeal.setmealId);
    if (printerlist.length > 0) {
      setState(() {
        printer = printerlist[0];
      });
    }
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

  setAttrData(productData) {
    if (productData["Attributes"].length > 0) {
      setState(() {
        attributeList.addAll(productData["Attributes"]);
      });
    }
  }

  setModifireData(productData) {
    if (productData["Modifire"].length > 0) {
      setState(() {
        modifireList.addAll(productData["Modifire"]);
      });
    }
    if (isEditing) {
      setProductEditingData();
    }
  }

  setMealProduct(productData) async {
    if (productData["SetMealsProduct"].length > 0) {
      setState(() {
        mealProducts.addAll(productData["SetMealsProduct"]);
      });
      await setSetMealData();
    }
  }

  setTaxs(productData) async {
    if (productData["BranchTax"].length > 0) {
      setState(() {
        taxlist.addAll(productData["BranchTax"]);
      });
    }
  }

  setPrinter(productData) async {
    if (productData["PrinterList"].length > 0) {
      List<Printer> printerList = productData["PrinterList"];
      setState(() {
        printer = printerList[0];
      });
    }
  }

  setCartData(productData) async {
    if (productData["CartTotals"].length > 0) {
      List<MST_Cart> cartval = productData["CartTotals"];
      setState(() {
        currentCart = cartval[0];
      });
    }
  }

  getSetMealAttributeList(List<SetMealProduct> mealProductList,
      List<MSTSubCartdetails> subCartDetails) {
    for (SetMealProduct product in mealProductList) {
      var attrData = jsonDecode(product.attributeDetails);
      attrData.removeWhere((attr) =>
          attr['attributeId'] == "null" || attr['attributeId'] == null);
      List<Attribute_Data> attributeList =
          (attrData != null && attrData.isNotEmpty)
              ? attrData
                  .map((c) => Attribute_Data.fromJson(c))
                  .whereType<Attribute_Data>()
                  .toList()
              : [];
      if (!isEditing) {
        for (Attribute_Data attribute in attributeList) {
          List<String> optionIds = attribute.attributeId.split(',');
          List<String> optionPrices = attribute.attr_types_price.split(',');
          for (var i = 0; i < optionIds.length; i++) {
            if (i < optionPrices.length) {
              updateAttribute(
                product.productId,
                attribute,
                attribute.attributeId.split(','),
                int.tryParse(optionIds[i]),
                optionPrices[i],
              );
            }
          }
        }
      } else {
        List<int> cartDetailsIds = new List();
        subCartDetails
            .forEach((subCart) => cartDetailsIds.add(subCart.attributeId));
        for (Attribute_Data attribute in attributeList) {
          List<String> optionIds = attribute.attributeId.split(',');
          List<String> optionPrices = attribute.attr_types_price.split(',');
          for (int i = 0; i < optionIds.length; i++) {
            if (i < optionPrices.length &&
                cartDetailsIds.contains(int.tryParse(optionIds[i]))) {
              updateAttribute(
                product.productId,
                attribute,
                attribute.attributeId.split(','),
                int.tryParse(optionIds[i]),
                optionPrices[i],
              );
            }
          }
        }
      }
      setMealAttributeList[product.productId] = attributeList;
    }
  }

  setSetMealData() {
    if (cartitem != null && !isEditing) {
      var cartData = jsonDecode(cartitem.setmeal_product_detail);
      List<SetMealProduct> tCartData = cartData.isNotEmpty
          ? cartData
              .map((c) => SetMealProduct.fromJson(c))
              .whereType<SetMealProduct>()
              .toList()
          : [];
      setState(() {
        tempCart = tCartData;
      });
    } else {
      tempCart.addAll(mealProducts);
    }
  }

  setProductEditingData() async {
    List<MSTSubCartdetails> details;
    if (!isSetMeal && cartitem.id != null) {
      details = await localAPI.getItemModifire(cartitem.id);
    } else if (widget.extraSubDetail != null) {
      details = widget.extraSubDetail;
    }

    if (details.length > 0) {
      for (var i = 0; i < details.length; i++) {
        var item = details[i];
        if (item.caId != null) {
          //Attr
          if (attributeList.length > 0) {
            for (var i = 0; i < attributeList.length; i++) {
              var attribute = attributeList[i];
              var attributType = attribute.attr_types.split(',');
              var attrIDs = attribute.attributeId.split(',');
              var isdef = attribute.is_default.split(',');
              var attrtypesPrice = attribute.attr_types_price.split(',');
              for (var a = 0; a < attributType.length; a++) {
                var aattrid = int.parse(attrIDs[a]);
                if (item.attributeId == aattrid) {
                  onSelectAttr(a, attribute.ca_id, attributType[a], attrIDs[a],
                      attrtypesPrice[a], null, isdef[a]);
                }
              }
            }
          }
          // Modifier
          if (modifireList.length > 0) {
            for (var j = 0; j < modifireList.length; j++) {
              if (modifireList[j].modifierId == item.modifierId) {
                setModifire(modifireList[j]);
              }
            }
          }
        }
      }
    }
    if (cartitem.remark != null && cartitem.remark.isNotEmpty) {
      extraNotes.text = cartitem.remark;
    }
    setState(() {
      productQty = cartitem.productQty is int
          ? cartitem.productQty.toDouble()
          : cartitem.productQty;
      price = cartitem.productPrice;
    });
  }

  getAttributes(productid) async {
    List<Attribute_Data> productAttr =
        await localAPI.getProductDetails(productid);
    if (productAttr.length > 0 && this.mounted) {
      setState(() {
        attributeList = productAttr;
      });
    }

    List<ModifireData> productModifeir =
        await localAPI.getProductModifeir(productid);
    if (productModifeir.length > 0 && this.mounted) {
      for (ModifireData modifier in productModifeir) {
        if (modifier.isDefault == 1 && selectedModifier.length == 0) {
          selectedModifier.add(modifier);
        }
      }
    }
      setState(() {
        modifireList = productModifeir;
        selectedModifier = selectedModifier;
        isFirstMod = true;
        setPrice();
      });
    /* for (var item in productAttr) {
      if (item.is_default == "1") {
        print('enter is default');
        var isadded = selectedSetMealAttr.any((item) =>
            item['ca_id'] == attribute.ca_id && item['attribute'] == attr);
        if ((attrDefault[i] == "1" && !isadded && isFirstAttrSet) ||
            !isFirstAttrSet && isadded) {
          var prvSeelectedSetMeal = selectedSetMealAttr;
          prvSeelectedSetMeal.add({
            'setmeal_productID': product.setmealProductId,
            'ca_id': attribute.ca_id,
            'attribute': attr,
            'attrType_ID': attrIDs[i],
            'attr_price': attrtypesPrice[i]
          });
          setState(() {
            selectedSetMealAttr = prvSeelectedSetMeal;
            // isFirstAttrSet = false;
          });
          setPrice();
        }
      }
    } */
    if (isEditing) {
      setProductEditingData();
    }
  }
/* 
  getcartItemsDetails(productData) async {
    if (productData["CartItems"].length != 0) {
      setState(() {
        cartItems.addAll(productData["CartItems"]);
      });
    }
  } */

  getcartItemsDetails() async {
    if (!isSetMeal) {
      var contain = cartItems
          .where((element) => element.productId == productItem.productId);
      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        List<MSTCartdetails> myModels = (json.decode(jsonString) as List)
            .map((i) => MSTCartdetails.fromJson(i))
            .toList();
        var sameAttributes = [];
        for (var m = 0; m < myModels.length; m++) {
          List<MSTSubCartdetails> details =
              await localAPI.getItemModifire(myModels[m].id);
          if (details.length > 0) {
            for (var p = 0; p < details.length; p++) {
              var item = details[p];
              if (item.caId != null) {
                if (selectedAttr.length > 0) {
                  for (var i = 0; i < selectedAttr.length; i++) {
                    var attr = selectedAttr[i];

                    if (item.attributeId == int.parse(attr["attrType_ID"])) {
                      sameAttributes.add(item);
                    }
                  }
                }
              } else {
                if (selectedModifier.length > 0) {
                  for (var i = 0; i < selectedModifier.length; i++) {
                    var modifire = selectedModifier[i];
                    if (item.modifierId == modifire.modifierId) {
                      sameAttributes.add(item);
                    }
                  }
                }
              }
            }
          }
          if (selectedAttr.length != 0 || selectedModifier.length != 0) {
            if (details.length > 0 && sameAttributes.length == details.length) {
              setState(() {
                isEditing = true;
                cartitem = myModels[m];
              });
            }
          } else {
            if (details.length == 0) {
              setState(() {
                isEditing = true;
                cartitem = myModels[m];
              });
            }
          }
        }
        if (isEditing && cartitem != null) {
          setState(() {
            productQty =
                isEditing ? productQty + cartitem.productQty : productQty;
            price = isEditing ? price + cartitem.productPrice : price;
          });
        }
      }
    } else {
      //Put logic here for set Meal update
      var contain =
          cartItems.where((element) => element.productId == setmeal.setmealId);
      if (contain.isNotEmpty) {
        var jsonString = jsonEncode(contain.map((e) => e.toJson()).toList());
        List<MSTCartdetails> prodData = (json.decode(jsonString) as List)
            .map((i) => MSTCartdetails.fromJson(i))
            .toList();
        setmeal.price = prodData[0].productPrice;
        List<SetMealProduct> tCartData = [];
        if (prodData[0] != null) {
          List<dynamic> cartData =
              jsonDecode(prodData[0].setmeal_product_detail);
          tCartData = cartData.isNotEmpty
              ? cartData.map((c) => SetMealProduct.fromJson(c)).toList()
              : [];
        }
        setState(() {
          isEditing = true;
          setmeal = setmeal;
          price = setmeal.price;
          productQty = prodData[0].productQty;
          tempCart = tCartData;
          cartitem = prodData[0];
        });
      }
    }
  }

  updateAttribute(int productID, Attribute_Data attribute,
      List<String> listAttrId, int attrID, String attrPrice) {
    bool isSelectedType =
        selectedAttr.any((item) => item['attrType_ID'] == attrID);
    if (!isSelectedType) {
      selectedAttr.removeWhere((ele) => ele['ca_id'] == attribute.ca_id);
      if (this.mounted) {
        setState(() {
          selectedAttr.add({
            'ca_id': attribute.ca_id,
            'attribute': attribute,
            'attrType_ID': attrID,
            'attr_price': attrPrice,
          });
        });
      }
    }
    /*
    String changeDefault = "";
    if (attribute.attributeId != null) {
      for (int i = 0; i < listAttrId.length; i++) {
        if (listAttrId[i] == attrID.toString()) {
          changeDefault += "1";
        } else
          changeDefault += "0";
      }
    }
    attribute.is_default = changeDefault.split('').join(',');
    if (this.mounted) {
      setState(() {
        setMealAttributeList[productID].map((attr) {
          if (attr.attributeId == attribute.attributeId) {
            return attribute;
          }
          return attr;
        });
      });
    }
 */
    setPrice();
  }

  /*  onSelectSetmealAttr(id, attribute, attrTypeIDs, attrPrice, setmealproduct) {
    var prvSeelected = selectedSetMealAttr;
    var isSelected = selectedSetMealAttr.any((item) =>
        item['ca_id'] == id && item["setmeal_productID"] == setmealproduct);
    var isSelectedType =
        selectedSetMealAttr.any((item) => item["attribute"] == attribute);
    if (isSelectedType) {
    } else {
      if (isSelected) {
        var isarrSelected =
            selectedSetMealAttr.any((item) => item['attribute'] == attribute);
        selectedSetMealAttr.removeWhere((item) =>
            item['ca_id'] == id && item["setmeal_productID"] == setmealproduct);
        if (!isarrSelected) {
          prvSeelected.add({
            'product_id': productId,
            'setmeal_productID': setmealproduct,
            'ca_id': id,
            'attribute': attribute,
            'attrType_ID': attrTypeIDs,
            'attr_price': attrPrice
          });
        } else {
          selectedSetMealAttr.removeWhere((item) =>
              item['ca_id'] != id &&
              item["setmeal_productID"] != setmealproduct);
        }
        print(selectedSetMealAttr);
        setState(() {
          selectedSetMealAttr = selectedSetMealAttr;
          isFirstAttrSet = false;
        });
      } else if (selectedSetMealAttr.length < 1) {
        setState(() {
          selectedSetMealAttr = selectedSetMealAttr;
          isFirstAttrSet = true;
        });
      }
    }

    setPrice();
  } */

  increaseQty() async {
    if (isSetMeal) {
      var prevproductqty = productQty;
      setState(() {
        productQty = prevproductqty + 1;
      });
      setPrice();
    } else {
      if (productItem.hasInventory == 1) {
        List<ProductStoreInventory> cartval =
            await localAPI.checkItemAvailableinStore(productItem.productId);
        if (cartval.length > 0) {
          double storeqty = cartval[0].qty;
          if (storeqty > productQty) {
            var prevproductqty = productQty;
            setState(() {
              productQty = prevproductqty + 1;
            });
            setPrice();
          } else {
            CommunFun.showToast(context, Strings.stockNotValilable);
          }
        } else {
          var prevproductqty = productQty;
          setState(() {
            productQty = prevproductqty + 1;
          });
          setPrice();
        }
      } else {
        var prevproductqty = productQty;
        setState(() {
          productQty = prevproductqty + 1;
        });
        setPrice();
      }
    }
    await SyncAPICalls.logActivity(
        "product details", "Increased product qty", "product", 1);
  }

  decreaseQty() async {
    if (productQty > 1) {
      var prevproductqty = productQty;
      setState(() {
        productQty = prevproductqty - 1;
      });
      setPrice();
    }
    await SyncAPICalls.logActivity(
        "product details", "Decresed product qty", "product", 1);
  }

  onSelectAttr(
      i, id, attribute, attrTypeIDs, attrPrice, setmealid, isDefault) async {
    var prvSeelected = selectedAttr;
    var isSelected = selectedAttr.any((item) => item['ca_id'] == id);
    var isSelectedType =
        selectedAttr.any((item) => item['attribute'] == attribute);
    if (isSelectedType) {
    } else {
      if (isSelected) {
        var isarrSelected =
            selectedAttr.any((item) => item['attribute'] == attribute);

        selectedAttr.removeWhere((item) => item['ca_id'] == id);
        if (!isarrSelected) {
          prvSeelected.add({
            'ca_id': id,
            'attribute': attribute,
            'attrType_ID': attrTypeIDs,
            'attr_price': attrPrice,
          });
        } else {
          selectedAttr.removeWhere((item) => item['attribute'] != attribute);
          await SyncAPICalls.logActivity(
              "change attributes", "removed selected attribute", "product", 1);
        }
        setState(() {
          selectedAttr = selectedAttr;
          isFirstAttr = true;
        });
      } else {
        prvSeelected.add({
          'ca_id': id,
          'attribute': attribute,
          'attrType_ID': attrTypeIDs,
          'attr_price': attrPrice
        });
        setState(() {
          selectedAttr = prvSeelected;
          isFirstAttr = false;
        });
        await SyncAPICalls.logActivity(
            "change attributes", "Added product attributes", "product", 1);
      }
    }

    setPrice();
  }

  setPrice() {
    // print("setPrice");
    double productPrice = productnetprice;
    double newPrice = productPrice ?? price;
    for (int i = 0; selectedAttr.length > 0 && i < selectedAttr.length; i++) {
      var price = selectedAttr[i]["attr_price"];
      newPrice += double.parse(price);
    }
    if (!isSetMeal) {
      for (int i = 0;
          selectedModifier.length > 0 && i < selectedModifier.length;
          i++) {
        double mprice = selectedModifier[i].price;
        newPrice += mprice;
      }
    }
    double pricewithQty = newPrice * productQty;
    if (widget.selproduct.qty != null && widget.selproduct.qty > 0) {
      pricewithQty = newPrice * widget.selproduct.qty;
    }
    setState(() {
      price = pricewithQty;
    });
  }

  setModifire(ModifireData mod) async {
    var isSelected = selectedModifier.any((item) => item.pmId == mod.pmId);
    if (isSelected) {
      selectedModifier.removeWhere((item) => item.pmId == mod.pmId);
      setState(() {
        selectedModifier = selectedModifier;
      });
      await SyncAPICalls.logActivity(
          "change modifire", "removed selected product modifire", "product", 1);
    } else {
      selectedModifier.add(mod);
      await SyncAPICalls.logActivity(
          "change modifire", "Added product modifire", "product", 1);
    }
    setState(() {
      selectedModifier = selectedModifier;
    });

    setPrice();
  }

  updateCartItem() {
    produtAddTocart();
  }

  countTotalQty() {
    double qty = 0;
    if (cartItems.length > 0) {
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        if (isSetMeal) {
          if (item.productId == setmeal.setmealId) {
            item.productQty = productQty;
          }
        } else {
          if (item.productId == productItem.productId) {
            item.productQty = productQty;
          }
        }
        qty += item.productQty;
      }
      if (!isEditing) {
        qty += productQty;
      }
    } else {
      qty += productQty;
    }
    return qty;
  }

  countSubtotal() {
    double subT = 0;
    if (cartItems.length > 0) {
      double selectedITemTotal = 0;
      for (var i = 0; i < cartItems.length; i++) {
        var item = cartItems[i];
        selectedITemTotal += item.productDetailAmount;
      }
      if (isEditing) {
        if (!isSetMeal) {
          selectedITemTotal = selectedITemTotal - cartitem.productDetailAmount;
        } else {
          selectedITemTotal = selectedITemTotal - setmeal.price;
        }
      }
      subT = selectedITemTotal + price;
    } else {
      subT += price;
    }
    return subT;
  }

  countGrandtotal(subt, serviceCharge, tax, dis) {
    double grandTotal = 0;
    grandTotal = (((subt - dis) + serviceCharge) + tax);
    return grandTotal;
  }

  _setSelectUnselect(SetMealProduct product) async {
    var isSelected = tempCart
        .any((item) => item.setmealProductId == product.setmealProductId);
    if (isSelected) {
      tempCart.removeWhere(
          (item) => item.setmealProductId == product.setmealProductId);
      setState(() {
        tempCart = tempCart;
      });
      await SyncAPICalls.logActivity("setmeal attributes",
          "removed setmeal product attributes", "product", 1);
    } else {
      tempCart.add(product);
      setState(() {
        tempCart = tempCart;
      });
      await SyncAPICalls.logActivity("setmeal attributes",
          "removed added product attributes", "product", 1);
    }
  }

  countTax(subT) async {
    Table_order tableData = await CommunFun.getTableData();
    var subtNServ = subT +
        await CommunFun.countServiceCharge(tableData.service_charge, subT);
    var totalTax = [];
    double taxvalue = taxvalues;
    if (taxlist.length > 0) {
      for (var i = 0; i < taxlist.length; i++) {
        var taxlistitem = taxlist[i];
        // List<Tax> tax = await localAPI.getTaxName(taxlistitem.taxId);
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
          "taxAmount": taxval.toStringAsFixed(2),
          "taxCode": taxlistitem.code
        };
        totalTax.add(taxmap);
      }
    }
    return totalTax;
  }

  countDiscount() {
    return currentCart.discountAmount != null
        ? double.parse(currentCart.discountAmount.toStringAsFixed(2))
        : 0.00;
  }

  addToReservation() async {
    var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
    var loginData = await json.decode(loginUser);
    ProductDetails cartItemproduct = new ProductDetails();
    if (!isSetMeal) {
      cartItemproduct.qty = productQty;
      cartItemproduct.status = productItem.status;
      cartItemproduct.productId = productItem.productId;
      cartItemproduct.name = productItem.name;
      cartItemproduct.uuid = productItem.uuid;
      cartItemproduct.price = productItem.price;
    } else {
      cartItemproduct.qty = productQty;
      cartItemproduct.status = setmeal.status;
      cartItemproduct.productId = setmeal.setmealId;
      cartItemproduct.name = setmeal.name;
      cartItemproduct.uuid = setmeal.uuid;
      cartItemproduct.price = setmeal.price;
    }
    MSTCartdetails cartdetails = new MSTCartdetails();
    if (isEditing) {
      cartdetails.id = cartitem.id;
    }
    //cartdetails.cartId = cartid;
    cartdetails.productId =
        isSetMeal ? setmeal.setmealId : productItem.productId;
    cartdetails.productName = isSetMeal ? setmeal.name : productItem.name;
    cartdetails.productSecondName = isSetMeal ? "" : productItem.name_2;
    cartdetails.productPrice = isSetMeal ? setmeal.price : productItem.price;
    cartdetails.productDetailAmount = double.parse(price.toStringAsFixed(2));
    cartdetails.productQty = productQty.toDouble();
    cartdetails.productNetPrice =
        productItem.oldPrice != null ? productItem.oldPrice : 0.0;
    cartdetails.createdBy = loginData["id"];
    cartdetails.cart_detail = jsonEncode(cartItemproduct);
    cartdetails.discountAmount = 0;
    cartdetails.localID = await CommunFun.getLocalID();
    cartdetails.remark =
        extraNotes.text.trim().isNotEmpty ? extraNotes.text.trim() : "";
    cartdetails.issetMeal = isSetMeal ? 1 : 0;
    cartdetails.taxValue = taxvalues;
    cartdetails.printer_id = printer != null ? printer.printerId : 0;
    cartdetails.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    if (isSetMeal) {
      cartdetails.setmeal_product_detail = json.encode(mealProducts);
    }
    List<MSTSubCartdetails> modifierSelected = [];
    List<MSTSubCartdetails> attrSelected = [];
    if (selectedModifier != null && selectedModifier.length > 0) {
      for (var i = 0; i < selectedModifier.length; i++) {
        MSTSubCartdetails subCartData = new MSTSubCartdetails();
        var modifire = selectedModifier[i];
        subCartData.productId = productItem.productId;
        subCartData.modifierId = modifire.modifierId;
        subCartData.modifirePrice = modifire.price;
        modifierSelected.add(subCartData);
        //await localAPI.addsubCartData(subCartData);
      }
    }
    for (var i = 0; i < selectedAttr.length; i++) {
      var attr = selectedAttr[i];
      MSTSubCartdetails subCartData = new MSTSubCartdetails();
      subCartData.productId = productItem.productId;
      subCartData.caId = attr["ca_id"];
      subCartData.attributeId = attr["attrType_ID"] is int
          ? attr["attrType_ID"]
          : int.parse(attr["attrType_ID"]);
      subCartData.attrPrice = double.parse(attr["attr_price"]).toDouble();
      attrSelected.add(subCartData);
      //await localAPI.addsubCartData(subCartData);
    }
    await SyncAPICalls.logActivity(
        "product details", "Added items to cart", "cart", 1);
    Navigator.of(context).pop();
    widget.addReservation(cartdetails, modifierSelected, attrSelected);
  }

  produtAddTocart() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (widget.cartID == null && widget.addReservation != null) {
        return addToReservation();
      }
      MST_Cart cart = new MST_Cart(); 
  
      var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
      var loginData = await json.decode(loginUser);   

      Table_order tableData = await CommunFun.getTableData(); // table data  

      if (currentCart != null) {
        cart.id = currentCart.id; 
      } 

      var cartid = await localAPI.insertItemTocart(
          loginData['id'], 
          currentCart.id, 
          tableData.table_id, 
          productItem.productId, 
          productQty == null?0:productQty.toInt(), 
          selectedModifier.map((e) => e.modifierId).toList(),
          selectedAttr.map<int>((e) => e["attrType_ID"] is int
            ? e["attrType_ID"]
            : int.parse(e["attrType_ID"])).toList(),
          isSetMeal,
          extraNotes.text
        );

      await SyncAPICalls.logActivity(
          "product details", "Added items to cart", "cart", 1);
      Navigator.of(context).pop();
      widget.onClose();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      CommunFun.showToast(context, 'There is something went wrong.');
      print(error.toString());
    }
  }


  // produtAddTocart() async {
  //   if (widget.cartID == null && widget.addReservation != null) {
  //     return addToReservation();
  //   }
  //   MST_Cart cart = new MST_Cart();

  //   //MSTSubCartdetails subCartData = new MSTSubCartdetails();
  //   SaveOrder orderData = new SaveOrder();

  //   var branchid = await CommunFun.getbranchId();
  //   var loginUser = await Preferences.getStringValuesSF(Constant.LOIGN_USER);
  //   var loginData = await json.decode(loginUser);
  //   var customerData =
  //       await Preferences.getStringValuesSF(Constant.CUSTOMER_DATA);
  //   var customer =
  //       customerData != null ? json.decode(customerData) : customerData;
  //   var customerid = customer != null ? customer["customer_id"] : 0;
  //   Table_order tableData = await CommunFun.getTableData(); // table data
  //   var qty = await countTotalQty();
  //   var disc = await countDiscount();
  //   var subtotal = await countSubtotal();
  //   var serviceCharge = 
  //       await CommunFun.countServiceCharge(tableData.service_charge, subtotal);
  //   var serviceChargePer = tableData.service_charge == null
  //       ? await CommunFun.getServiceChargePer()
  //       : tableData.service_charge;

  //   var totalTax = await countTax(subtotal);
  //   var grandTotal =
  //       await countGrandtotal(subtotal, serviceCharge, taxvalues, disc);

  //   //cart data

  //   if (currentCart != null) {
  //     cart.id = currentCart.id;
  //     cart.discountType = currentCart.discountType;
  //     cart.voucher_detail = currentCart.voucher_detail;
  //     cart.voucher_id = cart.voucher_id;
  //   }
  //   cart.user_id = customerid;
  //   cart.branch_id = int.parse(branchid);
  //   cart.sub_total = double.parse(subtotal.toStringAsFixed(2));
  //   cart.serviceCharge = CommunFun.getDoubleValue(serviceCharge);
  //   cart.serviceChargePercent = CommunFun.getDoubleValue(serviceChargePer);
  //   cart.discountAmount = disc;
  //   cart.table_id = tableData.table_id;
  //   cart.total_qty = qty;
  //   cart.tax = double.parse(taxvalues.toStringAsFixed(2));
  //   cart.source = 2;
  //   cart.tax_json = json.encode(totalTax);
  //   cart.grand_total = double.parse(grandTotal.toStringAsFixed(2));
  //   cart.customer_terminal = customer != null ? customer["terminal_id"] : 0;
  //   cart.created_by = loginData["id"];
  //   cart.localID = await CommunFun.getLocalID();
  //   cart.created_at = await CommunFun.getCurrentDateTime(DateTime.now());
  //   orderData.orderName = tableData != null ? "" : "test";
  //   orderData.numberofPax = tableData != null ? tableData.number_of_pax : 0;
  //   orderData.isTableOrder = tableData != null ? 1 : 0;
  //   if (!isEditing) {
  //     orderData.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
  //   }

  //   var cartid = await localAPI.insertItemTocart(
  //     loginUser, currentCart.id, cart, productItem, orderData, tableData.table_id);
  //   ProductDetails cartItemproduct = new ProductDetails();
  //   if (!isSetMeal) {
  //     cartItemproduct.qty = productQty;
  //     cartItemproduct.status = productItem.status;
  //     cartItemproduct.productId = productItem.productId;
  //     cartItemproduct.name = productItem.name;
  //     cartItemproduct.uuid = productItem.uuid;
  //     cartItemproduct.price = productItem.price;
  //   } else {
  //     cartItemproduct.qty = productQty;
  //     cartItemproduct.status = setmeal.status;
  //     cartItemproduct.productId = setmeal.setmealId;
  //     cartItemproduct.name = setmeal.name;
  //     cartItemproduct.uuid = setmeal.uuid;
  //     cartItemproduct.price = setmeal.price;
  //   }
  //   cartItemproduct
  //       .toJson()
  //       .removeWhere((String key, dynamic value) => value == null);
  //   var data = cartItemproduct;
  //   MSTCartdetails cartdetails = new MSTCartdetails();
  //   if (isEditing) {
  //     cartdetails.id = cartitem.id;
  //   }
  //   cartdetails.cartId = cartid;
  //   cartdetails.productId =
  //       isSetMeal ? setmeal.setmealId : productItem.productId;
  //   cartdetails.productName = isSetMeal ? setmeal.name : productItem.name;
  //   cartdetails.productSecondName = isSetMeal ? "" : productItem.name_2;
  //   cartdetails.productPrice = isSetMeal ? setmeal.price : productItem.price;
  //   cartdetails.productDetailAmount = double.parse(price.toStringAsFixed(2));
  //   cartdetails.productQty = productQty.toDouble();
  //   cartdetails.productNetPrice =
  //       productItem.oldPrice != null ? productItem.oldPrice : 0.0;
  //   cartdetails.createdBy = loginData["id"];
  //   cartdetails.cart_detail = jsonEncode(data);
  //   cartdetails.discountAmount = 0;
  //   cartdetails.localID = await CommunFun.getLocalID();
  //   cartdetails.remark =
  //       extraNotes.text.trim().isNotEmpty ? extraNotes.text.trim() : "";
  //   cartdetails.issetMeal = isSetMeal ? 1 : 0;
  //   cartdetails.taxValue = taxvalues;
  //   cartdetails.printer_id = printer != null ? printer.printerId : 0;
  //   cartdetails.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
  //   if (isSetMeal) {
  //     cartdetails.setmeal_product_detail = json.encode(mealProducts);
  //   }
  //   var detailID = await localAPI.addintoCartDetails(cartdetails);
  //   await localAPI.deletesubcartDetail(detailID);
  //   if (selectedModifier.length > 0) {
  //     for (var i = 0; i < selectedModifier.length; i++) {
  //       MSTSubCartdetails subCartData = new MSTSubCartdetails();
  //       var modifire = selectedModifier[i];

  //       subCartData.cartdetailsId = detailID;
  //       subCartData.localID = cart.localID;
  //       subCartData.productId = productItem.productId;
  //       subCartData.modifierId = modifire.modifierId;
  //       subCartData.caId = cart.id;
  //       subCartData.modifirePrice = modifire.price;
  //       int addedID = await localAPI.addsubCartData(subCartData);
  //       print(addedID);
  //     }
  //   }
  //   for (var i = 0; i < selectedAttr.length; i++) {
  //     var attr = selectedAttr[i];
  //     MSTSubCartdetails subCartData = new MSTSubCartdetails();
  //     subCartData.cartdetailsId = detailID;
  //     subCartData.localID = cart.localID;
  //     subCartData.productId = productItem.productId;
  //     subCartData.caId = attr["ca_id"];
  //     subCartData.attributeId = attr["attrType_ID"] is int
  //         ? attr["attrType_ID"]
  //         : int.parse(attr["attrType_ID"]);
  //     subCartData.attrPrice = double.parse(attr["attr_price"]).toDouble();
  //     await localAPI.addsubCartData(subCartData);
  //   }
  //   if (isEditing) {
  //     if (!isSetMeal) {
  //       if (cartitem.isSendKichen == 1) {
  //         var items = [];
  //         items.add(cartitem);
  //         //senditemtoKitchen(items);
  //       }
  //     }
  //   }
  //   await SyncAPICalls.logActivity(
  //       "product details", "Added items to cart", "cart", 1);
  //   Navigator.of(context).pop();
  //   widget.onClose();
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
        height: SizeConfig.safeBlockVertical * 9,
        color: StaticColor.colorBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              isSetMeal
                  ? setmeal.name.toUpperCase()
                  : productItem.name.toUpperCase(),
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockVertical * 3,
                  color: StaticColor.colorWhite),
            ),
            Spacer(),

            CloseButtonWidget(inputContext: context),
            
            /* GestureDetector(
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
                ), */
            //addbutton(context)
          ],
        ),
      ), // close button

      content: mainContent(),
      //main part of the popup
      actions: <Widget>[
        // Button div + - buttons
        Container(
          width: MediaQuery.of(context).size.width / 1.4,
          child: Column(
            children: <Widget>[
              CommunFun.divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isSetMeal
                          ? currency != null
                              ? currency +
                                  " " +
                                  price.toStringAsFixed(2).toString()
                              : price.toStringAsFixed(2).toString()
                          : currency != null
                              ? currency +
                                  " " +
                                  price.toStringAsFixed(2).toString()
                              : price.toStringAsFixed(2).toString(),
                      style: Styles.orangeLarge(),
                    ),
                    Spacer(),
                    buttonContainer(),
                    Spacer(),
                    isLoading 
                      ? SpinKitCircle(color: Colors.black, size: 30.0)
                      : Container(),
                    Spacer(),
                    addbutton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buttonContainer() {
    return Container(
      child: Row(
        children: <Widget>[
          _button("-", () async {
            if (permissions.contains(Constant.CHANGE_QUANTITY)) {
              decreaseQty();
            } else {
              await SyncAPICalls.logActivity("change Qty",
                  "Cashier has no permission for change Qty", "change qty", 1);
              CommonUtils.openPermissionPop(context, Constant.CHANGE_QUANTITY,
                  () async {
                await increaseQty();
                await SyncAPICalls.logActivity("change Qty",
                    "manager given permission for change Qty", "change qty", 1);
              }, () {});
            }
          }),
          _quantityTextInput(),
          _button("+", () async {
            if (permissions.contains(Constant.CHANGE_QUANTITY)) {
              increaseQty();
            } else {
              await SyncAPICalls.logActivity("change Qty",
                  "Cashier has no permission for change Qty", "change qty", 1);
              await CommonUtils.openPermissionPop(
                  context, Constant.CHANGE_QUANTITY, () async {
                await increaseQty();
                await SyncAPICalls.logActivity("change Qty",
                    "manager given permission for change Qty", "change qty", 1);
              }, () {});
            }
          }),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width / 1.8,
      height: MediaQuery.of(context).size.height / 1.8,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            isSetMeal ? getMealsProductList() : getAttributeList(),
            (isSetMeal || modifireList.length == 0)
                ? SizedBox()
                : Text(
                    Strings.modifier,
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
                  ),
            SizedBox(height: 5),
            (isSetMeal || modifireList.length == 0)
                ? SizedBox()
                : modifireItmeList(),
            SizedBox(height: 10),
            _extraNotesTitle(),
            SizedBox(height: 5),
            inputNotesView(),
          ],
        ),
      ),
    );
  }

  Widget getMealsProductList() {
    return isSetMeal && !isEditing
        ? Container(
            // color: StaticColor.colorGreen,
            height: MediaQuery.of(context).size.height / 2.1,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: mealProducts.map((product) {
                    //var index = mealProducts.indexOf(product);
                    return InkWell(
                        onTap: () {
                          //_setSelectUnselect(product);
                          //  getAttributes(product.productId);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: new BoxDecoration(
                              color: StaticColor.lightGrey100,
                              borderRadius: BorderRadius.circular(8.0)),
                          /* color: tempCart
                              .where((element) =>
                                  element.setmealProductId ==
                                  product.setmealProductId)
                              .isNotEmpty
                          ? StaticColor.colorGrey[100]
                          : StaticColor.colorWhite,*/
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Hero(
                                    tag: product.productId,
                                    child: new Stack(
                                      children: [
                                        Container(
                                          height:
                                              SizeConfig.safeBlockVertical * 8,
                                          width:
                                              SizeConfig.safeBlockVertical * 9,
                                          child: product.base64 != "" &&
                                                  product.base64 != null
                                              ? CommonUtils
                                                  .imageFromBase64String(
                                                      product.base64)
                                              : new Image.asset(
                                                  Strings.noImageAsset,
                                                  fit: BoxFit.cover,
                                                  gaplessPlayback: true,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Flexible(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(product.name.toUpperCase(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: Styles.smallBlack())
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(product.quantity.toString(),
                                            style: Styles.smallBlack()),
                                        SizedBox(width: 90),
                                        Icon(
                                          tempCart
                                                  .where((element) =>
                                                      element
                                                          .setmealProductId ==
                                                      product.setmealProductId)
                                                  .isNotEmpty
                                              ? Icons.check_circle
                                              : Icons.check_circle_outline,
                                          color: StaticColor.colorGreen,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              getsetMealAttrList(product),
                            ],
                          ),
                        ));
                  }).toList()),
            ),
          )
        : Container(
            // color: StaticColor.colorGreen,
            height: MediaQuery.of(context).size.height / 2.1,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: mealProducts.map((product) {
                    //var index = mealProducts.indexOf(product);
                    return InkWell(
                        onTap: () {
                          _setSelectUnselect(product);
                          //  getAttributes(product.productId);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: new BoxDecoration(
                              color: StaticColor.lightGrey100,
                              borderRadius: BorderRadius.circular(8.0)),
                          /* color: tempCart
                              .where((element) =>
                                  element.setmealProductId ==
                                  product.setmealProductId)
                              .isNotEmpty
                          ? StaticColor.colorGrey[100]
                          : StaticColor.colorWhite,*/
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Hero(
                                    tag: product.productId,
                                    child: new Stack(
                                      children: [
                                        Container(
                                          height:
                                              SizeConfig.safeBlockVertical * 8,
                                          width:
                                              SizeConfig.safeBlockVertical * 9,
                                          child: product.base64 != "" &&
                                                  product.base64 != null
                                              ? CommonUtils
                                                  .imageFromBase64String(
                                                      product.base64)
                                              : new Image.asset(
                                                  Strings.noImageAsset,
                                                  fit: BoxFit.cover,
                                                  gaplessPlayback: true,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Flexible(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(product.name.toUpperCase(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: Styles.smallBlack())
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(product.quantity.toString(),
                                            style: Styles.smallBlack()),
                                        SizedBox(width: 90),
                                        Icon(
                                          tempCart
                                                  .where((element) =>
                                                      element
                                                          .setmealProductId ==
                                                      product.setmealProductId)
                                                  .isNotEmpty
                                              ? Icons.check_circle
                                              : Icons.check_circle_outline,
                                          color: StaticColor.colorGreen,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              getsetMealAttrList(product),
                            ],
                          ),
                        ));
                  }).toList()),
            ),
          );
  }

  Widget getsetMealAttrList(SetMealProduct product) {
    List<Attribute_Data> attrList = setMealAttributeList[product.productId];
    /* if (product.attributeDetails != "" && product.attributeDetails != null) {
      List<dynamic> attrdata = jsonDecode(product.attributeDetails);
      attrList = attrdata.isNotEmpty
          ? attrdata.map((c) => Attribute_Data.fromJson(c)).toList()
          : [];
    } */

    return attrList == null
        ? Container()
        : Container(
            //color: StaticColor.colorWhite,
            margin: EdgeInsets.only(bottom: isSetMeal ? 0 : 10, top: 0),
            // MediaQuery.of(context).size.height /8,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              children: attrList.map(
                (attribute) {
                  Map<int, Map<String, dynamic>> attrOption = new Map();
                  if (attribute.attributeId != null) {
                    List<String> listAttrId = attribute.attributeId.split(',');
                    List<String> listIsDefault =
                        attribute.is_default.split(',');
                    List<String> listAttrTypes =
                        attribute.attr_types.split(',');
                    List<String> listAttrPrice =
                        attribute.attr_types_price.split(',');
                    for (int i = 0; i < listAttrId.length; i++) {
                      int attrIds = int.tryParse(listAttrId[i]);
                      attrOption[attrIds] = new Map();
                      attrOption[attrIds]["selected"] = i < listIsDefault.length
                          ? int.tryParse(listIsDefault[i])
                          : 0;
                      attrOption[attrIds]["types"] =
                          i < listAttrTypes.length ? listAttrTypes[i] : "";
                      attrOption[attrIds]["price"] =
                          i < listAttrPrice.length ? listAttrPrice[i] : "";
                    }
                  }
                  /* var attributType = [];

            Map attrIDs;
            Map attrtypesPrice;
            Map attrDefault;
            if (attribute.ca_id != null) {
              attrDefault = attribute.is_default.split(',').asMap();
              attributType = attribute.attr_types.split(',');
              attrIDs = attribute.attributeId.split(',').asMap();
              attrtypesPrice = attribute.attr_types_price.split(',').asMap();
            } */

                  /*Set attribute name for selection toast*/
                  return attribute.ca_id != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              attribute.attr_name != null
                                  ? attribute.attr_name
                                  : "",
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 3),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8.0),
                              height: SizeConfig.safeBlockVertical * 9,
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: attrOption.entries.map(
                                  (entry) {
                                    return Padding(
                                      padding: EdgeInsets.all(5),
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            //entry.value["selected"] == 1
                                            color: selectedAttr.any((ele) =>
                                                    ele["attrType_ID"] ==
                                                    entry.key)
                                                ? StaticColor.colorGreen
                                                : StaticColor.colorGrey400,
                                            width: 4,
                                          ),
                                        ),
                                        minWidth: 50,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              entry.value["types"].toString(),
                                              style: Styles.blackMediumBold(),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              double.parse(entry.value["price"])
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: StaticColor.deepOrange,
                                                  fontSize: SizeConfig
                                                          .safeBlockVertical *
                                                      2.5),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          updateAttribute(
                                            product.productId,
                                            attribute,
                                            attribute.attributeId.split(','),
                                            entry.key,
                                            entry.value["price"],
                                          );
                                          /* onSelectSetmealAttr(
                                        attribute.ca_id,
                                        entry.value["types"],
                                        entry.key,
                                        entry.value["price"],
                                        product.setmealProductId); */
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),

                                /* attributType
                              .asMap()
                              .map(
                                (i, attr) {
                                  return MapEntry(
                                    i,
                                    
                                },
                              )
                              .values
                              .toList(), */
                              ),
                            )
                          ],
                        )
                      : SizedBox();
                },
              ).toList(),
            ),
          );
  }

  Widget getAttributeList() {
    return Container(
      //color: StaticColor.colorWhite,
      margin: EdgeInsets.only(bottom: isSetMeal ? 0 : 10, top: 0),
      // MediaQuery.of(context).size.height /8,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        children: attributeList.map((attribute) {
          var attributType = attribute.attr_types.split(',');
          var attrIDs = attribute.attributeId.split(',').asMap();
          var attrtypesPrice = attribute.attr_types_price.split(',').asMap();
          var attributisDefault = attribute.is_default.split(',');
          /*Set attribute name for selection toast*/
          attributeTitle = attribute.attr_name;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              isSetMeal ? SizedBox() : SizedBox(height: 10),
              isSetMeal
                  ? SizedBox()
                  : Text(
                      attribute.attr_name != null ? attribute.attr_name : "",
                      style:
                          TextStyle(fontSize: SizeConfig.safeBlockVertical * 3),
                    ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
                  height: SizeConfig.safeBlockVertical * 9,
                  child: ListView(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: attributType
                          .asMap()
                          .map((i, attr) {
                            var isadded = selectedAttr.any(
                              (item) =>
                                  item['ca_id'] == attribute.ca_id &&
                                  item['attribute'] == attr,
                            );
                            if (!isEditing) {
                              if (attributisDefault[i] == "1" &&
                                  !isadded &&
                                  !isFirstAttr) {
                                var prvSeelected = selectedAttr;
                                prvSeelected.add({
                                  'ca_id': attribute.ca_id,
                                  'attribute': attr,
                                  'attrType_ID': attrIDs[i],
                                  'attr_price': attrtypesPrice[i]
                                });
                                setState(() {
                                  selectedAttr = prvSeelected;
                                  // isFirstAttr = true;
                                  // setPrice();
                                });
                              }
                            } else {
                              if (isadded && isFirstAttr) {
                                setState(() {
                                  isFirstAttr = true;
                                  // setPrice();
                                });
                              }
                            }

                            return MapEntry(
                                i,
                                Padding(
                                    padding: EdgeInsets.all(5),
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            color: selectedAttr.any((item) =>
                                                    item['ca_id'] ==
                                                        attribute.ca_id &&
                                                    item['attribute'] == attr)
                                                ? StaticColor.colorGreen
                                                : StaticColor.colorGrey300,
                                            width: 4,
                                          )),
                                      minWidth: 50,
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            attr.toString(),
                                            style: Styles.blackMediumBold(),
                                          ),
                                          double.tryParse(attrtypesPrice[i]) !=
                                                  0
                                              ? SizedBox(width: 10)
                                              : SizedBox(),
                                          double.tryParse(attrtypesPrice[i]) !=
                                                  0
                                              ? Text(
                                                  double.parse(
                                                          attrtypesPrice[i])
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      color: StaticColor
                                                          .deepOrange,
                                                      fontSize: SizeConfig
                                                              .safeBlockVertical *
                                                          2.5),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                      textColor: StaticColor.colorBlack,
                                      color: StaticColor.colorGrey300,
                                      onPressed: () {
                                        onSelectAttr(
                                            i,
                                            attribute.ca_id,
                                            attr,
                                            attrIDs[i],
                                            attrtypesPrice[i],
                                            null,
                                            attributisDefault[i]);
                                      },
                                    )));
                          })
                          .values
                          .toList()))
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget modifireItmeList() {
    return Container(
      height: SizeConfig.safeBlockVertical * 9,
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: modifireList.map(
          (modifier) {
            //bool isadded = selectedModifier.any((item) => item.pmId == modifier.pmId);
            // if (modifier.isDefault == 1 && selectedModifier.length == 0) {
            //   setState(() {
            //     setPrice();
            //     selectedModifier.add(modifier);
            //     isFirstMod = true;
            //   });
            // }
            return Padding(
              padding: EdgeInsets.all(5),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: selectedModifier
                                .any((item) => item.pmId == modifier.pmId)
                            ? StaticColor.colorGreen
                            : StaticColor.colorGrey300,
                        width: 4)),
                minWidth: 50,
                child: Row(
                  children: <Widget>[
                    Text(
                      modifier.name.toString(),
                      style: Styles.blackMediumBold(),
                    ),
                    SizedBox(width: 10),
                    Text(
                      modifier.price.toStringAsFixed(2).toString(),
                      style: TextStyle(
                          color: StaticColor.deepOrange,
                          fontSize: SizeConfig.safeBlockVertical * 2.5),
                    ),
                  ],
                ),
                textColor: StaticColor.colorBlack,
                color: StaticColor.colorGrey300,
                onPressed: () {
                  setModifire(modifier);
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _sizeTitle() {
    return Text(
      Strings.size,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: StaticColor.colorGrey800),
    );
  }

  Widget _extraNotesTitle() {
    return Text(
      Strings.notesAndQty,
      style: TextStyle(
          fontSize: SizeConfig.safeBlockVertical * 3,
          fontWeight: FontWeight.w400,
          color: StaticColor.colorGrey800),
    );
  }

  Widget inputNotesView() {
    return Container(
        padding: EdgeInsets.all(10),
        //height: 170, // MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: StaticColor.lightGrey100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[notesInput()],
          ),
        ));
  }

  Widget notesInput() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: extraNotes,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: SizeConfig.safeBlockVertical * 3, height: 1.4),
          maxLines: 2,
          decoration: new InputDecoration(
            border: InputBorder.none,
            // hintText: productQty.toDouble().toString(),
          ),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _quantityTextInput() {
    return Container(
      height: 40,
      width: 100,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: StaticColor.colorGrey)),
      child: Center(
        child: Text(productQty.toStringAsFixed(0),
            // " " +
            // (!isSetMeal
            //     ? productItem.priceTypeName != null
            //         ? productItem.priceTypeName
            //         : ""
            //     : ""
            //     ),
            style: TextStyle(color: StaticColor.colorGrey, fontSize: 20)),
      ),
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        height: 40,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: StaticColor.colorWhite,
                fontWeight: FontWeight.bold,
                fontSize: 30.0)),
        textColor: StaticColor.colorBlack,
        color: StaticColor.deepOrange,
        onPressed: f,
      ),
    );
  }

  Widget addbutton(context) {
    return MaterialButton(
      height: 40,
      onPressed: () {
        if (attributeList.length > 0) {
          if (selectedAttr.length > 0) {
            if (isEditing) {
              updateCartItem();
            } else {
              produtAddTocart();
            }
          } else {
            CommunFun.showToast(context, "Please select " + attributeTitle);
          }
        } else {
          if (isEditing) {
            updateCartItem();
          } else {
            produtAddTocart();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !isEditing
                ? Icon(
                    Icons.add_circle_outline,
                    color: StaticColor.colorWhite,
                    size: SizeConfig.safeBlockVertical * 3.5,
                  )
                : Icon(
                    Icons.edit,
                    color: StaticColor.colorWhite,
                    size: SizeConfig.safeBlockVertical * 3.5,
                  ),
            SizedBox(width: 6),
            Text(
              isEditing ? Strings.update : Strings.add,
              style: TextStyle(
                color: StaticColor.colorWhite,
                fontSize: SizeConfig.safeBlockVertical * 3,
              ),
            ),
          ],
        ),
      ),
      color: StaticColor.deepOrange,
      textColor: StaticColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
