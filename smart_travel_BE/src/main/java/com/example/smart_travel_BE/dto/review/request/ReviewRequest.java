
package com.example.smart_travel_BE.dto.review.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
public class ReviewRequest {

    @NotNull(message = "Rating không được để trống")
    @Min(value = 1)
    @Max(value = 5)
    private Integer rating;

    private String comment;

    private List<MultipartFile> images;  // có thể null

    @NotBlank(message = "Invoice Number không được để trống")
    private String invoiceNumber;
}