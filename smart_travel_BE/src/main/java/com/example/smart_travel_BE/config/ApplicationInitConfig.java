package com.example.smart_travel_BE.config;


import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;



@Configuration
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ApplicationInitConfig {

    PasswordEncoder passwordEncoder;
    @NonFinal
    static final String ADMIN_EMAIL = "tuansdev@gmail.com";

    @NonFinal
    static final String ADMIN_PASSWORD = "tuansdev";

    // Tạo Admin
    @Bean
    @ConditionalOnProperty(
            prefix = "spring",
            value = "datasource.driver-class-name",
            havingValue = "com.mysql.cj.jdbc.Driver")
    //chỉ khi bạn đang dùng SQL Server thì phương thức này mới được kích hoạt.
    ApplicationRunner applicationRunner(UserRepository userRepository) {
        log.info("Init Application Runner...");
        return args -> { // một biểu thức lambda, thực hiện nhiệm vụ định nghĩa hành động bên trong ApplicationRunner.

            if (userRepository.findByEmail(ADMIN_EMAIL).isEmpty()) {

                User user = User.builder()
                        .email(ADMIN_EMAIL)
                        .emailVerified(true)
                        .password(passwordEncoder.encode(ADMIN_PASSWORD))
                        .role("ADMIN")
                        .isActive(true)
                        .build();

                userRepository.save(user);
            }
            log.info("Application initialization completed ...");
        };
    }
}
