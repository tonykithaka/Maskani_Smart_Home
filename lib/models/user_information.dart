class UserInfo {
  int success;
  String message;
  Data data;

  UserInfo({
    this.success,
    this.message,
    this.data,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String userId;
  String nationalId;
  String fullName;
  String phoneNumber;
  String email;
  String city;
  String suburb;
  String dateOfBirth;
  String gender;
  String imageUrl;

  Data({
    this.userId,
    this.nationalId,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.city,
    this.suburb,
    this.dateOfBirth,
    this.gender,
    this.imageUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        nationalId: json["national_id"],
        fullName: json["full_name"],
        phoneNumber: json["phone_number"],
        email: json["email"],
        city: json["city"],
        suburb: json["suburb"],
        dateOfBirth: json["date_of_birth"],
        gender: json["gender"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "national_id": nationalId,
        "full_name": fullName,
        "phone_number": phoneNumber,
        "email": email,
        "city": city,
        "suburb": suburb,
        "date_of_birth": dateOfBirth,
        "gender": gender,
        "image_url": imageUrl,
      };
}
