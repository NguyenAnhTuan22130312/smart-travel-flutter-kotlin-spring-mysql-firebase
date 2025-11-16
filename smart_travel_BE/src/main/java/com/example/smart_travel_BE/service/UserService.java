package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.UpdateProfileRequest;
import com.example.smart_travel_BE.dto.user.response.ProfileResponse;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;

    /**
     * Lấy thông tin profile của user hiện tại
     */
    public ProfileResponse getProfile() {
        User currentUser = getCurrentUser();
        
        // Kiểm tra email đã được xác thực chưa
        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }
        
        // Lấy UserProfile, nếu chưa có thì tạo mới (chỉ khi email đã verified)
        UserProfile userProfile = userProfileRepository.findByUser(currentUser)
                .orElseGet(() -> {
                    // Tạo UserProfile mặc định nếu chưa có (chỉ khi email đã verified)
                    UserProfile newProfile = UserProfile.builder()
                            .user(currentUser)
                            .darkModeEnabled(false)
                            .build();
                    return userProfileRepository.save(newProfile);
                });

        return buildProfileResponse(currentUser, userProfile);
    }

    /**
     * Cập nhật thông tin profile
     */
    @Transactional
    public ProfileResponse updateProfile(UpdateProfileRequest request) {
        User currentUser = getCurrentUser();
        
        // Kiểm tra email đã được xác thực chưa
        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }
        
        // Cập nhật thông tin User
        if (request.getFullName() != null) {
            currentUser.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            // Kiểm tra phone đã tồn tại chưa (trừ chính user hiện tại)
            if (userRepository.existsByPhone(request.getPhone()) && 
                !request.getPhone().equals(currentUser.getPhone())) {
                throw new AppException(ErrorCode.PHONE_EXISTED);
            }
            currentUser.setPhone(request.getPhone());
        }
        userRepository.save(currentUser);

        // Lấy hoặc tạo UserProfile (chỉ khi email đã verified)
        UserProfile userProfile = userProfileRepository.findByUser(currentUser)
                .orElseGet(() -> {
                    // Tạo UserProfile mặc định nếu chưa có (chỉ khi email đã verified)
                    UserProfile newProfile = UserProfile.builder()
                            .user(currentUser)
                            .darkModeEnabled(false)
                            .build();
                    return userProfileRepository.save(newProfile);
                });

        // Cập nhật thông tin UserProfile
        if (request.getAvatarUrl() != null) {
            userProfile.setAvatarUrl(request.getAvatarUrl());
        }
        if (request.getBio() != null) {
            userProfile.setBio(request.getBio());
        }
        if (request.getGender() != null) {
            userProfile.setGender(request.getGender());
        }
        if (request.getDateOfBirth() != null) {
            userProfile.setDateOfBirth(request.getDateOfBirth());
        }
        if (request.getAddress() != null) {
            userProfile.setAddress(request.getAddress());
        }
        if (request.getCity() != null) {
            userProfile.setCity(request.getCity());
        }
        if (request.getCountry() != null) {
            userProfile.setCountry(request.getCountry());
        }
        if (request.getPreferences() != null) {
            userProfile.setPreferences(request.getPreferences());
        }
        if (request.getLanguageSettings() != null) {
            userProfile.setLanguageSettings(request.getLanguageSettings());
        }
        if (request.getDarkModeEnabled() != null) {
            userProfile.setDarkModeEnabled(request.getDarkModeEnabled());
        }

        userProfileRepository.save(userProfile);

        log.info("Profile updated for user: {}", currentUser.getEmail());
        return buildProfileResponse(currentUser, userProfile);
    }

    /**
     * Lấy user hiện tại từ SecurityContext
     */
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
        
        if (authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        
        throw new AppException(ErrorCode.UNAUTHENTICATED);
    }

    /**
     * Build ProfileResponse từ User và UserProfile
     */
    private ProfileResponse buildProfileResponse(User user, UserProfile userProfile) {
        return ProfileResponse.builder()
                // Thông tin từ User
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .role(user.getRole())
                .authProvider(user.getAuthProvider())
                .emailVerified(user.getEmailVerified())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                // Thông tin từ UserProfile
                .avatarUrl(userProfile.getAvatarUrl())
                .bio(userProfile.getBio())
                .gender(userProfile.getGender())
                .dateOfBirth(userProfile.getDateOfBirth())
                .address(userProfile.getAddress())
                .city(userProfile.getCity())
                .country(userProfile.getCountry())
                .preferences(userProfile.getPreferences())
                .languageSettings(userProfile.getLanguageSettings())
                .darkModeEnabled(userProfile.getDarkModeEnabled())
                .profileUpdatedAt(userProfile.getUpdatedAt())
                .build();
    }
}
