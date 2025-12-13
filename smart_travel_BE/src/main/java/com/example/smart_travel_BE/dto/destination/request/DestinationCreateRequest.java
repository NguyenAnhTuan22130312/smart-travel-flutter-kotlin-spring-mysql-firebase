package com.example.smart_travel_BE.dto.destination.request;

import jakarta.validation.constraints.*;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Data
public class DestinationCreateRequest {
    @NotBlank(message = "DESTINATION_NAME_BLANK")
    @Size(min = 2, max = 200, message = "DESTINATION_NAME_SIZE")
    private String name;

    @NotNull(message = "PROVINCE_ID_REQUIRED")
    private Long provinceId;

    private String description;

    @Size(min = 2, max = 100, message = "CATEGORY_SIZE")
    private String category;

    @NotNull(message = "LATITUDE_REQUIRED")
    @Min(value = -90, message = "LATITUDE_INVALID")
    @Max(value = 90, message = "LATITUDE_INVALID")
    private Double latitude;

    @NotNull(message = "LONGITUDE_REQUIRED")
    @Min(value = -180, message = "LONGITUDE_INVALID")
    @Max(value = 180, message = "LONGITUDE_INVALID")
    private Double longitude;

    private String address;

    @Min(value = 0, message = "ENTRY_FEE_NEGATIVE")
    private BigDecimal entryFee;

    private String openingHours; // JSON string
    private Boolean isFeatured;
}
