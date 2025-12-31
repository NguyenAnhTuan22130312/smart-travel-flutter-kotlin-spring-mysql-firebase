package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.hotel.response.HotelDetailResponse;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.HotelImage;

public interface HotelMapper {

    /**
     * Chuyển đổi từ Entity Hotel sang DTO HotelResponse
     */
    public static HotelDetailResponse toDetailResponse(Hotel hotel) {
        if (hotel == null) return null;

        return HotelDetailResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .stars(hotel.getStarRating())
                .rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : 0.0)
                .numOfReviews(hotel.getReviewCount())
                .description(hotel.getDescription())
                .thumbnail(hotel.getThumbnail())
                .images(
                        hotel.getImages() != null
                                ? hotel.getImages().stream().map(HotelImage::getImageUrl).toList()
                                : null
                )
                .destinationName(
                        hotel.getDestination() != null
                                ? hotel.getDestination().getName()
                                : null
                )
                .provinceName(
                        hotel.getDestination() != null && hotel.getDestination().getProvince() != null
                                ? hotel.getDestination().getProvince().getName()
                                : null
                )
                .rooms(
                        hotel.getRoomTypes() != null
                                ? hotel.getRoomTypes().stream()
                                .map(RoomTypeMapper::toResponse)
                                .toList()
                                : null
                )
                .latitude(hotel.getLatitude())
                .longitude(hotel.getLongitude())
                .build();
    }
}
