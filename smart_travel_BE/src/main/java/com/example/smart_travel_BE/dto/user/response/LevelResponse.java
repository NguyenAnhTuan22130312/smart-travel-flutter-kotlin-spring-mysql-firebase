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
    private String currentBadge;
    private Long experiencePoints;
    private Long nextLevelAt;
    private Double progressPercentage;
    private String achievements;
}

