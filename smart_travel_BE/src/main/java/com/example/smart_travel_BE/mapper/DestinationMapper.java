package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.destination.request.DestinationRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationDetailResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.dto.hotel.response.HotelSummaryResponse;
import com.example.smart_travel_BE.dto.review.response.ReviewResponse;
import com.example.smart_travel_BE.dto.tour.response.TourSummaryResponse;
import com.example.smart_travel_BE.entity.*;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface DestinationMapper {

    Destination toDestination(DestinationRequest destinationRequest);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationResponse toDestinationResponse(Destination destination);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationFeaturedResponse toDestinationFeaturedResponse(Destination destination);

    DestinationDetailResponse toDestinationDetailResponse(Destination destination);

    // Chuyển Tour -> TourSummaryResponse (ảnh đầu tiên)
    @Mapping(target = "images", ignore = true)
    TourSummaryResponse map(Tour tour);

    // Chuyển Hotel -> HotelSummaryResponse (ảnh đầu tiên)
    @Mapping(target = "images", ignore = true)
    HotelSummaryResponse map(Hotel hotel);

    // Chuyển Review -> ReviewResponse (danh sách ảnh)
    @Mapping(target = "images", source = "images")
    ReviewResponse map(Review review);

    @AfterMapping
    default void mapImageUrl(Destination destination, @MappingTarget DestinationFeaturedResponse response) {
        if (destination.getImages() != null && !destination.getImages().isEmpty()) {
            // Lấy ảnh đầu tiên
            response.setImageUrl(destination.getImages().get(0).getImageUrl());
        } else {
            // Trường hợp không có ảnh
            response.setImageUrl(null);
        }
    }
    @AfterMapping
    default void mapImageUrl(Destination destination, @MappingTarget DestinationResponse response) {
        if (destination.getImages() != null && !destination.getImages().isEmpty()) {
            // Lấy ảnh đầu tiên
            response.setImageUrl(destination.getImages().get(0).getImageUrl());
        } else {
            // Trường hợp không có ảnh
            response.setImageUrl(null);
        }
    }

    // ====== Sau khi map xong, gán ảnh đầu tiên cho Tour ======
    @AfterMapping
    default void mapTourImage(Tour tour, @MappingTarget TourSummaryResponse response) {
        if (tour.getImages() != null && !tour.getImages().isEmpty()) {
            response.setImages(List.of(tour.getImages().get(0).getImageUrl()).toString());
        } else {
            response.setImages(String.valueOf(new ArrayList<>()));
        }
    }

    // ====== Sau khi map xong, gán ảnh đầu tiên cho Hotel ======
    @AfterMapping
    default void mapHotelImage(Hotel hotel, @MappingTarget HotelSummaryResponse response) {
        if (hotel.getImages() != null && !hotel.getImages().isEmpty()) {
            response.setImages(List.of(hotel.getImages().get(0).getImageUrl()).toString());
        } else {
            response.setImages(String.valueOf(new ArrayList<>()));
        }
    }

    // ====== Chuyển danh sách ảnh Review -> danh sách URL ======
    default List<String> map(List<ReviewImage> images) {
        if (images == null) {
            return new ArrayList<>();
        }
        return images.stream()
                .map(ReviewImage::getImageUrl)
                .collect(Collectors.toList());
    }
}
