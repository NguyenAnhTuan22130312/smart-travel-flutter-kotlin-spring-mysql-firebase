package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.ChangePasswordRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateProfileRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.ProfileResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    /**
     * Lấy thông tin profile của user hiện tại
     */
    @GetMapping("/profile")
    public ResponseEntity<APIResponse<ProfileResponse>> getProfile() {
        try {
            ProfileResponse response = userService.getProfile();
            return ResponseEntity.ok(
                    APIResponse.<ProfileResponse>builder()
                            .msg("Lấy thông tin profile thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Get profile failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<ProfileResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error getting profile", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<ProfileResponse>builder()
                            .msg("Có lỗi xảy ra khi lấy thông tin profile")
                            .build()
            );
        }
    }

    /**
     * Cập nhật thông tin profile
     */
    @PutMapping("/profile")
    public ResponseEntity<APIResponse<ProfileResponse>> updateProfile(
            @Valid @RequestBody UpdateProfileRequest request) {
        try {
            ProfileResponse response = userService.updateProfile(request);
            return ResponseEntity.ok(
                    APIResponse.<ProfileResponse>builder()
                            .msg("Cập nhật profile thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Update profile failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<ProfileResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error updating profile", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<ProfileResponse>builder()
                            .msg("Có lỗi xảy ra khi cập nhật profile")
                            .build()
            );
        }
    }

    /**
     * Đổi mật khẩu
     */
    @PutMapping("/change-password")
    public ResponseEntity<APIResponse<Void>> changePassword(
            @Valid @RequestBody ChangePasswordRequest request) {
        try {
            userService.changePassword(request);
            return ResponseEntity.ok(
                    APIResponse.<Void>builder()
                            .msg("Đổi mật khẩu thành công")
                            .build()
            );
        } catch (AppException e) {
            log.error("Change password failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error when changing password", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<Void>builder()
                            .msg("Có lỗi xảy ra khi đổi mật khẩu")
                            .build()
            );
        }
    }
}

