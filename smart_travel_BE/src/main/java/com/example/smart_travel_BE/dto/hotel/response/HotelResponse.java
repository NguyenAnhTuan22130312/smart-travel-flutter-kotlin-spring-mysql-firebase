package com.example.smart_travel_BE.dto.hotel.response;

import lombok.*;

import java.math.BigDecimal;

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
}
