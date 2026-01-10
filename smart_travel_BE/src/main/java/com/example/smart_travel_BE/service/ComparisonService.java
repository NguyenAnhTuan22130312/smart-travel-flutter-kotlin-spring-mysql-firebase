package com.example.smart_travel_BE.service;


import com.example.smart_travel_BE.dto.comparison.ComparisonResponse;
import com.example.smart_travel_BE.dto.comparison.HotelComparisonDTO;
import com.example.smart_travel_BE.dto.comparison.TourComparisonDTO;
import com.example.smart_travel_BE.entity.*;
import com.example.smart_travel_BE.repository.HotelRepository;
import com.example.smart_travel_BE.repository.TourRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


@Service
@RequiredArgsConstructor
public class ComparisonService {


    private final TourRepository tourRepository;
    private final HotelRepository hotelRepository;
    private final ObjectMapper objectMapper; // Spring Boot tự động inject ObjectMapper có sẵn


    // --- SO SÁNH TOUR ---
    @Transactional(readOnly = true)
    public ComparisonResponse<TourComparisonDTO> compareTours(Long id1, Long id2) {
        Tour t1 = tourRepository.findById(id1)
                .orElseThrow(() -> new RuntimeException("Tour 1 không tồn tại: " + id1));
        Tour t2 = tourRepository.findById(id2)
                .orElseThrow(() -> new RuntimeException("Tour 2 không tồn tại: " + id2));


        return new ComparisonResponse<>(mapToTourDTO(t1), mapToTourDTO(t2));
    }


    // --- SO SÁNH HOTEL ---
    @Transactional(readOnly = true)
    public ComparisonResponse<HotelComparisonDTO> compareHotels(Long id1, Long id2) {
        Hotel h1 = hotelRepository.findById(id1)
                .orElseThrow(() -> new RuntimeException("Hotel 1 không tồn tại: " + id1));
        Hotel h2 = hotelRepository.findById(id2)
                .orElseThrow(() -> new RuntimeException("Hotel 2 không tồn tại: " + id2));


        return new ComparisonResponse<>(mapToHotelDTO(h1), mapToHotelDTO(h2));
    }


    // --- HELPER MAPPERS ---


    private TourComparisonDTO mapToTourDTO(Tour tour) {
        String imgUrl = tour.getImages().isEmpty() ? null : tour.getImages().get(0).getImageUrl();


        return TourComparisonDTO.builder()
                .id(tour.getId())
                .name(tour.getName())
                .imageUrl(imgUrl)
                .price(tour.getPricePerPerson())
                .durationDays(tour.getDurationDays())
                .durationNights(tour.getDurationNights())
                .rating(tour.getAverageRating() != null ? tour.getAverageRating().doubleValue() : 0.0)
                .reviewCount(tour.getReviewCount())
                .destinationName(tour.getDestination().getName())
                .maxPeople(tour.getMaxPeople())
                .included(parseJsonToList(tour.getIncluded())) // Parse JSON string
                .excluded(parseJsonToList(tour.getExcluded())) // Parse JSON string
                .build();
    }


    private HotelComparisonDTO mapToHotelDTO(Hotel hotel) {
        return HotelComparisonDTO.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .imageUrl(hotel.getThumbnail())
                .pricePerNight(hotel.getPricePerNight()) // Hoặc dùng logic getMinPrice() của bạn
                .stars(hotel.getStarRating())
                .rating(hotel.getAverageRating() != null ? hotel.getAverageRating().doubleValue() : 0.0)
                .reviewCount(hotel.getReviewCount())
                .address(hotel.getAddress())
                .destinationName(hotel.getDestination().getName())
                .totalRooms(hotel.getTotalRooms())
                .amenities(parseJsonToList(hotel.getAmenities())) // Parse JSON string (Wifi, Gym...)
                .build();
    }


    // Hàm tiện ích để chuyển String JSON thành List<String>
    private List<String> parseJsonToList(String jsonString) {
        if (jsonString == null || jsonString.isEmpty()) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(jsonString, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            // Nếu lỗi parse (hoặc dữ liệu cũ không phải json), trả về list rỗng hoặc list chứa string gốc
            System.err.println("Lỗi parse JSON: " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
