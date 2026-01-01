package com.example.smart_travel_BE.dto.banner.response;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BannerResponse {
    Long id;
    String title;
    String imageUrl;
    String linkUrl;
    String description;
    boolean active;
}