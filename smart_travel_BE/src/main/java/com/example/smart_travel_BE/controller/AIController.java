package com.example.smart_travel_BE.controller;


import com.example.smart_travel_BE.service.AIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AIController {

    private final AIService aiService;

    @PostMapping("/search-image")
    public ResponseEntity<?> searchByImage(@RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(aiService.suggestFromImage(file));
    }
}