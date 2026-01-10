package com.example.smart_travel_BE.dto.comparison;


import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;


@Data
@Builder
public class HotelComparisonDTO {
    private Long id;
    private String name;
    private String imageUrl;
    private BigDecimal pricePerNight;
    private Integer stars;
    private Double rating;
    private Integer reviewCount;
    private String address;
    private String destinationName;


    private List<String> amenities;
    private Integer totalRooms;
}
