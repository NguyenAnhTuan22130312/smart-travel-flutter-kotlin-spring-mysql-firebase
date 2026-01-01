package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.tour.request.CreateTourRequest;
import com.example.smart_travel_BE.dto.tour.request.TourImageRequest;
import com.example.smart_travel_BE.dto.tour.request.TourScheduleRequest;
import com.example.smart_travel_BE.dto.tour.request.UpdateTourRequest;
import com.example.smart_travel_BE.dto.tour.response.TourDetailResponse;
import com.example.smart_travel_BE.dto.tour.response.TourImageResponse;
import com.example.smart_travel_BE.dto.tour.response.TourScheduleResponse;
import com.example.smart_travel_BE.dto.tour.response.TourSummaryResponse;
import com.example.smart_travel_BE.entity.TourImage;
import com.example.smart_travel_BE.service.TourImageService;
import com.example.smart_travel_BE.service.TourService;
import org.springframework.data.domain.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/admin/tours")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasRole('ADMIN')")
public class AdminTourController {

    private final TourService adminTourService;
    private final TourImageService tourImageService;

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
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourDetailResponse create(@RequestBody CreateTourRequest request) {
        return adminTourService.createTour(request);
    }

    @GetMapping("/{id}")
    public TourDetailResponse getDetail(@PathVariable Long id) {
        return adminTourService.getDetail(id);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourDetailResponse update(
            @PathVariable Long id,
            @RequestBody UpdateTourRequest request
    ) {
        return adminTourService.updateTour(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public void delete(@PathVariable Long id) {
        adminTourService.deleteTour(id);
    }

    // Update STATUS
    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public void updateStatus(
            @PathVariable Long id,
            @RequestBody UpdateTourRequest request
    ) {
        adminTourService.updateStatus(id, request.getIsActive());
    }

    // Add 1 ảnh
    @PostMapping("/{tourId}/images")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourImageResponse addImage(
            @PathVariable Long tourId,
            @RequestParam MultipartFile file,
            @RequestParam(defaultValue = "false") boolean isPrimary,
            @RequestParam(defaultValue = "0") int displayOrder
    ) throws IOException {
        return tourImageService.addImage(tourId, file, isPrimary, displayOrder);
    }

    // Update 1 ảnh
    @PutMapping("/images/{imageId}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourImageResponse updateImage(
            @PathVariable Long imageId,
            @RequestParam(required = false) MultipartFile file,
            @RequestParam(required = false) Boolean isPrimary,
            @RequestParam(required = false) Integer displayOrder
    ) throws IOException {
        return tourImageService.updateImage(imageId, file, isPrimary, displayOrder);
    }

    // Get list ảnh
    @GetMapping("/{tourId}/images")
    public List<TourImageResponse> getImages(@PathVariable Long tourId) {
        return tourImageService.getImagesByTour(tourId);
    }

    // Bulk upload
    @PostMapping("/{tourId}/images/bulk")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public List<TourImageResponse> addImages(
            @PathVariable Long tourId,
            @RequestParam List<MultipartFile> files
    ) throws IOException {
        return tourImageService.addImages(tourId, files);
    }

    // DELETE IMAGE
    @DeleteMapping("/images/{imageId}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public void deleteImage(@PathVariable Long imageId) {
        adminTourService.deleteImage(imageId);
    }

    // REORDER IMAGES
    @PutMapping("/images/reorder")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public void reorderImages(
            @RequestBody List<TourImageRequest> requests
    ) {
        adminTourService.reorderImages(requests);
    }

    // SET PRIMARY IMAGE
    @PutMapping("/images/{imageId}/primary")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public ResponseEntity<Void> setPrimary(@PathVariable Long imageId) {
        adminTourService.setPrimaryImage(imageId);
        return ResponseEntity.ok().build();
    }

    // SCHEDULE
    @PostMapping("/{id}/schedules")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourScheduleResponse addSchedule(
            @PathVariable Long id,
            @RequestBody TourScheduleRequest request) {
        return adminTourService.addSchedule(id, request);
    }

    @PutMapping("/schedules/{scheduleId}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public TourScheduleResponse updateSchedule(
            @PathVariable Long scheduleId,
            @RequestBody TourScheduleRequest request) {
        return adminTourService.updateSchedule(scheduleId, request);
    }

    @DeleteMapping("/schedules/{scheduleId}")
    @PreAuthorize("hasRole('ADMINTOUR')")
    public void deleteSchedule(@PathVariable Long scheduleId) {
        adminTourService.deleteSchedule(scheduleId);
    }
}
