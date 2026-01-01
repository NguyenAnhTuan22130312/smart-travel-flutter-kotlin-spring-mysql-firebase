package com.example.smart_travel_BE.dto.statistics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private Long totalUsers;
    private Long totalProvinces;
    private Long totalDestinations;
    private Long totalHotels;
    private Long totalTours;
}
