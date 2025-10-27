package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.destination.request.DestinationRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.entity.Destination;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface DestinationMapper {

    Destination toDestination(DestinationRequest destinationRequest);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationResponse toDestinationResponse(Destination destination);

    @Mapping(source = "province.name", target = "provinceName")
    DestinationFeaturedResponse toDestinationFeaturedResponse(Destination destination);

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
}
