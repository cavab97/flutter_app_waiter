class ModifireData {
  String name;
  int modifierId;
  int isDefault;
  int pmId;
  int price;

  ModifireData({
    this.name,
    this.modifierId,
    this.isDefault,
    this.pmId,
    this.price,
  });

  ModifireData.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    modifierId = json["modifier_id"];
    isDefault = json["is_default"];
    pmId = json["pm_id"];
    price = json["price"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["modifier_id"] = this.modifierId;
    data["is_default"] = this.isDefault;
    data["pm_id"] = this.pmId;
    data["price"] = this.price;
    return data;
  }
}
