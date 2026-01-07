import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_event.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_state.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart';
import 'package:smart_travel/presentation/widgets/common/custom_textfield.dart';

import '../../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement forgot password logic with BLoC
      context.read<AuthBloc>().add(ForgotPasswordSubmitted(_emailController.text.trim()));

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state){
          if (state is ForgotPasswordSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.fixed,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Thành công',
                message: state.response,
                contentType: ContentType.success,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is AuthError) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.fixed,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Lỗi',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          if (loading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 500,
                repeat: true,
              ),
            );
          }
          return Container(
          decoration: const BoxDecoration(
          color: AppColors.background
          ),
          child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Quay lại',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Quên mật khẩu',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logo & Title
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,   // 90% chiều rộng màn hình
                        height: MediaQuery.of(context).size.height * 0.2, // 30% chiều cao màn hình
                        decoration: BoxDecoration(
                            border: Border.symmetric(),
                            color: AppColors.accent,
                            image: DecorationImage(
                                image:AssetImage("assets/images/img_1.png"),
                                fit: BoxFit.cover
                            ),
                            borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nhập email để nhận liên kết đặt lại mật khẩu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Forgot Password Form Card
                        Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email Field
                                  CustomTextField(
                                    label: "Email",
                                    hintText: "example@email.com",
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập email';
                                      }
                                      if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Email không hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24),
                                  // Reset Password Button
                                  PrimaryButton(
                                      text: loading ? "Đang xử lý" : "Gửi liên kết đặt lại mật khẩu",
                                      onPressed: _handleResetPassword),
                                  const SizedBox(height: 24),
                                  // Back to Login Link
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Nhớ mật khẩu? ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: const Text(
                                            'Đăng nhập',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            )
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )
          )
          );
        }

     )
    );
  }
}
