package com.example.smart_travel_BE.dto.hotel.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelResponse {
    private Long id;
    private String name;
    private String address;
    private BigDecimal minPrice;
    private Integer stars;
    private Double rating;        // trung bình rating từ reviews
    private Integer numOfReviews; // số lượt review
    private String thumbnail;     // url ảnh đại diện (nếu có)
    private Long destinationId;
    private String destinationName;
    private String phone;
    private String email;
    private String description;
    private List<String> amenities; // Tiện ích khách sạn
    private Integer totalRooms;
    private Integer availableRooms;
    private Double latitude;
    private Double longitude;
}

