package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.*;
import com.example.smart_travel_BE.dto.user.response.LoginResponse;
import com.example.smart_travel_BE.dto.user.response.RegisterResponse;
import com.example.smart_travel_BE.entity.EmailVerificationToken;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.entity.UserProfile;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.UserMapper;
import com.example.smart_travel_BE.repository.EmailVerificationTokenRepository;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.RefreshTokenRepository;
import com.example.smart_travel_BE.repository.UserProfileRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import com.example.smart_travel_BE.util.JwtUtil;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final RefreshTokenRepository refreshTokenRepository;


    /**
     * Đăng ký người dùng mới
     */
    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        // Validate mật khẩu khớp
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new AppException(ErrorCode.INVALID_PASSWORD);
        }

        // Kiểm tra email đã tồn tại
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new AppException(ErrorCode.EMAIL_EXISTED);
        }

        // Kiểm tra số điện thoại đã tồn tại (nếu có)
        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            if (userRepository.existsByPhone(request.getPhone())) {
                throw new AppException(ErrorCode.PHONE_EXISTED);
            }
        }

        // Tạo user mới
        User user = userMapper.toUser(request);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("USER");
        user.setAuthProvider("EMAIL");
        user.setIsActive(true);
        user.setEmailVerified(false);

        userRepository.save(user);

        log.info("User created successfully: {}", user.getEmail());

        // Tạo token xác thực email
        String token = generateVerificationToken(user);

        // Gửi email xác thực
        try {
            EmailRequest emailRequest = EmailRequest.builder()
                    .email(user.getEmail())
                    .to(request.getEmail())
                    .token(token)
                    .build();
            emailService.sendVerificationEmail(emailRequest);
            log.info("Verification email sent to: {}", user.getEmail());
        } catch (Exception e) {
            log.error("Failed to send verification email", e);
            // Không throw exception để user vẫn được tạo
        }

        RegisterResponse response = userMapper.toRegisterResponse(user);
        response.setMessage("Đăng kí tài khoản thành công, vui lòng xác thực tài khoản");

        return response;
    }

    /**
     * Tạo token xác thực email
     */
    private String generateVerificationToken(User user) {
        // Xóa token cũ nếu có
        tokenRepository.findByUser(user).ifPresent(tokenRepository::delete);
        tokenRepository.flush();

        // Tạo token mới
        String token = UUID.randomUUID().toString();

        EmailVerificationToken verificationToken = EmailVerificationToken.builder()
                .token(token)
                .user(user)
                .expiryDate(LocalDateTime.now().plusHours(1)) // Hết hạn sau 1 giờ
                .build();


        tokenRepository.save(verificationToken);
        return token;
    }

    /**
     * Xác thực email
     */
    @Transactional
    public void verifyEmail(String token) {
        EmailVerificationToken verificationToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new AppException(ErrorCode.TOKEN_INVALID));

        if (verificationToken.isVerified()) {
            throw new AppException(ErrorCode.EMAIL_ISVERIFIED);
        }

        if (verificationToken.isExpired()) {
            throw new AppException(ErrorCode.TOKEN_ISEXPIRED);
        }

        // Cập nhật trạng thái xác thực
        User user = verificationToken.getUser();
        log.info("Verifying email for user: {} (ID: {})", user.getEmail(), user.getId());
        log.info("Current emailVerified status: {}", user.getEmailVerified());

        user.setEmailVerified(true);
        userRepository.save(user);
        userRepository.flush(); // Đảm bảo thay đổi được commit ngay

        // Refresh user để đảm bảo lấy dữ liệu mới nhất
        user = userRepository.findById(user.getId())
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));

        log.info("After save - emailVerified status: {}", user.getEmailVerified());

        // Tạo UserProfile sau khi email đã được xác thực
        createUserProfile(user);

        verificationToken.setVerifiedAt(LocalDateTime.now());
        tokenRepository.save(verificationToken);

        // Gửi email chào mừng
        try {
            emailService.sendWelcomeEmail(user.getEmail(), user.getFullName());
        } catch (Exception e) {
            log.error("Failed to send welcome email", e);
        }

        log.info("Email verified successfully for user: {} - emailVerified: {}",
                user.getEmail(), user.getEmailVerified());
    }

    /**
     * Gửi lại email xác thực
     */
    @Transactional
    public void resendVerificationEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.EMAIL_NOT_EXISTED));

        if (user.getEmailVerified()) {
            throw new AppException(ErrorCode.EMAIL_ISVERIFIED);
        }

        // Tạo token mới
        String token = generateVerificationToken(user);


        // Gửi email
        EmailRequest emailRequest = EmailRequest.builder()
                .email(user.getEmail())
                .to(email)
                .token(token)
                .build();
        emailService.sendVerificationEmail(emailRequest);

        log.info("Resent verification email to: {}", email);
    }

    /**
     * Đăng nhập
     */
    public LoginResponse login(LoginRequest request) {

        // Tìm user theo email
        var user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.EMAIL_NOT_EXISTED));
        if (!user.getEmailVerified()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }
        if (!user.getIsActive()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_CONFIRM);
        }
        // Kiểm tra mật khẩu
        boolean authenticated = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!authenticated) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }


        // Tạo token JWT
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", user.getId());
        claims.put("role", user.getRole());
        String token = jwtUtil.generateToken(user.getId(), claims);
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        return LoginResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .role(String.valueOf(user.getRole()))
                .fullName(user.getFullName())
                .build();


    }

    /**
     * Quên mật khẩu
     */
    @Transactional
    public void forgotPassword(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.EMAIL_NOT_EXISTED));

        // Tạo token reset mật khẩu (thường khác token xác minh email)
        String resetToken = generateVerificationToken(user);

        EmailRequest emailRequest = EmailRequest.builder()
                .to(user.getEmail())
                .email("Đặt lại mật khẩu của bạn")
                .token(resetToken)
                .build();

        emailService.sendResetPasswordEmail(emailRequest);

        log.info("Sent reset password email to: {}", email);
    }

    /**
     * Xác thực email quên mật khẩu
     */
    @Transactional
    public void checkResetPassword(String token) {
        EmailVerificationToken verificationToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new AppException(ErrorCode.TOKEN_INVALID));

        if (verificationToken.isVerified()) {
            throw new AppException(ErrorCode.EMAIL_ISVERIFIED);
        }

        if (verificationToken.isExpired()) {
            throw new AppException(ErrorCode.TOKEN_ISEXPIRED);
        }

        verificationToken.setVerifiedAt(LocalDateTime.now());
        tokenRepository.save(verificationToken);
    }

    /**
     * Xác thực email quên mật khẩu
     */
    @Transactional
    public void resetPassword(PasswordResetRequest request) {
        EmailVerificationToken verificationToken = tokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new AppException(ErrorCode.TOKEN_INVALID));

        if (verificationToken.isExpired()) {
            throw new AppException(ErrorCode.TOKEN_ISEXPIRED);
        }
        if(!request.getPassword().equalsIgnoreCase(request.getPasswordConfirm())){
            throw  new AppException(ErrorCode.INVALID_PASSWORD);
        }
        User user = verificationToken.getUser();
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);

        verificationToken.setVerifiedAt(LocalDateTime.now());
        tokenRepository.save(verificationToken);



    }


    /**
     * Đăng nhập bằng gg
     */

    public LoginResponse loginWithGoogle(GoogleLoginRequest request) {

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = getClass().getClassLoader().getResourceAsStream("firebase-service-account.json");
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();
                FirebaseApp.initializeApp(options);
            }
            //  Xác minh token với Firebase
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(request.getIdToken());
            String email = decodedToken.getEmail();
            String name = request.getDisplayName() != null ? request.getDisplayName() : email;

            // Tìm user theo email hoặc tạo mới
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                User newUser = new User();
                newUser.setEmail(email);
                newUser.setFullName(name);
                newUser.setEmailVerified(true); // Google đã verify email
                newUser.setIsActive(true);
                newUser.setRole("USER");
                newUser.setAuthProvider("GOOGLE");
                User savedUser = userRepository.save(newUser);

                // Tạo UserProfile sau khi email đã được xác thực (Google đã verify)
                createUserProfile(savedUser);

                return savedUser;
            });

            // Sinh JWT cho backend
            Map<String, Object> claims = new HashMap<>();
            claims.put("id", user.getId());
            claims.put("role", user.getRole());
            String token = jwtUtil.generateToken(user.getId(), claims);
            String refreshToken = jwtUtil.generateRefreshToken(user.getId());


            return LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .fullName(user.getFullName())
                    .role(user.getRole())
                    .build();

        } catch (Exception e) {
            log.info(e.toString());
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
    }


    /**
     * Đăng nhập bằng fb
     */

    public LoginResponse loginWithFacebook(FacebookLoginRequest request) {

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = getClass().getClassLoader().getResourceAsStream("firebase-service-account.json");
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();
                FirebaseApp.initializeApp(options);
            }
            //  Xác minh token với Firebase
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(request.getIdToken());
            String email = decodedToken.getEmail();
            String name = request.getDisplayName() != null ? request.getDisplayName() : email;

            // Tìm user theo email hoặc tạo mới
            User user = userRepository.findByEmail(email).orElseGet(() -> {
                User newUser = new User();
                newUser.setEmail(email);
                newUser.setFullName(name);
                newUser.setEmailVerified(true); // Facebook đã verify email
                newUser.setIsActive(true);
                newUser.setRole("USER");
                newUser.setAuthProvider("FACEBOOK");
                User savedUser = userRepository.save(newUser);

                // Tạo UserProfile sau khi email đã được xác thực (Facebook đã verify)
                createUserProfile(savedUser);

                return savedUser;
            });

            // Sinh JWT cho backend
            Map<String, Object> claims = new HashMap<>();
            claims.put("id", user.getId());
            claims.put("role", user.getRole());
            String token = jwtUtil.generateToken(user.getId(), claims);
            String refreshToken = jwtUtil.generateRefreshToken(user.getId());


            return LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .fullName(user.getFullName())
                    .role(user.getRole())
                    .build();

        } catch (Exception e) {
            log.info(e.toString());
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
    }

    /**
     * Tạo UserProfile mặc định cho user mới
     */
    private void createUserProfile(User user) {
        // Kiểm tra xem UserProfile đã tồn tại chưa
        if (!userProfileRepository.existsByUser(user)) {
            UserProfile userProfile = UserProfile.builder()
                    .user(user)
                    .darkModeEnabled(false)
                    .languageSettings("{\"lang\": \"vi\"}")
                    .build();
            userProfileRepository.save(userProfile);
            log.info("UserProfile created for user: {}", user.getEmail());
        }
    }

    /**
     * Lấy user theo email (dùng để debug)
     */
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }
    //Refresh token
    public LoginResponse refreshToken(RefreshTokenRequest refreshTokenRequest) {


        var tokenInDb = refreshTokenRepository.findByToken(refreshTokenRequest.getRefreshToken())
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED));

        if (tokenInDb.isRevoked()) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        // Lấy userId từ token (subject)
        String userId = jwtUtil.extractSubjectAsUserId(refreshTokenRequest.getRefreshToken());

        Map<String, Object> claims = new HashMap<>();
        claims.put("role", userRepository.findById(Long.valueOf(userId))
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED))
                .getRole());

        String newToken = jwtUtil.generateToken(Long.valueOf(userId), claims);


        return LoginResponse.builder()
                .token(newToken)
                .build();
    }

    //Đăng xuất
    public void logoutAdmin(String token) {
        var storedToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED));

        storedToken.setRevoked(true);
        refreshTokenRepository.save(storedToken);
    }
}
