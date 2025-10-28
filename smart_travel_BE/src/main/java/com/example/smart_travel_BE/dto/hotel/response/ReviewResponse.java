package com.example.smart_travel_BE.dto.hotel.response;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewResponse {
    private String userName;
    private Double rating;
    private String comment;
    private LocalDateTime createdAt;
}
