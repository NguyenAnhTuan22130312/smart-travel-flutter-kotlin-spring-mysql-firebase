package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;

@Data
public class TourImageRequest {
    private String id;
    private String imageUrl;
    private Boolean isPrimary;
    private Integer displayOrder;
}

