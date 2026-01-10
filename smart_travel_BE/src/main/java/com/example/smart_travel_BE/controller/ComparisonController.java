package com.example.smart_travel_BE.controller;


import com.example.smart_travel_BE.dto.comparison.ComparisonResponse;
import com.example.smart_travel_BE.dto.comparison.HotelComparisonDTO;
import com.example.smart_travel_BE.dto.comparison.TourComparisonDTO;
import com.example.smart_travel_BE.service.ComparisonService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/v1/compare")
@RequiredArgsConstructor
public class ComparisonController {


    private final ComparisonService comparisonService;


    // API so sánh 2 Tour
    // Usage: GET /api/v1/compare/tours?id1=1&id2=5
    @GetMapping("/tours")
    public ResponseEntity<ComparisonResponse<TourComparisonDTO>> compareTours(
            @RequestParam Long id1,
            @RequestParam Long id2) {
        return ResponseEntity.ok(comparisonService.compareTours(id1, id2));
    }


    // API so sánh 2 Khách sạn
    // Usage: GET /api/v1/compare/hotels?id1=10&id2=12
    @GetMapping("/hotels")
    public ResponseEntity<ComparisonResponse<HotelComparisonDTO>> compareHotels(
            @RequestParam Long id1,
            @RequestParam Long id2) {
        return ResponseEntity.ok(comparisonService.compareHotels(id1, id2));
    }
}

