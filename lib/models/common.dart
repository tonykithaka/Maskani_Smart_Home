class CommonData {
  CommonData({
    this.message,
    this.success,
  });
  int success;
  String message;

  factory CommonData.fromJson(Map<String, dynamic> json) => CommonData(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
