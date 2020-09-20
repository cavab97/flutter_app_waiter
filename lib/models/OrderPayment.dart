class OrderPayment {
  int op_id;
  String uuid;
  int order_id;
  int branch_id;
  int terminal_id;
  int app_id;
  int op_method_id;
  double op_amount;
  String op_method_response;
  int op_status;
  String op_datetime;
  int op_by;
  String updated_at;
  int updated_by;

  OrderPayment({
    this.op_id,
    this.uuid,
    this.order_id,
    this.branch_id,
    this.terminal_id,
    this.app_id,
    this.op_method_id,
    this.op_amount,
    this.op_method_response,
    this.op_status,
    this.op_datetime,
    this.op_by,
    this.updated_at,
    this.updated_by,
  });

  OrderPayment.fromJson(Map<String, dynamic> json) {
    op_id = json["op_id"];
    uuid = json["uuid"];
    order_id = json["order_id"];
    branch_id = json["branch_id"];
    terminal_id = json["terminal_id"];
    app_id = json["app_id"];
    op_method_id = json["op_method_id"];
    op_amount = json["op_amount"];
    op_method_response = json["op_method_response"];
    op_status = json["op_status"];
    op_datetime = json["op_datetime"];
    op_by = json["op_by"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["op_id"] = this.op_id;
    data["uuid"] = this.uuid;
    data["order_id"] = this.order_id;
    data["branch_id"] = this.branch_id;
    data["terminal_id"] = this.terminal_id;
    data["app_id"] = this.app_id;
    data["op_method_id"] = this.op_method_id;
    data["op_amount"] = this.op_amount;
    data["op_method_response"] = this.op_method_response;
    data["op_status"] = this.op_status;
    data["op_datetime"] = this.op_datetime;
    data["op_by"] = this.op_by;
    data["updated_at"] = this.updated_at;
    data["updated_by"] = this.updated_by;

    return data;
  }
}