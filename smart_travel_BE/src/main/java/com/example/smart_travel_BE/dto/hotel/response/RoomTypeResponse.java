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
    private Integer capacity;  // Sức chứa tối đa của phòng (số người/phòng)
    private BigDecimal price;
    private Integer availableRooms;
    private String amenities; // Tiện nghi trong phòng (ví dụ: “WiFi, Breakfast, Sea View”), có thể lưu dạng JSON
}
