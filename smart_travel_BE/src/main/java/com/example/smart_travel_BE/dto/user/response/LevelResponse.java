package com.example.smart_travel_BE.dto.user.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LevelResponse {
    private String currentLevel;
    private Long experiencePoints; // Đây là TỔNG ĐIỂM mới
    private Long nextLevelAt;
    private Double progressPercentage;
    private Boolean isLevelUp;
    private Long earnedExp; //  Số điểm vừa nhận được (20-50)
    private java.time.LocalDateTime serverTime;
}

