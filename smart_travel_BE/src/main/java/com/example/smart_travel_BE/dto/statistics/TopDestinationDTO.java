package com.example.smart_travel_BE.dto.statistics;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopDestinationDTO {
    private Long id;
    private String name;
    private Long viewCount;
    private String provinceName;
}
