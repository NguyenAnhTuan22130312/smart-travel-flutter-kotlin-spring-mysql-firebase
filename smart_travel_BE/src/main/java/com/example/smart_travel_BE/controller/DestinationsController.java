package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.DestinationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/destination")
@RequiredArgsConstructor
@Slf4j
public class DestinationsController {
    private final DestinationService destinationService;


    /**
     * Lấy danh sách địa điểm nổi bật
     */
    @GetMapping("/destination-featured")
    public ResponseEntity<APIResponse<List<DestinationResponse>>>getAllDestinationsFeatured(){
        return ResponseEntity.status(HttpStatus.OK).body(
                 APIResponse.<List<DestinationResponse>>builder()
                         .data(destinationService.getAllDestinationsFeatured())
                         .build()
        );
    }
}
