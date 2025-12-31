package com.example.smart_travel_BE.dto.hotel.request;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelCreateRequest {

    private String name;
    private String address;
    private Integer stars;
    private String description;

    private Double latitude;
    private Double longitude;

    private Long destinationId;
    private String phone;
    private String email;
    private List<String> amenities;
    private Integer totalRooms;
    private Integer availableRooms;
    private String thumbnail;

    private List<String> images;
    private List<RoomTypeCreateRequest> roomTypes;
}
