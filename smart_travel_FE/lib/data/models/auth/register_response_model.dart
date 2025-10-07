
class RegisterResponseModel {
  final  int userId;
  final String email;
  final String fullName;
  final String message;


  RegisterResponseModel({required this.userId,required this.email,required
  this.fullName, required this.message});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      userId: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'message': message,
    };
  }
}
