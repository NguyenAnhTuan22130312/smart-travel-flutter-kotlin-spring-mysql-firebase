package com.example.smart_travel_BE.dto.tour.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
public class TourDetailResponse {
    private Long id;
    private String name;
    private Long destinationId;
    private String destinationName;
    private String description;
    private Integer durationDays;
    private Integer durationNights;
    private BigDecimal pricePerPerson;
    private Integer maxPeople;
    private Integer minPeople;
    private String included;
    private String excluded;
    private Double averageRating;
    private Integer reviewCount;
    private Integer bookingCount;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<TourImageResponse> images;
    private List<TourScheduleResponse> schedules;
}
