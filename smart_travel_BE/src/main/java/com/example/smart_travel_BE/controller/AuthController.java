package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.GoogleLoginRequest;
import com.example.smart_travel_BE.dto.user.request.LoginRequest;
import com.example.smart_travel_BE.dto.user.request.PasswordResetRequest;
import com.example.smart_travel_BE.dto.user.request.RegisterRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.LoginResponse;
import com.example.smart_travel_BE.dto.user.response.RegisterResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.view.RedirectView;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    /**
     * Đăng ký người dùng mới
     */
    @PostMapping("/register")
    public ResponseEntity<APIResponse<RegisterResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        try {
            RegisterResponse response = authService.register(request);

            return ResponseEntity.status(HttpStatus.CREATED).body(
                    APIResponse.<RegisterResponse>builder()
                            .msg("Đăng ký thành công")
                            .data(response)
                            .build()
            );

        } catch (AppException e) {
            log.error("Registration failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<RegisterResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }
    /**
     * Xác thực email
     */
    @GetMapping("/verify-email")
    public RedirectView verifyEmail(@RequestParam("token") String token) {
        try {
            authService.verifyEmail(token);
            return new RedirectView("/verify-success.html");
        } catch (AppException e) {
            log.error("Xác thực thất bại", e);
            // truyền message qua query param
            String errorMsg = UriUtils.encode(e.getMessage(), StandardCharsets.UTF_8);
            return new RedirectView("/verify-fail.html?error=" + errorMsg);
        }
    }
    /**
     * Gửi lại xác thực
     */
    @PostMapping("/resend-verification")
    public ResponseEntity<APIResponse<Void>> resendVerificationEmail(
            @RequestParam("email") String  email) {
        try {
          authService.resendVerificationEmail(email);

            return ResponseEntity.status(HttpStatus.CREATED).body(
                    APIResponse.<Void>builder()
                            .msg("Gửi lại email xác thực thành công")
                            .build()
            );

        } catch (AppException e) {
            log.error("Gửi lại email xác thực thất bại", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }
    /**
     * Đăng nhập
     */
    @PostMapping("/login")
    public ResponseEntity<APIResponse<LoginResponse>> login(
           @RequestBody @Valid LoginRequest request) {
        try {
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<LoginResponse>builder()
                            .data(authService.login(request))
                            .build()
            );
        } catch (AppException e) {
            log.error("Đăng nhập thất bại:", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<LoginResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }
    /**
     * Quên mật khẩu
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<APIResponse<Void>> forgotPassword(
            @RequestParam("email") String email) {
        try {
            authService.forgotPassword(email);
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Yêu cầu đã được gửi!")
                            .build()
            );
        } catch (AppException e) {
            log.error("Không th gửi yêu cầu quên mật khẩu:", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }

    /**
     * Verify Email quên mật khâu
     */
    @GetMapping("/check-reset-password")
    public RedirectView  checkResetPassword(
            @RequestParam("token") String token) {
        try {
            authService.checkResetPassword(token);
            return new RedirectView("/reset-password.html?token=" + token);
        } catch (AppException e) {
            log.error("Xác thực thất bại", e);
            // truyền message qua query param
            String errorMsg = UriUtils.encode(e.getMessage(), StandardCharsets.UTF_8);
            return new RedirectView("/verify-fail.html?error=" + errorMsg);
        }
    }

    /**
     * Verify Email quên mật khâu
     */
    @PostMapping("/reset-password")
    public ResponseEntity<APIResponse<Void>> resetPassword(
            @RequestBody @Valid PasswordResetRequest request) {
        try {
            authService.resetPassword(request);
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Đặt lại mật khẩu thành công!. Vui lòng quay lại ứng dụng để đăng nhập")
                            .build()
            );
        } catch (AppException e) {
            log.error("Đặt mật khẩu thất bại:", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }

    @PostMapping("/google-login")
    public ResponseEntity<APIResponse<LoginResponse>> googleLogin(@RequestBody GoogleLoginRequest request) {
        LoginResponse response = authService.loginWithGoogle(request);
        return ResponseEntity.ok().body(
                APIResponse.<LoginResponse>builder()
                        .data(response)
                        .build()
        );
    }
}