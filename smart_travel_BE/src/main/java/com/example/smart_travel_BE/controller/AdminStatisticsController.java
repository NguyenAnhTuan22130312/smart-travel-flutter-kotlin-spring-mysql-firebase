package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.statistics.DashboardStatsDTO;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/statistics")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('ADMIN', 'ADMINTOUR', 'ADMINHOTEL')")
public class AdminStatisticsController {
    private final StatisticsService statisticsService;

    /**
     * Lấy thống kê tổng quan Dashboard
     */
    @GetMapping("/dashboard")
    public ResponseEntity<APIResponse<DashboardStatsDTO>> getDashboardStats() {
        DashboardStatsDTO stats = statisticsService.getDashboardStats();
        return ResponseEntity.ok(APIResponse.<DashboardStatsDTO>builder()
                .msg("Lấy thống kê thành công")
                .data(stats)
                .build()
        );
    }
}
