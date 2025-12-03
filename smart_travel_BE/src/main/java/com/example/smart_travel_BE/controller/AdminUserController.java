package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.common.PageResponse;
import com.example.smart_travel_BE.dto.user.request.UpdateUserAdminRequest;
import com.example.smart_travel_BE.dto.user.request.UserListRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.UserDetailResponse;
import com.example.smart_travel_BE.dto.user.response.UserSummaryResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.AdminUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final AdminUserService adminUserService;

    /**
     * Lấy danh sách users với pagination và tìm kiếm
     * GET /api/v1/admin/users?page=0&size=10&searchKeyword=john&sortBy=createdAt&sortDirection=DESC
     */
    @GetMapping
    public ResponseEntity<APIResponse<PageResponse<UserSummaryResponse>>> getAllUsers(
            @Valid @ModelAttribute UserListRequest request) {
        try {
            PageResponse<UserSummaryResponse> response = adminUserService.getAllUsers(request);
            return ResponseEntity.ok(
                    APIResponse.<PageResponse<UserSummaryResponse>>builder()
                            .msg("Lấy danh sách users thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Get all users failed", e);
            return ResponseEntity.badRequest().body(
                    APIResponse.<PageResponse<UserSummaryResponse>>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error getting all users", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<PageResponse<UserSummaryResponse>>builder()
                            .msg("Có lỗi xảy ra khi lấy danh sách users")
                            .build()
            );
        }
    }

    /**
     * Xem chi tiết thông tin user
     * GET /api/v1/admin/users/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<APIResponse<UserDetailResponse>> getUserDetail(@PathVariable Long id) {
        try {
            UserDetailResponse response = adminUserService.getUserDetail(id);
            return ResponseEntity.ok(
                    APIResponse.<UserDetailResponse>builder()
                            .msg("Lấy thông tin user thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Get user detail failed: {}", id, e);
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<UserDetailResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error getting user detail: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<UserDetailResponse>builder()
                            .msg("Có lỗi xảy ra khi lấy thông tin user")
                            .build()
            );
        }
    }

    /**
     * Chỉnh sửa thông tin user cơ bản
     * PUT /api/v1/admin/users/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<APIResponse<UserDetailResponse>> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserAdminRequest request) {
        try {
            UserDetailResponse response = adminUserService.updateUser(id, request);
            return ResponseEntity.ok(
                    APIResponse.<UserDetailResponse>builder()
                            .msg("Cập nhật thông tin user thành công")
                            .data(response)
                            .build()
            );
        } catch (AppException e) {
            log.error("Update user failed: {}", id, e);
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<UserDetailResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error updating user: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<UserDetailResponse>builder()
                            .msg("Có lỗi xảy ra khi cập nhật user")
                            .build()
            );
        }
    }

    /**
     * Khóa tài khoản user
     * POST /api/v1/admin/users/{id}/lock
     */
    @PostMapping("/{id}/lock")
    public ResponseEntity<APIResponse<Void>> lockUser(@PathVariable Long id) {
        try {
            adminUserService.lockUser(id);
            return ResponseEntity.ok(
                    APIResponse.<Void>builder()
                            .msg("Khóa tài khoản thành công")
                            .build()
            );
        } catch (AppException e) {
            log.error("Lock user failed: {}", id, e);
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error locking user: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<Void>builder()
                            .msg("Có lỗi xảy ra khi khóa tài khoản")
                            .build()
            );
        }
    }

    /**
     * Mở khóa tài khoản user
     * POST /api/v1/admin/users/{id}/unlock
     */
    @PostMapping("/{id}/unlock")
    public ResponseEntity<APIResponse<Void>> unlockUser(@PathVariable Long id) {
        try {
            adminUserService.unlockUser(id);
            return ResponseEntity.ok(
                    APIResponse.<Void>builder()
                            .msg("Mở khóa tài khoản thành công")
                            .build()
            );
        } catch (AppException e) {
            log.error("Unlock user failed: {}", id, e);
            return ResponseEntity.status(e.getErrorCode().getStatusCode()).body(
                    APIResponse.<Void>builder()
                            .msg(e.getMessage())
                            .build()
            );
        } catch (Exception e) {
            log.error("Unexpected error unlocking user: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    APIResponse.<Void>builder()
                            .msg("Có lỗi xảy ra khi mở khóa tài khoản")
                            .build()
            );
        }
    }
}
