class ScenesData {
  ScenesData({
    this.success,
    this.message,
    this.scenes,
  });

  int success;
  String message;
  List<Scene> scenes;

  factory ScenesData.fromJson(Map<String, dynamic> json) => ScenesData(
        success: json["success"],
        message: json["message"],
        scenes: List<Scene>.from(json["scenes"].map((x) => Scene.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "scenes": List<dynamic>.from(scenes.map((x) => x.toJson())),
      };
}

class Scene {
  Scene({
    this.customerId,
    this.sceneId,
    this.sceneName,
    this.imageUrl,
    this.startTime,
    this.endTime,
    this.status,
  });

  String customerId;
  String sceneId;
  String sceneName;
  String imageUrl;
  String startTime;
  String endTime;
  String status;

  factory Scene.fromJson(Map<String, dynamic> json) => Scene(
        customerId: json["id"],
        sceneId: json["sceneId"],
        sceneName: json["sceneName"],
        imageUrl: json["imageUrl"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        status: json["sceneStatus"],
      );

  Map<String, dynamic> toJson() => {
        "id": customerId,
        "sceneId": sceneId,
        "sceneName": sceneName,
        "imageUrl": imageUrl,
        "startTime": startTime,
        "endTime": endTime,
        "sceneStatus": status,
      };
}
