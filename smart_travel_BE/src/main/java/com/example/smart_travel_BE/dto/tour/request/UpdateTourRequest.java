package com.example.smart_travel_BE.dto.tour.request;

import com.example.smart_travel_BE.dto.tour.response.TourImageResponse;
import com.example.smart_travel_BE.dto.tour.response.TourScheduleResponse;
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
    private List<TourImageResponse> images;
    private List<TourScheduleResponse> schedules;

    private List<String> included;
    private List<String> excluded;
}