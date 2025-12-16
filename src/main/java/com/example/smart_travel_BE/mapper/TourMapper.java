package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.tour.response.*;
import com.example.smart_travel_BE.entity.Tour;
import com.example.smart_travel_BE.entity.TourImage;
import com.example.smart_travel_BE.entity.TourSchedule;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface TourMapper {

    @Mapping(source = "destination.id", target = "destinationId")
    @Mapping(source = "destination.name", target = "destinationName")
    @Mapping(target = "thumbnail", expression = "java(getThumbnail(tour))")
    TourResponse toSummary(Tour tour);

    @Mapping(source = "destination.id", target = "destinationId")
    @Mapping(source = "destination.name", target = "destinationName")
    @Mapping(target = "included", source = "included", qualifiedByName = "jsonToMap")
    @Mapping(target = "excluded", source = "excluded", qualifiedByName = "jsonToMap")
    TourDetailResponse toDetail(Tour tour);

    default String getThumbnail(Tour tour) {
        if (tour.getImages() != null && !tour.getImages().isEmpty()) {
            return tour.getImages().get(0).getImageUrl();
        }
        return null;
    }

    @Named("jsonToMap")
    public static Map<String, Object> jsonToMap(String json) {
        if (json == null || json.isEmpty()) return Collections.emptyMap();
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            return Collections.emptyMap();
        }
    }
    TourImageResponse toImageResponse(TourImage image);

    TourScheduleResponse toScheduleResponse(TourSchedule schedule);

    List<TourImageResponse> toImageResponses(List<TourImage> images);

    List<TourScheduleResponse> toScheduleResponses(List<TourSchedule> schedules);
}
