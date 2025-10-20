package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceIsPopularResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.ProvinceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/province")
@RequiredArgsConstructor
@Slf4j
public class ProvinceController {
    private final ProvinceService provinceService;


    /**
     * Lấy danh sách tỉnh thành phổ biến
     */
    @GetMapping("/popular")
    public ResponseEntity<APIResponse<List<ProvinceIsPopularResponse>>> getAllProvinceIsPopular(){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<List<ProvinceIsPopularResponse>>builder()
                        .data(provinceService.getAllProvinceIsPopular())
                        .build()
        );
    }
}
