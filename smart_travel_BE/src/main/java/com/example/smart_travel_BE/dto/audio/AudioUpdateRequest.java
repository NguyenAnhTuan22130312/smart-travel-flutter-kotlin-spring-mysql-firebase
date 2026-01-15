package com.example.smart_travel_BE.dto.audio;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AudioUpdateRequest {
    private String audioScript;
}
