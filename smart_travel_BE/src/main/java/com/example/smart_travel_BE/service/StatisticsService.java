package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.statistics.DashboardStatsDTO;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.ProvinceRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.example.smart_travel_BE.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class StatisticsService {

    private final UserRepository userRepository;
    private final ProvinceRepository provinceRepository;
    private final HotelRepository hotelRepository;
    private final TourRepository tourRepository;

    /**
     * Lấy thống kê tổng quan Dashboard
     */
    public DashboardStatsDTO getDashboardStats() {
        log.info("Fetching dashboard statistics");

        return DashboardStatsDTO.builder()
                .totalUsers(userRepository.count())
                .totalProvinces(provinceRepository.count())
                .totalHotels(hotelRepository.count())
                .totalTours(tourRepository.count())
                .build();
    }
}
