package com.example.smart_travel_BE.dto.hotel.response;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class HotelSummaryResponse {
    private Long id;
    private String name;
    private String address;
    private BigDecimal pricePerNight;
    private Integer starRating;
    private BigDecimal averageRating;
    private String images; // Ảnh đầu tiên của khách sạn
}
