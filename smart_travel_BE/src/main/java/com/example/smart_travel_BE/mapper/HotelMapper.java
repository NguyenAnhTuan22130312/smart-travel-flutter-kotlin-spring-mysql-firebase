package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.hotel.response.HotelResponse;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.HotelImage;

import java.math.BigDecimal;

public interface HotelMapper {

    static HotelResponse toResponse(Hotel hotel) {
        // Nếu hotel null thì không xử lý
        if (hotel == null) return null;

        // 1. Tính trung bình rating + số lượng review
        double avgRating = 0.0;
        int numOfReviews = 0;

        if (hotel.getReviews() != null && !hotel.getReviews().isEmpty()) {
            numOfReviews = hotel.getReviews().size();
            double sum = hotel.getReviews().stream()
                    .filter(r -> r.getRating() != null)
                    .mapToDouble(r -> r.getRating())
                    .sum();
            avgRating = numOfReviews > 0 ? sum / numOfReviews : 0.0;
        }

        // 2. Lấy ảnh đại diện (thumbnail)
        String thumbnail = null;

        if (hotel.getImages() != null && !hotel.getImages().isEmpty()) {
            // Ưu tiên ảnh có type = "thumbnail" nếu có
            HotelImage thumbImage = hotel.getImages().stream()
                    .filter(img -> "thumbnail".equalsIgnoreCase(img.getType()))
                    .findFirst()
                    .orElse(hotel.getImages().get(0)); // nếu không có thì lấy ảnh đầu tiên

            thumbnail = thumbImage.getUrl();
        }

        // 3️. Lấy giá tối thiểu (minPrice)
        BigDecimal minPrice = hotel.getMinPrice();

        // 4️. Xây dựng DTO trả về
        return HotelResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .minPrice(minPrice)
                .stars(hotel.getStars())
                .rating(avgRating)
                .numOfReviews(numOfReviews)
                .thumbnail(thumbnail)
                .destinationId(hotel.getDestination() != null ? hotel.getDestination().getId() : null)
                .destinationName(hotel.getDestination() != null ? hotel.getDestination().getName() : null)
                .build();
    }
}
