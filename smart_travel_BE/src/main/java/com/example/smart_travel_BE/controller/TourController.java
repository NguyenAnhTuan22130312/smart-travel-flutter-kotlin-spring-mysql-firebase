package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.tour.request.TourFilterRequest;
import com.example.smart_travel_BE.dto.tour.response.*;
import com.example.smart_travel_BE.service.TourService;
import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/tours")
public class TourController {

    @Autowired
    private TourService tourService;

    @GetMapping("/filter")
    public Page<TourResponse> filterTours(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String minPrice,
            @RequestParam(required = false) String maxPrice,
            @RequestParam(required = false) String minDays,
            @RequestParam(required = false) String maxDays,
            @RequestParam(required = false) String minPeople,
            @RequestParam(required = false) String minRating,
            @RequestParam(required = false) String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Boolean isActive // Thêm param
    ) {
        boolean activeFilter = Optional.ofNullable(isActive).orElse(true); // default = true
        return tourService.filterTours(
                keyword,
                parseDouble(minPrice),
                parseDouble(maxPrice),
                parseInt(minDays),
                parseInt(maxDays),
                parseInt(minPeople),
                parseDouble(minRating),
                sort,
                page,
                size,
                activeFilter // truyền vào service
        );
    }

    private Double parseDouble(String value) {
        try {
            return (value == null || value.isBlank()) ? null : Double.parseDouble(value);
        } catch (Exception e) {
            return null;
        }
    }

    private Integer parseInt(String value) {
        try {
            return (value == null || value.isBlank()) ? null : Integer.parseInt(value);
        } catch (Exception e) {
            return null;
        }
    }

    // 3. GET /api/v1/tours/{id}
    @GetMapping("/{id:\\d+}")
    public ResponseEntity<TourDetailResponse> getTourDetail(@PathVariable Long id) {
        return ResponseEntity.ok(tourService.getTourDetail(id));
    }

    // 4. GET /api/v1/tours/{id}/images
    @GetMapping("/{id:\\d+}/images")
    public ResponseEntity<List<TourImageResponse>> getImages(@PathVariable Long id) {
        return ResponseEntity.ok(tourService.getImages(id));
    }

    // 5. GET /api/v1/tours/{id}/day/{day}
    @GetMapping("/{id:\\d+}/day/{day:\\d+}")
    public ResponseEntity<TourScheduleResponse> getScheduleByDay(@PathVariable Long id, @PathVariable Integer day) {
        return ResponseEntity.ok(tourService.getScheduleByDay(id, day));
    }

    // 6. GET /api/v1/tours/destination/{destinationId}
    @GetMapping("/destination/{destinationId:\\d+}")
    public ResponseEntity<List<TourResponse>> getByDestination(@PathVariable Long destinationId) {
        return ResponseEntity.ok(tourService.getToursByDestination(destinationId));
    }

    // Admin example: POST /api/v1/tours/{id}/images (protected)
    @PostMapping("/{id:\\d+}/images")
    public ResponseEntity<TourImageResponse> addImage(@PathVariable Long id, @RequestParam String imageUrl, @RequestParam(required = false) Boolean isPrimary, @RequestParam(required = false) Integer displayOrder) {
        // Should be protected by @PreAuthorize or method security
        return ResponseEntity.ok(tourService.addImageToTour(id, imageUrl, isPrimary, displayOrder));
    }
}
