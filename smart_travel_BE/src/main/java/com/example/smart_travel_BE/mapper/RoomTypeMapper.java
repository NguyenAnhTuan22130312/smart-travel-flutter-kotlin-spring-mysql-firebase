package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.hotel.response.RoomTypeResponse;
import com.example.smart_travel_BE.entity.RoomType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public interface RoomTypeMapper {

    public static RoomTypeResponse toResponse(RoomType rt) {
        if (rt == null) return null;

        // Tạm tính availableRooms = totalRooms này tạm tính thôi nha
        // nên chỉnh sửa lại theo cthuc : Available = Total - Đã đặt (Booked) - Đang bảo trì.
        Integer available = rt.getTotalRooms();
        List<String> amenitiesList = new ArrayList<>();
        if (rt.getAmenities() != null && !rt.getAmenities().isEmpty()) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                amenitiesList = mapper.readValue(rt.getAmenities(), new TypeReference<List<String>>() {
                });
            } catch (Exception e) {
                // Nếu dữ liệu cũ không phải JSON chuẩn thì bọc tạm vào list để không bị lỗi
                amenitiesList = Collections.singletonList(rt.getAmenities());
            }
        }

        return RoomTypeResponse.builder()
                .id(rt.getId())
                .name(rt.getName())
                .capacity(rt.getCapacity())
                .price(rt.getPrice())
                .availableRooms(available)
                .amenities(amenitiesList)
                .build();
    }
}
