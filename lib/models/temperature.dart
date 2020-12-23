class TemperatureInfo {
  TemperatureInfo({
    this.success,
    this.message,
    this.temperatureSettings,
  });

  int success;
  String message;
  List<TemperatureSetting> temperatureSettings;

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) =>
      TemperatureInfo(
        success: json["success"],
        message: json["message"],
        temperatureSettings: List<TemperatureSetting>.from(
            json["temperatureSettings"]
                .map((x) => TemperatureSetting.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "temperatureSettings":
            List<dynamic>.from(temperatureSettings.map((x) => x.toJson())),
      };
}

class TemperatureSetting {
  TemperatureSetting({
    this.sceneId,
    this.minimumTemp,
    this.maximumTemp,
  });

  String sceneId;
  int minimumTemp;
  int maximumTemp;

  factory TemperatureSetting.fromJson(Map<String, dynamic> json) =>
      TemperatureSetting(
        sceneId: json["sceneId"],
        minimumTemp: json["minimumTemp"],
        maximumTemp: json["maximumTemp"],
      );

  Map<String, dynamic> toJson() => {
        "sceneId": sceneId,
        "minimumTemp": minimumTemp,
        "maximumTemp": maximumTemp,
      };
}
