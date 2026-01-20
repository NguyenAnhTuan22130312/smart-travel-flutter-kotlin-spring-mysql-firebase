package com.example.smart_travel_BE.dto.chat;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RecommendationDTO {
    private Long id;
    private String name;
    private String imageUrl;
    private String address;
    private Double price;
    private Double rating;
    private Integer reviewCount;
    private String type;
}