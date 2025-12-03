package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.common.PageResponse;
import com.example.smart_travel_BE.dto.user.request.UpdateUserAdminRequest;
import com.example.smart_travel_BE.dto.user.request.UserListRequest;
import com.example.smart_travel_BE.dto.user.response.UserDetailResponse;
import com.example.smart_travel_BE.dto.user.response.UserSummaryResponse;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import com.example.smart_travel_BE.specification.UserSpecification;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminUserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    /**
     * Lấy danh sách users với pagination và tìm kiếm
     */
    public PageResponse<UserSummaryResponse> getAllUsers(UserListRequest request) {
        // Tạo Pageable với sorting
        Sort sort = Sort.by(
                "DESC".equalsIgnoreCase(request.getSortDirection()) 
                        ? Sort.Direction.DESC 
                        : Sort.Direction.ASC,
                request.getSortBy()
        );
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize(), sort);

        // Tạo Specification cho tìm kiếm
        Specification<User> spec = UserSpecification.searchByKeyword(request.getSearchKeyword());

        // Query database
        Page<User> userPage = userRepository.findAll(spec, pageable);

        // Convert entities sang DTOs
        List<UserSummaryResponse> userSummaries = userPage.getContent().stream()
                .map(this::mapToUserSummaryResponse)
                .collect(Collectors.toList());

        // Build PageResponse
        return PageResponse.<UserSummaryResponse>builder()
                .content(userSummaries)
                .currentPage(userPage.getNumber())
                .totalPages(userPage.getTotalPages())
                .totalElements(userPage.getTotalElements())
                .pageSize(userPage.getSize())
                .hasNext(userPage.hasNext())
                .hasPrevious(userPage.hasPrevious())
                .build();
    }

    /**
     * Lấy thông tin chi tiết một user
     */
    public UserDetailResponse getUserDetail(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        UserProfile userProfile = userProfileRepository.findByUser(user).orElse(null);

        return mapToUserDetailResponse(user, userProfile);
    }

    /**
     * Cập nhật thông tin user bởi admin
     */
    @Transactional
    public UserDetailResponse updateUser(Long userId, UpdateUserAdminRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        // Cập nhật fullName
        if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
            user.setFullName(request.getFullName());
        }

        // Cập nhật phone (kiểm tra unique)
        if (request.getPhone() != null && !request.getPhone().trim().isEmpty()) {
            // Kiểm tra phone đã tồn tại chưa (trừ chính user hiện tại)
            if (userRepository.existsByPhone(request.getPhone()) 
                    && !request.getPhone().equals(user.getPhone())) {
                throw new AppException(ErrorCode.PHONE_EXISTED);
            }
            user.setPhone(request.getPhone());
        }

        // Cập nhật role
        if (request.getRole() != null && !request.getRole().trim().isEmpty()) {
            user.setRole(request.getRole());
        }

        userRepository.save(user);
        log.info("Admin updated user: {}", user.getEmail());

        UserProfile userProfile = userProfileRepository.findByUser(user).orElse(null);
        return mapToUserDetailResponse(user, userProfile);
    }

    /**
     * Khóa tài khoản user
     */
    @Transactional
    public void lockUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        if (!user.getIsActive()) {
            throw new AppException(ErrorCode.USER_ALREADY_LOCKED);
        }

        user.setIsActive(false);
        userRepository.save(user);
        log.info("Admin locked user: {}", user.getEmail());
    }

    /**
     * Mở khóa tài khoản user
     */
    @Transactional
    public void unlockUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

        if (user.getIsActive()) {
            throw new AppException(ErrorCode.USER_ALREADY_UNLOCKED);
        }

        user.setIsActive(true);
        userRepository.save(user);
        log.info("Admin unlocked user: {}", user.getEmail());
    }

    // ============= Helper Methods =============

    private UserSummaryResponse mapToUserSummaryResponse(User user) {
        return UserSummaryResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .build();
    }

    private UserDetailResponse mapToUserDetailResponse(User user, UserProfile userProfile) {
        UserDetailResponse.UserDetailResponseBuilder builder = UserDetailResponse.builder()
                // Thông tin từ User
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .role(user.getRole())
                .authProvider(user.getAuthProvider())
                .isActive(user.getIsActive())
                .emailVerified(user.getEmailVerified())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt());

        // Thông tin từ UserProfile (nếu có)
        if (userProfile != null) {
            builder.avatarUrl(userProfile.getAvatarUrl())
                    .bio(userProfile.getBio())
                    .gender(userProfile.getGender())
                    .dateOfBirth(userProfile.getDateOfBirth())
                    .address(userProfile.getAddress())
                    .city(userProfile.getCity())
                    .country(userProfile.getCountry())
                    .currentLevel(userProfile.getCurrentLevel())
                    .experiencePoints(userProfile.getExperiencePoints());
        }

        return builder.build();
    }
}
