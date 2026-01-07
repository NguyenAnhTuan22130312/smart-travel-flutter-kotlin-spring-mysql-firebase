package com.example.smart_travel_BE.dto.destination.response;

import com.example.smart_travel_BE.dto.hotel.response.HotelSummaryResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.dto.review.response.ReviewResponse;
import com.example.smart_travel_BE.dto.tour.response.TourSummaryResponse;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class DestinationDetailResponse {
    private Long id;
    private String name;
    private String description;
    private String category;
    private String address;
    private Double latitude;
    private Double longitude;

    private ProvinceResponse province;

    private BigDecimal averageRating;
    private Integer reviewCount;
    private Long viewCount;

    private BigDecimal entryFee;
    private String openingHours;

    private Boolean isActive;
    private Boolean isFeatured;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    //  Danh sách ảnh
    private List<DestinationImageResponse> images;

    //Danh sách khách sạn liên quan
    private List<HotelSummaryResponse> hotels;

    // Danh sách tour liên quan
    private List<TourSummaryResponse> tours;

    // Đánh giá người dùng
    private List<ReviewResponse> reviews;

    private String audioScript;
    private Long experienceReward;

}
