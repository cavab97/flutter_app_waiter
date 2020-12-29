class MST_Cart {
  int id;
  String localID;
  int user_id;
  int branch_id;
  double sub_total;
  String remark;
  int table_id;
  double tax;
  String tax_json;
  double grand_total;
  double total_qty;
  int is_deleted;
  int created_by;
  String created_at;
  String cart_order_number;
  int customer_terminal;
  int voucher_id;
  String voucher_detail;
  double sub_total_after_discount;
  int source;
  double total_item;
  int cart_payment_id;
  String cart_payment_response;
  int cart_payment_status;
  double serviceChargePercent;
  double serviceCharge;
  double discountAmount;
  int discountType;
  String discountRemark;

  MST_Cart({
    this.id,
    this.localID,
    this.user_id,
    this.branch_id,
    this.sub_total,
    this.remark,
    this.table_id,
    this.tax,
    this.tax_json,
    this.voucher_id,
    this.grand_total,
    this.total_qty,
    this.is_deleted,
    this.created_by,
    this.created_at,
    this.customer_terminal,
    this.voucher_detail,
    this.sub_total_after_discount,
    this.source,
    this.total_item,
    this.cart_order_number,
    this.cart_payment_id,
    this.cart_payment_response,
    this.cart_payment_status,
    this.serviceChargePercent,
    this.serviceCharge,
    this.discountAmount,
    this.discountType,
    this.discountRemark,
  });

  MST_Cart.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    localID = json["localID"];
    user_id = json["user_id"];
    branch_id = json["branch_id"];
    sub_total = json["sub_total"] is int
        ? (json['sub_total'] as int).toDouble()
        : json['sub_total'];
    table_id = json["table_id"];
    remark = json["remark"];
    tax = json["tax"] is int ? (json['tax'] as int).toDouble() : json['tax'];
    tax_json = json["tax_json"];
    grand_total = json["grand_total"] is int
        ? (json['grand_total'] as int).toDouble()
        : json['grand_total'];
    total_qty = json["total_qty"] is int
        ? (json['total_qty'] as int).toDouble()
        : json['total_qty'];
    voucher_id = json["voucher_id"];
    is_deleted = json["is_deleted"];
    created_by = json["created_by"];
    created_at = json["created_at"];
    customer_terminal = json["customer_terminal"];
    voucher_detail = json["voucher_detail"];
    sub_total_after_discount = json["sub_total_after_discount"] is int
        ? (json['sub_total_after_discount'] as int).toDouble()
        : json['sub_total_after_discount'];
    source = json["source"];
    total_item = json["total_item"] is int
        ? (json['total_item'] as int).toDouble()
        : json['total_item'];
    cart_order_number = json["cart_order_number"];
    cart_payment_id = json["cart_payment_id"];
    cart_payment_response = json["cart_payment_response"];
    cart_payment_status = json["cart_payment_status"];
    serviceChargePercent = json["service_charge_percent"] is int
        ? (json['service_charge_percent'] as int).toDouble()
        : json['service_charge_percent'];
    serviceCharge = json["service_charge"] is int
        ? (json['service_charge'] as int).toDouble()
        : json['service_charge'];
    discountAmount = json["discount_amount"] is int
        ? (json['discount_amount'] as int).toDouble()
        : json["discount_amount"];
    discountType = json["discount_type"];
    discountRemark = json['discount_remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["id"] = this.id;
    data["localID"] = this.localID;
    data["user_id"] = this.user_id;
    data["branch_id"] = this.branch_id;
    data["sub_total"] = this.sub_total;
    data["remark"] = this.remark;
    data["table_id"] = this.table_id;
    data["tax"] = this.tax;
    data["tax_json"] = this.tax_json;
    data["grand_total"] = this.grand_total;
    data["total_qty"] = this.total_qty;
    data["voucher_id"] = this.voucher_id;
    data["is_deleted"] = this.is_deleted;
    data["created_by"] = this.created_by;
    data["created_at"] = this.created_at;
    data["voucher_detail"] = this.voucher_detail;
    data["sub_total_after_discount"] = this.sub_total_after_discount;
    data["source"] = this.source;
    data["total_item"] = this.total_item;
    data["cart_order_number"] = this.cart_order_number;
    data["cart_payment_id"] = this.cart_payment_id;
    data["cart_payment_response"] = this.cart_payment_response;
    data["cart_payment_status"] = this.cart_payment_status;
    data["customer_terminal"] = this.customer_terminal;
    data["service_charge_percent"] = this.serviceChargePercent;
    data["service_charge"] = this.serviceCharge;
    data["discount_amount"] = this.discountAmount;
    data["discount_type"] = this.discountType;
    data["discount_remark"] = this.discountRemark;
    return data;
  }
}
