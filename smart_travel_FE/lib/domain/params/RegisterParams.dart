class RegisterParams{
  final String fullName;
  final String email;
  final String? phone;
  final String password;
  final String confirmPassword;

  RegisterParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword});

}