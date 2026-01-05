package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.List;
import java.util.Map;

@Data
public class CreateTourRequest {
    private String name;
    private String description;
    private Long destinationId;

    private BigDecimal pricePerPerson;
    private Integer durationDays;
    private Integer durationNights;
    private Integer minPeople;
    private Integer maxPeople;
    private BigInteger owned_id;

    private Map<String, Object> included;
    private Map<String, Object> excluded;

    private List<TourImageRequest> images;
    private List<TourScheduleRequest> schedules;
}
