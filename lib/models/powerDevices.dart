class PowerInfo {
  PowerInfo({
    this.success,
    this.message,
    this.powerSetting,
  });

  int success;
  String message;
  List<PowerSetting> powerSetting;

  factory PowerInfo.fromJson(Map<String, dynamic> json) => PowerInfo(
        success: json["success"],
        message: json["message"],
        powerSetting: List<PowerSetting>.from(
            json["powerSetting"].map((x) => PowerSetting.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "powerSetting": List<dynamic>.from(powerSetting.map((x) => x.toJson())),
      };
}

class PowerSetting {
  PowerSetting({
    this.sceneId,
    this.powerSwitchOne,
    this.powerSwitchTwo,
    this.powerSwitchThree,
    this.lightSwitch,
    this.curtainSwitch,
  });

  String sceneId;
  String powerSwitchOne;
  String powerSwitchTwo;
  String powerSwitchThree;
  String lightSwitch;
  String curtainSwitch;

  factory PowerSetting.fromJson(Map<String, dynamic> json) => PowerSetting(
        sceneId: json["sceneId"],
        powerSwitchOne: json["powerSwitchOne"],
        powerSwitchTwo: json["powerSwitchTwo"],
        powerSwitchThree: json["powerSwitchThree"],
        lightSwitch: json["lightSwitch"],
        curtainSwitch: json["curtainSwitch"],
      );

  Map<String, dynamic> toJson() => {
        "sceneId": sceneId,
        "powerSwitchOne": powerSwitchOne,
        "powerSwitchTwo": powerSwitchTwo,
        "powerSwitchThree": powerSwitchThree,
        "lightSwitch": lightSwitch,
        "curtainSwitch": curtainSwitch,
      };
}
