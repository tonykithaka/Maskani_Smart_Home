class RoomData {
  RoomData({
    this.success,
    this.message,
    this.rooms,
  });

  int success;
  String message;
  List<Room> rooms;

  factory RoomData.fromJson(Map<String, dynamic> json) => RoomData(
        success: json["success"],
        message: json["message"],
        rooms: List<Room>.from(json["rooms"].map((x) => Room.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "rooms": List<dynamic>.from(rooms.map((x) => x.toJson())),
      };
}

class Room {
  Room({
    this.roomId,
    this.customerId,
    this.roomName,
    this.deviceId,
    this.imageId,
  });

  String roomId;
  String customerId;
  String roomName;
  String deviceId;
  String imageId;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomId: json["room_id"],
        customerId: json["customer_id"],
        roomName: json["room_name"],
        deviceId: json["device_id"],
        imageId: json["image_id"],
      );

  Map<String, dynamic> toJson() => {
        "room_id": roomId,
        "customer_id": customerId,
        "room_name": roomName,
        "device_id": deviceId,
        "image_id": imageId,
      };
}

class RoomDevice {
  final String title;
  final Room roomData;

  RoomDevice(this.title, this.roomData);
}

class DeviceSettingsData {
  final String deviceTitle;
  final String sceneId;
  final List<Room> roomList;

  DeviceSettingsData(this.deviceTitle, this.sceneId, this.roomList);
}
