class OrderDetail {
  int detailId;
  String uuid;
  int order_id;
  int branch_id;
  int terminal_id;
  int app_id;
  int product_id;
  double product_price;
  double product_old_price;
  int category_id;
  int detail_attribute_id;
  double detail_attribute_price;
  double detail_amount;
  double detail_qty;
  int detail_status;
  int detail_by;

  OrderDetail({
    this.detailId,
    this.uuid,
    this.order_id,
    this.branch_id,
    this.terminal_id,
    this.app_id,
    this.product_id,
    this.product_price,
    this.product_old_price,
    this.category_id,
    this.detail_attribute_id,
    this.detail_attribute_price,
    this.detail_amount,
    this.detail_qty,
    this.detail_status,
    this.detail_by,
  });

  OrderDetail.fromJson(Map<String, dynamic> json) {
    detailId = json["detail_id"];
    uuid = json["uuid"];
    order_id = json["order_id"];
    branch_id = json["branch_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    product_id = json["product_id"];
    product_price = json["product_price"];
    product_old_price = json["product_old_price"];
    category_id = json["category_id"];
    detail_attribute_id = json["detail_attribute_id"];
    detail_attribute_price = json["detail_attribute_price"];
    detail_amount = json["detail_amount"];
    detail_qty = json["detail_qty"];
    detail_status = json["detail_status"];
    detail_by = json["detail_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["detail_id"] = this.detailId;
    data["uuid"] = this.uuid;
    data["order_id"] = this.order_id;
    data["branch_id"] = this.branch_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["product_id"] = this.product_id;
    data["product_price"] = this.product_price;
    data["product_old_price"] = this.product_old_price;
    data["category_id"] = this.category_id;
    data["detail_attribute_id"] = this.detail_attribute_id;
    data["detail_attribute_price"] = this.detail_attribute_price;
    data["detail_amount"] = this.detail_amount;
    data["detail_qty"] = this.detail_qty;
    data["detail_status"] = this.detail_status;
    data["detail_by"] = this.detail_by;
    return data;
  }
}