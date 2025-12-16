package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.tour.request.TourFilterRequest;
import com.example.smart_travel_BE.dto.tour.response.*;
import com.example.smart_travel_BE.service.TourService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tours")
public class TourController {

    @Autowired
    private TourService tourService;

    // 1. GET /api/v1/tours?page=0&size=10
    @GetMapping
    public ResponseEntity<Page<TourResponse>> getAllTours(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) String sortDir
    ) {
        return ResponseEntity.ok(tourService.getAllTours(page, size, sortBy, sortDir));
    }

    // 2. POST /api/v1/tours/filter  (body: TourFilterRequest)
    @PostMapping("/filter")
    public ResponseEntity<Page<TourResponse>> filterTours(@RequestBody TourFilterRequest req) {
        return ResponseEntity.ok(tourService.filterTours(req));
    }

    // 3. GET /api/v1/tours/{id}
    @GetMapping("/{id}")
    public ResponseEntity<TourDetailResponse> getTourDetail(@PathVariable Long id) {
        return ResponseEntity.ok(tourService.getTourDetail(id));
    }

    // 4. GET /api/v1/tours/{id}/images
    @GetMapping("/{id}/images")
    public ResponseEntity<List<TourImageResponse>> getImages(@PathVariable Long id) {
        return ResponseEntity.ok(tourService.getImages(id));
    }

    // 5. GET /api/v1/tours/{id}/day/{day}
    @GetMapping("/{id}/day/{day}")
    public ResponseEntity<TourScheduleResponse> getScheduleByDay(@PathVariable Long id, @PathVariable Integer day) {
        return ResponseEntity.ok(tourService.getScheduleByDay(id, day));
    }

    // 6. GET /api/v1/tours/destination/{destinationId}
    @GetMapping("/destination/{destinationId}")
    public ResponseEntity<List<TourResponse>> getByDestination(@PathVariable Long destinationId) {
        return ResponseEntity.ok(tourService.getToursByDestination(destinationId));
    }

    // Admin example: POST /api/v1/tours/{id}/images (protected)
    @PostMapping("/{id}/images")
    public ResponseEntity<TourImageResponse> addImage(@PathVariable Long id, @RequestParam String imageUrl, @RequestParam(required = false) Boolean isPrimary, @RequestParam(required = false) Integer displayOrder) {
        // Should be protected by @PreAuthorize or method security
        return ResponseEntity.ok(tourService.addImageToTour(id, imageUrl, isPrimary, displayOrder));
    }
}
