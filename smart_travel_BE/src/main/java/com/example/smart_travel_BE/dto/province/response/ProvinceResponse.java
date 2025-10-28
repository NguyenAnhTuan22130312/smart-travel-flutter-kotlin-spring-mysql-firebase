package com.example.smart_travel_BE.dto.province.response;


import lombok.Data;

@Data
public class ProvinceResponse {

    private Long id;

    private String name;

    private String code;

    private String region;

    private String description;

    private String imageUrl;

    private Boolean isPopular;

    private int destinationCount;
}
