package com.example.smart_travel_BE.dto.tour.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class TourSummaryResponse {
    private Long id;
    private String name;
    private Integer durationDays;
    private BigDecimal pricePerPerson;
    private BigDecimal averageRating;
    private String destinationName;
    private Boolean isActive;
    private Integer bookingCount;
    private LocalDateTime createdAt;
    private String images; // Ảnh đầu tiên của tour
}
