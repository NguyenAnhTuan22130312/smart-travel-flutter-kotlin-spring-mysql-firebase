package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.entity.Hotel;

public class HotelMapper {

    /**
     * Chuyển đổi từ Entity Hotel sang DTO HotelResponse
     */
    public static HotelResponse toResponse(Hotel hotel) {
        if (hotel == null) return null;

        return HotelResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .minPrice(hotel.getMinPrice()) // dùng phương thức helper đã có trong Hotel entity
                .stars(hotel.getStarRating())
                .rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : 0.0)
                .numOfReviews(hotel.getReviewCount())
                .thumbnail(hotel.getThumbnail()) // dùng helper method trong Hotel entity
                .destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null)
                .destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null)
                .build();
    }
}
