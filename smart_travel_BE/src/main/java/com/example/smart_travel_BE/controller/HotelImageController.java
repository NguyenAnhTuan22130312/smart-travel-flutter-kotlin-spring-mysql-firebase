package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.entity.HotelImage;
import com.example.smart_travel_BE.service.HotelImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/v1/hotels/{hotelId}/images")
@RequiredArgsConstructor
public class HotelImageController {

    private final HotelImageService hotelImageService;

    @PostMapping("/upload")
    @PreAuthorize("hasRole('ADMINHOTEL')")
    public ResponseEntity<List<HotelImage>> uploadMultiple(
            @PathVariable Long hotelId,
            @RequestParam("file") List<MultipartFile> files
    ) throws IOException {
        return ResponseEntity.ok(hotelImageService.uploadMultiple(hotelId, files));
    }

    @GetMapping
    public ResponseEntity<List<HotelImage>> getImages(@PathVariable Long hotelId) {
        return ResponseEntity.ok(hotelImageService.getImagesByHotel(hotelId));
    }

    @DeleteMapping("/{imageId}")
    @PreAuthorize("hasRole('ADMINHOTEL')")
    public ResponseEntity<Void> deleteImage(@PathVariable Long imageId) {
        hotelImageService.deleteImage(imageId);
        return ResponseEntity.noContent().build();
    }
}