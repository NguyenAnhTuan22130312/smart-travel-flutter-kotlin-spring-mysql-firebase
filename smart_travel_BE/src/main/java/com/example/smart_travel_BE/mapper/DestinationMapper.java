package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.destination.request.DestinationCreateRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationUpdateRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationDetailResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationImageResponse;
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
import java.util.Optional;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface DestinationMapper {

    Destination toDestination(DestinationRequest destinationRequest);
    Destination toDestination(DestinationCreateRequest request);
    DestinationImageResponse toImageResponse (DestinationImage img);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationResponse toDestinationResponse(Destination destination);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationFeaturedResponse toDestinationFeaturedResponse(Destination destination);


    DestinationDetailResponse toDestinationDetailResponse(Destination destination);

    void updateDestinationFromRequest(DestinationUpdateRequest request, @MappingTarget Destination destination);


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
            // SỬA LẠI: Lấy trực tiếp chuỗi URL của ảnh đầu tiên
            // Không dùng List.of(...).toString() nữa
            response.setImages(tour.getImages().get(0).getImageUrl());
        } else {
            response.setImages(null); // Hoặc để "" tùy bạn
        }
    }

    // ====== Sau khi map xong, gán ảnh đầu tiên cho Hotel ======
    @AfterMapping
    default void mapHotelImage(Hotel hotel, @MappingTarget HotelSummaryResponse response) {
        if (hotel.getImages() != null && !hotel.getImages().isEmpty()) {
            // Lấy ảnh chính (isPrimary = true)
            Optional<HotelImage> primaryImage = hotel.getImages().stream()
                    .filter(HotelImage::getIsPrimary)
                    .findFirst();
            response.setImages(primaryImage.map(HotelImage::getImageUrl)
                    .orElse(null));
        } else {
            response.setImages(null); // nếu không có ảnh
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

//    @AfterMapping
//    default void mapDestinationImages(Destination destination, @MappingTarget DestinationDetailResponse response) {
//        if (destination.getImages() != null && !destination.getImages().isEmpty()) {
//            // Lấy danh sách URL ảnh
//            List<String> imageUrls = destination.getImages()
//                    .stream()
//                    .map(DestinationImage::getImageUrl)
//                    .collect(Collectors.toList());
//            response.setImageUrls(imageUrls);
//        } else {
//            response.setImageUrls(new ArrayList<>());
//        }
//    }
    @AfterMapping
    default void mapUserFullName(Review review, @MappingTarget ReviewResponse response) {
        if (review.getUser() != null && review.getUser().getFullName() != null) {
            response.setUserFullName(review.getUser().getFullName());
        } else {
            response.setUserFullName("Ẩn danh"); // hoặc để null tùy yêu cầu
        }
    }
}
