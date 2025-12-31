package com.example.smart_travel_BE.dto.hotel.request;

import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoomTypeCreateRequest {
    private String name;
    private Integer capacity;
    private BigDecimal price;
    private Integer totalRooms;
    private List<String> amenities;
}
