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
    this.dateCreated,
    this.imageUrl,
  });

  String roomId;
  String customerId;
  String roomName;
  String dateCreated;
  String imageUrl;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        customerId: json["id"],
        roomId: json["roomId"],
        roomName: json["roomName"],
        dateCreated: json["dateCreated"],
        imageUrl: json["imageUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": customerId,
        "roomId": roomId,
        "roomName": roomName,
        "dateCreated": dateCreated,
        "imageUrl": imageUrl,
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
