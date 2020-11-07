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
        customerId: json["customer_id"],
        sceneId: json["scene_id"],
        sceneName: json["scene_name"],
        imageUrl: json["image_url"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "scene_id": sceneId,
        "scene_name": sceneName,
        "image_url": imageUrl,
        "start_time": startTime,
        "end_time": endTime,
        "status": status,
      };
}
