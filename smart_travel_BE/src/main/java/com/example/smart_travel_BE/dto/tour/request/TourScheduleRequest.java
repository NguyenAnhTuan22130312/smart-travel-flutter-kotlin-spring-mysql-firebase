package com.example.smart_travel_BE.dto.tour.request;

import lombok.Data;

@Data
public class TourScheduleRequest {
    private Integer dayNumber;
    private String title;
    private String activities;
    private String meals;
    private String accommodation;
}

