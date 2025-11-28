package com.example.smart_travel_BE.dto.tour.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TourScheduleResponse {
    private Long id;
    private Integer dayNumber;
    private String title;
    private String activities;
    private String accommodation;
    private String meals;
}
