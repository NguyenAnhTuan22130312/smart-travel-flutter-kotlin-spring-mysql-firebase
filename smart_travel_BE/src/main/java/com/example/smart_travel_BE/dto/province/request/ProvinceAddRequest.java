package com.example.smart_travel_BE.dto.province.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ProvinceAddRequest {

    @NotBlank(message = "NOT_BLANK_PROVINCE_NAME")
    @Size(min = 2, max = 100, message = "SIZE_PROVINCE_NAME")
    private String name;

    @NotBlank(message = "NOT_BLANK_PROVINCE_CODE")
    @Size(min = 2, max = 10, message = "SIZE_PROVINCE_CODE")
    private String code;

    @NotBlank(message = "NOT_BLANK_REGION")
    private String region;

    private String description;

     @NotNull(message = "NOT_NULL_IS_POPULAR")
    private Boolean isPopular;
}
