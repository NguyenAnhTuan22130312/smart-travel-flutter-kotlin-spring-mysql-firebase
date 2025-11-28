package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.ChangePasswordRequest;
import com.example.smart_travel_BE.dto.user.request.DeleteAccountRequest;
import com.example.smart_travel_BE.dto.user.request.SettingsRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateLevelRequest;
import com.example.smart_travel_BE.dto.user.request.UpdateProfileRequest;
import com.example.smart_travel_BE.dto.user.response.ProfileResponse;
import com.example.smart_travel_BE.dto.user.response.SettingsResponse;
import com.example.smart_travel_BE.dto.user.response.LevelResponse;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.repository.BookingRepository;
import com.example.smart_travel_BE.repository.EmailVerificationTokenRepository;
import com.example.smart_travel_BE.repository.RefreshTokenRepository;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final BookingRepository bookingRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailVerificationTokenRepository emailVerificationTokenRepository;
    private final PasswordEncoder passwordEncoder;

    private static final LevelTier[] LEVEL_TIERS = new LevelTier[]{
            new LevelTier("Đồng", 0L, 1000L),
            new LevelTier("Bạc", 1000L, 3000L),
            new LevelTier("Vàng", 3000L, 7000L),
            new LevelTier("Kim cương", 7000L, null)
    };

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
        UserProfile userProfile = getOrCreateUserProfile(currentUser);

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
        UserProfile userProfile = getOrCreateUserProfile(currentUser);

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
        if (request.getNotificationSettings() != null) {
            userProfile.setNotificationSettings(request.getNotificationSettings());
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
     * Lấy thông tin cài đặt của user hiện tại
     */
    public SettingsResponse getSettings() {
        User currentUser = getCurrentUser();

        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }

        UserProfile userProfile = getOrCreateUserProfile(currentUser);
        return buildSettingsResponse(userProfile);
    }

    /**
     * Cập nhật thông tin cài đặt (language, dark mode, notifications)
     */
    @Transactional
    public SettingsResponse updateSettings(SettingsRequest request) {
        User currentUser = getCurrentUser();

        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }

        UserProfile userProfile = getOrCreateUserProfile(currentUser);

        if (request.getLanguageSettings() != null) {
            userProfile.setLanguageSettings(request.getLanguageSettings());
        }
        if (request.getDarkModeEnabled() != null) {
            userProfile.setDarkModeEnabled(request.getDarkModeEnabled());
        }
        if (request.getNotificationSettings() != null) {
            userProfile.setNotificationSettings(request.getNotificationSettings());
        }

        userProfileRepository.save(userProfile);

        log.info("Settings updated for user: {}", currentUser.getEmail());
        return buildSettingsResponse(userProfile);
    }

    /**
     * Lấy thông tin cấp bậc/ thành tích của user
     */
    public LevelResponse getUserLevel() {
        User currentUser = getCurrentUser();

        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }

        UserProfile userProfile = getOrCreateUserProfile(currentUser);
        return buildLevelResponse(userProfile);
    }

    /**
     * Cập nhật cấp bậc/ huy hiệu
     */
    @Transactional
    public LevelResponse updateUserLevel(UpdateLevelRequest request) {
        User currentUser = getCurrentUser();

        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }

        UserProfile userProfile = getOrCreateUserProfile(currentUser);

        if (request.getExperiencePoints() != null) {
            userProfile.setExperiencePoints(request.getExperiencePoints());
        }
        LevelInfo levelInfo = calculateLevel(userProfile.getExperiencePoints());
        userProfile.setCurrentLevel(levelInfo.levelName());

        userProfileRepository.save(userProfile);

        log.info("Level updated for user: {} - level {}", currentUser.getEmail(), levelInfo.levelName());
        return buildLevelResponse(userProfile, levelInfo);
    }

    /**
     * Đổi mật khẩu cho user hiện tại
     */
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        User currentUser = getCurrentUser();

        // Kiểm tra email đã được xác thực chưa
        if (!currentUser.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }

        // Kiểm tra mật khẩu hiện tại
        if (!passwordEncoder.matches(request.getCurrentPassword(), currentUser.getPassword())) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }

        // Kiểm tra mật khẩu mới và xác nhận
        if (!request.getNewPassword().equals(request.getConfirmNewPassword())) {
            throw new AppException(ErrorCode.INVALID_PASSWORD);
        }

        // Không cho phép đặt lại cùng mật khẩu cũ
        if (passwordEncoder.matches(request.getNewPassword(), currentUser.getPassword())) {
            throw new AppException(ErrorCode.INVALID_PASSWORD);
        }

        currentUser.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(currentUser);

        log.info("Password changed for user: {}", currentUser.getEmail());
    }

    /**
     * Xóa tài khoản vĩnh viễn
     */
    @Transactional
    public void deleteAccount(DeleteAccountRequest request) {
        User currentUser = getCurrentUser();

        // Xóa tất cả email verification tokens của user
        emailVerificationTokenRepository.deleteByUser(currentUser);
        log.info("Deleted all email verification tokens for user: {}", currentUser.getEmail());

        // Xóa tất cả refresh tokens của user
        refreshTokenRepository.deleteByUser(currentUser);
        log.info("Deleted all refresh tokens for user: {}", currentUser.getEmail());

        // Xóa tất cả bookings của user (sẽ cascade xóa payments và invoices)
        bookingRepository.deleteByUser(currentUser);
        log.info("Deleted all bookings for user: {}", currentUser.getEmail());

        // Xóa UserProfile
        userProfileRepository.deleteByUserId(currentUser.getId());
        log.info("Deleted user profile for user: {}", currentUser.getEmail());

        // Xóa User
        userRepository.delete(currentUser);
        log.info("Account permanently deleted for user: {}", currentUser.getEmail());
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

    private UserProfile getOrCreateUserProfile(User user) {
        return userProfileRepository.findByUser(user)
                .orElseGet(() -> {
                    UserProfile newProfile = UserProfile.builder()
                            .user(user)
                            .darkModeEnabled(false)
                            .experiencePoints(0L)
                            .currentLevel("Đồng")
                            .build();
                    return userProfileRepository.save(newProfile);
                });
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
                .notificationSettings(userProfile.getNotificationSettings())
                .languageSettings(userProfile.getLanguageSettings())
                .darkModeEnabled(userProfile.getDarkModeEnabled())
                .profileUpdatedAt(userProfile.getUpdatedAt())
                .build();
    }

    /**
     * Build SettingsResponse từ UserProfile
     */
    private SettingsResponse buildSettingsResponse(UserProfile userProfile) {
        return SettingsResponse.builder()
                .languageSettings(userProfile.getLanguageSettings())
                .darkModeEnabled(userProfile.getDarkModeEnabled())
                .notificationSettings(userProfile.getNotificationSettings())
                .build();
    }

    /**
     * Build LevelResponse từ UserProfile
     */
    private LevelResponse buildLevelResponse(UserProfile userProfile) {
        LevelInfo levelInfo = calculateLevel(userProfile.getExperiencePoints());
        return buildLevelResponse(userProfile, levelInfo);
    }

    private LevelResponse buildLevelResponse(UserProfile userProfile, LevelInfo levelInfo) {
        return LevelResponse.builder()
                .currentLevel(levelInfo.levelName())
                .experiencePoints(userProfile.getExperiencePoints())
                .nextLevelAt(levelInfo.nextLevelAt())
                .progressPercentage(levelInfo.progress())
                .build();
    }

    private LevelInfo calculateLevel(Long experiencePoints) {
        long xp = experiencePoints != null ? experiencePoints : 0L;
        LevelTier currentTier = LEVEL_TIERS[LEVEL_TIERS.length - 1];
        LevelTier nextTier = null;

        for (int i = 0; i < LEVEL_TIERS.length; i++) {
            LevelTier tier = LEVEL_TIERS[i];
            LevelTier following = (i + 1 < LEVEL_TIERS.length) ? LEVEL_TIERS[i + 1] : null;

            if (following == null || xp < following.minXp()) {
                currentTier = tier;
                nextTier = following;
                break;
            }
        }

        Double progress;
        Long nextLevelAt = nextTier != null ? nextTier.minXp() : null;

        if (nextTier == null) {
            progress = 100d;
        } else {
            long range = nextTier.minXp() - currentTier.minXp();
            long gained = xp - currentTier.minXp();
            progress = range == 0 ? 0d : Math.min(100d, (gained * 100d) / range);
        }

        return new LevelInfo(currentTier.name(), nextLevelAt, progress);
    }

    private record LevelTier(String name, long minXp, Long nextXp) {
    }

    private record LevelInfo(String levelName, Long nextLevelAt, Double progress) {
    }
}
