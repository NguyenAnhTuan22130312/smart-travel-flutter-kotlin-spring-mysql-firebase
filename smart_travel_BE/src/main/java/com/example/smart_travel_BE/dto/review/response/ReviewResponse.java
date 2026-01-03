package com.example.smart_travel_BE.dto.review.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class ReviewResponse {
    private Long id;
    private String userFullName;
    private Integer rating;
    private String comment;
    private Integer likesCount;
    private Boolean isApproved;
    private LocalDateTime createdAt;
    private List<String> images;
}
