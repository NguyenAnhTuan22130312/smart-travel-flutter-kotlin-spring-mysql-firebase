package com.example.smart_travel_BE.dto.destination.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class DestinationImageUploadRequest {
    private Boolean isPrimary = false;
    private Integer displayOrder;
 }
