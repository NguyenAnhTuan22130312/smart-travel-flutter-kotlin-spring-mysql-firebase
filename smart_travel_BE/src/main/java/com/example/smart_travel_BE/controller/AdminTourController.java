package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.tour.request.CreateTourRequest;
import com.example.smart_travel_BE.dto.tour.request.TourImageRequest;
import com.example.smart_travel_BE.dto.tour.request.TourScheduleRequest;
import com.example.smart_travel_BE.dto.tour.request.UpdateTourRequest;
import com.example.smart_travel_BE.dto.tour.response.TourDetailResponse;
import com.example.smart_travel_BE.dto.tour.response.TourImageResponse;
import com.example.smart_travel_BE.dto.tour.response.TourScheduleResponse;
import com.example.smart_travel_BE.dto.tour.response.TourSummaryResponse;
import com.example.smart_travel_BE.service.TourService;
import org.springframework.data.domain.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/tours")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasRole('ADMIN')")
public class AdminTourController {

    private final TourService adminTourService;

    @GetMapping
    public Page<TourSummaryResponse> getTours(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long destinationId,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir
    ) {
        return adminTourService.getTours(
                keyword, destinationId, isActive,
                page, size, sortBy, sortDir
        );
    }

    @PostMapping
    public TourDetailResponse create(@RequestBody CreateTourRequest request) {
        return adminTourService.createTour(request);
    }

    @GetMapping("/{id}")
    public TourDetailResponse getDetail(@PathVariable Long id) {
        return adminTourService.getDetail(id);
    }

    @PutMapping("/{id}")
    public TourDetailResponse update(
            @PathVariable Long id,
            @RequestBody UpdateTourRequest request
    ) {
        return adminTourService.updateTour(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        adminTourService.deleteTour(id);
    }

    // Update STATUS
    @PatchMapping("/{id}/status")
    public void updateStatus(
            @PathVariable Long id,
            @RequestBody UpdateTourRequest request
    ) {
        adminTourService.updateStatus(id, request.getIsActive());
    }

    // UPLOAD 1 IMAGE
    @PostMapping("/{id}/images")
    public TourImageResponse addImage(
            @PathVariable Long id,
            @RequestBody TourImageRequest request) {
        return adminTourService.addImage(id, request);
    }

    // UPLOAD IMAGES
    @PostMapping("/{id}/images/bulk")
    public List<TourImageResponse> addImages(
            @PathVariable Long id,
            @RequestBody List<TourImageRequest> requests
    ) {
        return adminTourService.addImages(id, requests);
    }

    @PutMapping("/images/{imageId}")
    public TourImageResponse updateImage(
            @PathVariable Long imageId,
            @RequestBody TourImageRequest request) {
        return adminTourService.updateImage(imageId, request);
    }

    // DELETE IMAGE
    @DeleteMapping("/images/{imageId}")
    public void deleteImage(@PathVariable Long imageId) {
        adminTourService.deleteImage(imageId);
    }
    // REORDER IMAGES
    @PutMapping("/images/reorder")
    public void reorderImages(
            @RequestBody List<TourImageRequest> requests
    ) {
        adminTourService.reorderImages(requests);
    }

    // SET PRIMARY IMAGE
    @PutMapping("/images/{imageId}/primary")
    public ResponseEntity<Void> setPrimary(@PathVariable Long imageId) {
        adminTourService.setPrimaryImage(imageId);
        return ResponseEntity.ok().build();
    }

    // SCHEDULE
    @PostMapping("/{id}/schedules")
    public TourScheduleResponse addSchedule(
            @PathVariable Long id,
            @RequestBody TourScheduleRequest request) {
        return adminTourService.addSchedule(id, request);
    }

    @PutMapping("/schedules/{scheduleId}")
    public TourScheduleResponse updateSchedule(
            @PathVariable Long scheduleId,
            @RequestBody TourScheduleRequest request) {
        return adminTourService.updateSchedule(scheduleId, request);
    }

    @DeleteMapping("/schedules/{scheduleId}")
    public void deleteSchedule(@PathVariable Long scheduleId) {
        adminTourService.deleteSchedule(scheduleId);
    }
}
