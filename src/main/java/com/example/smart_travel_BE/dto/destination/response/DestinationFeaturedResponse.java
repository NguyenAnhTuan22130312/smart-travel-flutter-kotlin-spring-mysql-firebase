package com.example.smart_travel_BE.dto.destination.response;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class DestinationFeaturedResponse {
    private Long id;

    private String name;

    private String provinceName;

    private String category;

    private String address;

    private BigDecimal averageRating ;

    private Integer reviewCount ;

    private Long viewCount ;

    private Boolean isActive ;

    private Boolean isFeatured ;

    private BigDecimal entryFee;

    private String imageUrl;

}
