package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.user.request.ChangePasswordRequest;
import com.example.smart_travel_BE.dto.user.request.DeleteAccountRequest;
import com.example.smart_travel_BE.dto.user.request.SettingsRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateLevelRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateProfileRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.ProfileResponse;
import com.example.smart_travel_BE.dto.user.response.SettingsResponse;
import com.example.smart_travel_BE.dto.user.response.LevelResponse;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.repository.UserProfileRepository;
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
    private final UserProfileRepository userProfileRepository;

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

    /**
     * Lấy thông tin cài đặt của người dùng
     */
    @GetMapping("/settings")
    public ResponseEntity<APIResponse<SettingsResponse>> getSettings() {
        try {
            SettingsResponse response = userService.getSettings();
            return ResponseEntity.ok(
                    APIResponse.<SettingsResponse>builder()
                            .msg("Lấy thông tin cài đặt thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Get settings failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<SettingsResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error getting settings", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<SettingsResponse>builder()
                            .msg("Có lỗi xảy ra khi lấy cài đặt")
                            .build()
            );
        }
    }

    /**
     * Cập nhật thông tin cài đặt
     */
    @PutMapping("/settings")
    public ResponseEntity<APIResponse<SettingsResponse>> updateSettings(
            @Valid @RequestBody SettingsRequest request) {
        try {
            SettingsResponse response = userService.updateSettings(request);
            return ResponseEntity.ok(
                    APIResponse.<SettingsResponse>builder()
                            .msg("Cập nhật cài đặt thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Update settings failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<SettingsResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error updating settings", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<SettingsResponse>builder()
                            .msg("Có lỗi xảy ra khi cập nhật cài đặt")
                            .build()
            );
        }
    }

    /**
     * Lấy thông tin cấp bậc/ thành tích
     */
    @GetMapping("/level")
    public ResponseEntity<APIResponse<LevelResponse>> getUserLevel() {
        try {
            LevelResponse response = userService.getUserLevel();
            return ResponseEntity.ok(
                    APIResponse.<LevelResponse>builder()
                            .msg("Lấy cấp bậc thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Get user level failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<LevelResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error getting user level", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<LevelResponse>builder()
                            .msg("Có lỗi xảy ra khi lấy cấp bậc")
                            .build()
            );
        }
    }

    // API lấy Profile (chứa điểm) dựa trên User ID
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getProfileByUserId(@PathVariable Long userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Chưa có hồ sơ cho User ID: " + userId));

        return ResponseEntity.ok(profile);
    }

    /**
     * Cập nhật cấp bậc/ thành tích
     */
    @PutMapping("/level")
    public ResponseEntity<APIResponse<LevelResponse>> updateUserLevel(
            @Valid @RequestBody UpdateLevelRequest request) {
        try {
            LevelResponse response = userService.updateUserLevel(request);
            return ResponseEntity.ok(
                    APIResponse.<LevelResponse>builder()
                            .msg("Cập nhật cấp bậc thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Update user level failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<LevelResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error updating user level", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<LevelResponse>builder()
                            .msg("Có lỗi xảy ra khi cập nhật cấp bậc")
                            .build()
            );
        }
    }

    /**
     * Xóa tài khoản vĩnh viễn
     */
    @DeleteMapping("/account")
    public ResponseEntity<APIResponse<Void>> deleteAccount(
            @Valid @RequestBody DeleteAccountRequest request) {
        try {
            userService.deleteAccount(request);
            return ResponseEntity.ok(
                    APIResponse.<Void>builder()
                            .msg("Xóa tài khoản thành công")
                            .build()
            );
        } catch (AppException e) {
            log.error("Delete account failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error when deleting account", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<Void>builder()
                            .msg("Có lỗi xảy ra khi xóa tài khoản")
                            .build()
            );
        }
    }
}

