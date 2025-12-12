package com.example.smart_travel_BE.dto.user.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSummaryResponse {
    // User basic fields
    private Long id;
    private String email;
    private String fullName;
    private String phone;
    private String role;
    private String authProvider;
    private Boolean isActive;
    private Boolean emailVerified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // UserProfile fields
    private String avatarUrl;
    private String bio;
    private String gender;
    private LocalDate dateOfBirth;
    private String address;
    private String city;
    private String country;
    private String currentLevel;
    private Integer experiencePoints;
}
