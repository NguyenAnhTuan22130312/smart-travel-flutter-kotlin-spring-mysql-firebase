package com.example.smart_travel_BE.dto.tour.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TourImageResponse {
    private Long id;
    private String imageUrl;
    private Boolean isPrimary;
    private Integer displayOrder;
}
