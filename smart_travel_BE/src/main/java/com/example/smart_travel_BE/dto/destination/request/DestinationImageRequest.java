package com.example.smart_travel_BE.dto.destination.request;

import lombok.Data;

@Data
public class DestinationImageRequest {
    private Boolean isPrimary = false;
    private Integer displayOrder;
}
