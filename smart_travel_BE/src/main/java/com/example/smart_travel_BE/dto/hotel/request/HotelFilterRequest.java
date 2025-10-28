package com.example.smart_travel_BE.dto.hotel.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class HotelFilterRequest {
    private Long destinationId;
    private String keyword;
    private Integer minStars;
    private Integer maxStars;
    private Double minPrice;
    private Double maxPrice;
    private String city;
    private Integer page;
    private Integer size;
}
