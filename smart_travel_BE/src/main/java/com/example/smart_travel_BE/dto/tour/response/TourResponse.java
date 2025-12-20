package com.example.smart_travel_BE.dto.tour.response;

import lombok.Data;

@Data
public class TourResponse {

    private Long id;
    private String name;

    private Long destinationId;
    private String destinationName;

    private Integer durationDays;
    private Double pricePerPerson;

    private Double averageRating;
    private Integer reviewCount;
    private boolean isActive;

    private String thumbnail; // ảnh đầu tiên
}
