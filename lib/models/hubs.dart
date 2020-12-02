class HubData {
  HubData({
    this.success,
    this.message,
    this.hubInfo,
  });

  int success;
  String message;
  List<HubInfo> hubInfo;

  factory HubData.fromJson(Map<String, dynamic> json) => HubData(
        success: json["success"],
        message: json["message"],
        hubInfo:
            List<HubInfo>.from(json["hubInfo"].map((x) => HubInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "hubInfo": List<dynamic>.from(hubInfo.map((x) => x.toJson())),
      };
}

class HubInfo {
  HubInfo({
    this.id,
    this.hubId,
    this.dateCreated,
  });

  String id;
  String hubId;
  DateTime dateCreated;

  factory HubInfo.fromJson(Map<String, dynamic> json) => HubInfo(
        id: json["id"],
        hubId: json["hubId"],
        dateCreated: DateTime.parse(json["dateCreated"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hubId": hubId,
        "dateCreated": dateCreated.toIso8601String(),
      };
}
