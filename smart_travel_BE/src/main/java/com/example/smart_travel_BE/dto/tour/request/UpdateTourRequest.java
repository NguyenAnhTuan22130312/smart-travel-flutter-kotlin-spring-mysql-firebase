package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class UpdateTourRequest {
    private String name;
    private String description;
    private Double pricePerPerson;
    private Integer durationDays;
    private Integer durationNights;
    private Integer minPeople;
    private Integer maxPeople;
    private Boolean isActive;

    private Map<String, Object> included;
    private Map<String, Object> excluded;
}