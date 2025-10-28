package com.example.smart_travel_BE.dto.province.response;

import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import lombok.Data;

import java.util.List;

@Data
public class ProvinceDetailResponse {

    private Long id;

    private String name;

    private String code;

    private String region;

    private String description;

    private String imageUrl;

    private Boolean isPopular;

    private int destinationCount;

    private List<DestinationResponse> destinations;
}
