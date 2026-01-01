package com.example.smart_travel_BE.dto.hotel.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelDetailResponse {
    private Long id;
    private String name;
    private String address;
    private Integer stars;
    private Double rating;
    private Integer numOfReviews;
    private String description;
    private String thumbnail;  // Ảnh đại diện chính (thumbnail) của khách sạn
    private List<String> images;
    private String destinationName;
    private String phone;
    private String email;
    private Long destinationId;
    private List<String> amenities;
    private String provinceName;
    private List<RoomTypeResponse> rooms;
    private Double minPrice;
    private Double latitude;
    private Double longitude;
    private BigDecimal pricePerNight; // giá mặc định / hiển thị


}