package com.example.smart_travel_BE.dto.hotel.response;

import lombok.*;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoomTypeResponse {
    private Long id;
    private String name;
    private Integer capacity;         // Sức chứa tối đa
    private BigDecimal price;         // Giá / đêm
    private Integer availableRooms;   // Số phòng trống (nếu có)
    private String amenities;         // JSON hoặc text: ["WiFi","Breakfast","Pool"]
}
