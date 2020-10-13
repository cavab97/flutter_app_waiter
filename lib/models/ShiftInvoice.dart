class ShiftInvoice {
  int id;
  int shift_id;
  int invoice_id;
  int status;
  int created_by;
  int updated_by;
  String created_at;
  String updated_at;
  int sync;
  int serverId;
  String localID;
  int terminal_id;
  int shift_terminal_id;

  ShiftInvoice({
    this.id,
    this.shift_id,
    this.invoice_id,
    this.status,
    this.created_by,
    this.updated_by,
    this.created_at,
    this.updated_at,
    this.sync,
    this.serverId,
    this.localID,
    this.terminal_id,
    this.shift_terminal_id,
  });

  ShiftInvoice.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    shift_id = json["shift_id"];
    invoice_id = json["invoice_id"];
    status = json["status"];
    created_by = json["created_by"];
    updated_by = json["updated_by"];
    created_at = json["created_at"];
    updated_at = json["updated_at"];
    sync = json["sync"];
    serverId = json["serverId"];
    localID = json["localID"];
    terminal_id = json["terminal_id"];
    shift_terminal_id = json["shift_terminal_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["id"] = this.id;
    data["shift_id"] = this.shift_id;
    data["invoice_id"] = this.invoice_id;
    data["status"] = this.status;
    data["created_by"] = this.created_by;
    data["updated_by"] = this.updated_by;
    data["created_at"] = this.created_at;
    data["updated_at"] = this.updated_at;
    data["sync"] = this.sync;
    data["serverId"] = this.serverId;
    data["localID"] = this.localID;
    data["terminal_id"] = this.terminal_id;
    data["shift_terminal_id"] = this.shift_terminal_id;

    return data;
  }
}