class TerminalLog {
  int id;
  String uuid;
  int terminal_id;
  int isSync;
  int branch_id;
  String module_name;
  String description;
  String activity_date;
  String activity_time;
  String table_name;
  int entity_id;
  int status;
  String updated_at;
  int updated_by;

  TerminalLog({
    this.id,
    this.uuid,
    this.terminal_id,
    this.isSync,
    this.branch_id,
    this.module_name,
    this.description,
    this.activity_date,
    this.activity_time,
    this.table_name,
    this.entity_id,
    this.status,
    this.updated_at,
    this.updated_by,
  });

  TerminalLog.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    uuid = json["uuid"];
    terminal_id = json["terminal_id"];
    isSync = json["is_sync"];
    branch_id = json["branch_id"];
    module_name = json["module_name"];
    description = json["description"];
    activity_date = json["activity_date"];
    activity_time = json["activity_time"];
    table_name = json["table_name"];
    entity_id = json["entity_id"];
    status = json["status"];
    updated_at = json["updated_at"];
    updated_by = json["updated_by"];
  }

  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data["id"] = this.id;
      data["uuid"] = this.uuid;
      data["terminal_id"] = this.terminal_id;
      data["is_sync"] = this.isSync;
      data["branch_id"] = this.branch_id;
      data["module_name"] = this.module_name;
      data["description"] = this.description;
      data["activity_date"] = this.activity_date;
      data["activity_time"] = this.activity_time;
      data["table_name"] = this.table_name;
      data["entity_id"] = this.entity_id;
      data["status"] = this.status;
      data["updated_at"] = this.updated_at;
      data["updated_by"] = this.updated_by;
      return data;
    } catch (error) {
      print('toJson'+error);
      rethrow;
    }
  }
}
