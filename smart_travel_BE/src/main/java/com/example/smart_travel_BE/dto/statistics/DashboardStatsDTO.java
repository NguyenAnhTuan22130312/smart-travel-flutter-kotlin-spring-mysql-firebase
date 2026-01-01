package com.example.smart_travel_BE.dto.statistics;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

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
    private List<TopDestinationDTO> topDestinations;
}
