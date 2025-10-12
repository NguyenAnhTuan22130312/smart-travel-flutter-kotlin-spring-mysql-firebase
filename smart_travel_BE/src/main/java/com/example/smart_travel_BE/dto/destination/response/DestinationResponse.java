package com.example.smart_travel_BE.dto.destination.response;

import com.example.smart_travel_BE.entity.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
public class DestinationResponse {
    private Long id;

    private String name;


    private Province province;


    private String description;


    private String category;


    private Double latitude;

    private Double longitude;


    private String address;


    private BigDecimal averageRating ;


    private Integer reviewCount ;


    private Long viewCount ;


    private Boolean isActive ;


    private Boolean isFeatured ;

    private String openingHours;


    private BigDecimal entryFee;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private List<DestinationImage> images = new ArrayList<>();

    private List<Review> reviews = new ArrayList<>();

    private List<Hotel> hotels = new ArrayList<>();

    private List<Tour> tours = new ArrayList<>();
}
