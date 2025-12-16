package com.example.smart_travel_BE.config;


import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.User;
import com.example.smart_travel_BE.repository.BookingRepository;
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

import java.math.BigDecimal;
import java.time.LocalDate;

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

    @NonFinal
    static final String TEST_USER_EMAIL = "testuser@gmail.com";
    @NonFinal
    static final String TEST_USER_PASSWORD = "password123";

    @Bean
    @ConditionalOnProperty(
            prefix = "spring",
            value = "datasource.driver-class-name",
            havingValue = "com.mysql.cj.jdbc.Driver")
    ApplicationRunner applicationRunner(UserRepository userRepository, BookingRepository bookingRepository) {
        log.info("Init Application Runner...");
        return args -> {

            if (userRepository.findByEmail(ADMIN_EMAIL).isEmpty()) {
                User adminUser = User.builder()
                        .email(ADMIN_EMAIL)
                        .emailVerified(true)
                        .password(passwordEncoder.encode(ADMIN_PASSWORD))
                        .role("ADMIN")
                        .isActive(true)
                        .build();
                userRepository.save(adminUser);
                log.info("Admin user created: {}", ADMIN_EMAIL);
            }

            User testUser = userRepository.findByEmail(TEST_USER_EMAIL)
                    .orElseGet(() -> {
                        User newUser = User.builder()
                                .email(TEST_USER_EMAIL)
                                .emailVerified(true) // Đã xác thực để test login
                                .password(passwordEncoder.encode(TEST_USER_PASSWORD))
                                .role("USER")
                                .fullName("User Test")
                                .isActive(true)
                                .build();
                        log.info("Test user created: {}", TEST_USER_EMAIL);
                        return userRepository.save(newUser);
                    });

            if (bookingRepository.findFirstByUser(testUser).isEmpty()) {
                Booking testBooking = new Booking();
                testBooking.setUser(testUser);
                testBooking.setBookingType("DESTINATION");
                testBooking.setStartDate(LocalDate.now());
                testBooking.setEndDate(LocalDate.now().plusDays(1));
                testBooking.setNumberOfPeople(2);
                testBooking.setNumberOfRooms(1);
                testBooking.setTotalPrice(new BigDecimal("300000.00"));
                testBooking.setFinalPrice(new BigDecimal("300000.00"));
                testBooking.setStatus("PENDING");

                Booking savedBooking = bookingRepository.save(testBooking);
                log.warn("!!! TEST BOOKING CREATED !!!");
                log.warn("Test Booking ID: {}", savedBooking.getId());
                log.warn("Test Booking Price: {}", savedBooking.getFinalPrice());
            }

            log.info("Application initialization completed ...");
        };
    }
}