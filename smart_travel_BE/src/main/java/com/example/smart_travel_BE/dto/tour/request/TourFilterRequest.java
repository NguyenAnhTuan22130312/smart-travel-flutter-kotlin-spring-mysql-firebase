package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class TourFilterRequest {
    private Integer page;
    private Integer size;

    private BigDecimal minPrice;
    private BigDecimal maxPrice;

    private Integer minDays;
    private Integer maxDays;

    private Integer numberOfPeople;
    private Long destinationId;

    private String sortBy; // "price", "rating", "duration"
    private String sortDir; // "asc" / "desc"
}
