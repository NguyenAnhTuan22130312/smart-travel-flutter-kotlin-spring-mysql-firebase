
class LoginRequestModal {
  final String email;
  final String password;

  const LoginRequestModal({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson(){
    return{
      'email': email,
        'password': password,
    };
  }
  factory LoginRequestModal.fromJson(Map<String, dynamic> json) {
    return LoginRequestModal(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}

