package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.*;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.LoginResponse;
import com.example.smart_travel_BE.dto.user.response.RegisterResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.AuthService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.view.RedirectView;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

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
                            .code(e.getErrorCode().getCode())
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
                            .code(e.getErrorCode().getCode())
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
                            .code(e.getErrorCode().getCode())
                            .msg(e.getMessage())
                            .build()
            );
        }
    }


    @PostMapping("/refresh")
    APIResponse<LoginResponse> refresh(@RequestBody RefreshTokenRequest refreshToken) {
        log.info("req"+ refreshToken);
        return APIResponse.<LoginResponse>builder()
                .data(authService.refreshToken(refreshToken))
                .build();
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
                            .code(e.getErrorCode().getCode())
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
                            .code(e.getErrorCode().getCode())
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

    @PostMapping("/facebook-login")
    public ResponseEntity<APIResponse<LoginResponse>> facebookLogin(@RequestBody FacebookLoginRequest request) {
        LoginResponse response = authService.loginWithFacebook(request);
        return ResponseEntity.ok().body(
                APIResponse.<LoginResponse>builder()
                        .data(response)
                        .build()
        );
    }

    /**
     * Kiểm tra trạng thái email verified (dùng để debug)
     */
    @GetMapping("/check-email-status")
    public ResponseEntity<APIResponse<Object>> checkEmailStatus(@RequestParam("email") String email) {
        try {
            var user = authService.getUserByEmail(email);
            if (user == null) {
                return ResponseEntity.badRequest().body(
                        APIResponse.builder()
                                .msg("User không tồn tại")
                                .build()
                );
            }

            Map<String, Object> status = new HashMap<>();
            status.put("email", user.getEmail());
            status.put("emailVerified", user.getEmailVerified());
            status.put("id", user.getId());
            status.put("createdAt", user.getCreatedAt());
            status.put("updatedAt", user.getUpdatedAt());

            return ResponseEntity.ok(
                    APIResponse.builder()
                            .msg("Trạng thái email: " + (user.getEmailVerified() ? "Đã xác thực" : "Chưa xác thực"))
                            .data(status)
                            .build()
            );
        } catch (Exception e) {
            log.error("Error checking email status", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.builder()
                            .msg("Lỗi: " + e.getMessage())
                            .build()
            );
        }
    }

    //Đăng xuất của admin
    @PostMapping("/logout/admin")
    public ResponseEntity<Void> logoutAdmin( @CookieValue(value = "refreshToken", required = false) String refreshToken,
                                       HttpServletResponse response) {
        // Nếu có refreshToken, gọi service để xoá token trên server
        if (refreshToken != null && !refreshToken.isEmpty()) {
            authService.logoutAdmin(refreshToken);
        }

        // Xóa cookie refreshToken
        Cookie cookie = new Cookie("refreshToken", null);
        cookie.setHttpOnly(true);
        cookie.setSecure(false); // nếu chạy HTTP local
        cookie.setPath("/");
        cookie.setDomain("localhost"); // nếu đang test local
        cookie.setMaxAge(0);
        response.addCookie(cookie);

        return ResponseEntity.ok().build();
    }
}