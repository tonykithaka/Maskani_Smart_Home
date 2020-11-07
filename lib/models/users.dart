class LoginData {
  int success;
  String message;
  String token;
  Data data;

  LoginData({
    this.success,
    this.message,
    this.token,
    this.data,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "data": data.toJson(),
      };
}

class Data {
  String userId;
  String fullName;
  String emailAddress;
  String phoneNumber;
  String createdDate;

  Data({
    this.userId,
    this.fullName,
    this.emailAddress,
    this.phoneNumber,
    this.createdDate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        fullName: json["full_name"],
        emailAddress: json["email_address"],
        phoneNumber: json["phone_number"],
        createdDate: json["created_date"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "full_name": fullName,
        "email_address": emailAddress,
        "phone_number": phoneNumber,
        "created_date": createdDate,
      };
}

class UserData {
  final String user_id;
  final String full_name;
  final String email_address;
  final String phone_number;
  final String created_date;

  UserData(this.user_id, this.full_name, this.email_address, this.phone_number,
      this.created_date);

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(json["user_id"], json['full_name'], json['email_address'],
        json['phone_number'], json['created_date']);
  }
}

class SignUpData {
  final int success;
  final String message;

  SignUpData(this.success, this.message);

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    return SignUpData(json["success"], json['message']);
  }
}
