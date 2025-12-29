package com.example.smart_travel_BE.dto.banner.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BannerUpdateRequest {
    @NotBlank(message = "BANNER_NAME_BLANK")
    String title;

    @NotBlank(message = "IMAGE_URL_BLANK")
    String imageUrl;

    String linkUrl;
    String description;
    boolean active;
}