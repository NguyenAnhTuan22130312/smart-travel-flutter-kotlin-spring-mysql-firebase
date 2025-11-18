package com.example.smart_travel_BE.dto.destination.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DestinationImageResponse {
    private Long id;
    private String imageUrl;
    private Boolean isPrimary;
    private Integer displayOrder;
    private LocalDateTime uploadedAt;
}
