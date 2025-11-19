package com.example.smart_travel_BE.dto.user.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProfileResponse {
    // Thông tin từ User
    private Long id;
    private String email;
    private String fullName;
    private String phone;
    private String role;
    private String authProvider;
    private Boolean emailVerified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Thông tin từ UserProfile
    private String avatarUrl;
    private String bio;
    private String gender;
    private LocalDate dateOfBirth;
    private String address;
    private String city;
    private String country;
    private String notificationSettings; // JSON string
    private String languageSettings; // JSON string
    private Boolean darkModeEnabled;
    private LocalDateTime profileUpdatedAt;
}

