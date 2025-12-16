package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.common.PageResponse;
import com.example.smart_travel_BE.dto.user.request.CreateUserRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateUserAdminRequest;
import com.example.smart_travel_BE.dto.user.request.UserListRequest;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.dto.user.response.UserDetailResponse;
import com.example.smart_travel_BE.dto.user.response.UserSummaryResponse;
import com.example.smart_travel_BE.service.UserService;
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

    private final UserService userService;

    /**
     * Lấy danh sách users với pagination và tìm kiếm
     */
    @GetMapping
    public ResponseEntity<APIResponse<PageResponse<UserSummaryResponse>>> getAllUsers(
            @Valid @ModelAttribute UserListRequest request) {
        PageResponse<UserSummaryResponse> response = userService.getAllUsers(request);
        return ResponseEntity.ok(
                APIResponse.<PageResponse<UserSummaryResponse>>builder()
                        .msg("Lấy danh sách users thành công")
                        .data(response)
                        .build()
        );
    }

    /**
     * Tạo user mới
     */
    @PostMapping
    public ResponseEntity<APIResponse<UserDetailResponse>> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        UserDetailResponse response = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(
                APIResponse.<UserDetailResponse>builder()
                        .msg("Tạo user thành công")
                        .data(response)
                        .build()
        );
    }

    /**
     * Xem chi tiết thông tin user
     */
    @GetMapping("/{id}")
    public ResponseEntity<APIResponse<UserDetailResponse>> getUserDetail(@PathVariable Long id) {
        UserDetailResponse response = userService.getUserDetail(id);
        return ResponseEntity.ok(
                APIResponse.<UserDetailResponse>builder()
                        .msg("Lấy thông tin user thành công")
                        .data(response)
                        .build()
        );
    }

    /**
     * Chỉnh sửa thông tin user cơ bản
     */
    @PutMapping("/{id}")
    public ResponseEntity<APIResponse<UserDetailResponse>> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserAdminRequest request) {
        UserDetailResponse response = userService.updateUser(id, request);
        return ResponseEntity.ok(
                APIResponse.<UserDetailResponse>builder()
                        .msg("Cập nhật thông tin user thành công")
                        .data(response)
                        .build()
        );
    }

    /**
     * Khóa tài khoản user
     */
    @PostMapping("/{id}/lock")
    public ResponseEntity<APIResponse<Void>> lockUser(@PathVariable Long id) {
        userService.lockUser(id);
        return ResponseEntity.ok(
                APIResponse.<Void>builder()
                        .msg("Khóa tài khoản thành công")
                        .build()
        );
    }

    /**
     * Mở khóa tài khoản user
     */
    @PostMapping("/{id}/unlock")
    public ResponseEntity<APIResponse<Void>> unlockUser(@PathVariable Long id) {
        userService.unlockUser(id);
        return ResponseEntity.ok(
                APIResponse.<Void>builder()
                        .msg("Mở khóa tài khoản thành công")
                        .build()
        );
    }
}
