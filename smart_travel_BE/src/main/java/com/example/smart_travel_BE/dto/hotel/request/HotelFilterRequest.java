package com.example.smart_travel_BE.dto.hotel.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class HotelFilterRequest {
    private Long destinationId;
    private String keyword;
    private Integer minStars;
    private Integer maxStars;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String city;

    // Pagination
    private Integer page = 0;
    private Integer size = 10;

    // Optional sorting
    private String sortBy = "pricePerNight";
    private String sortDir = "asc";
}
