package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.province.response.ProvinceDetailResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.ProvinceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
    @GetMapping("/all")
    public ResponseEntity<APIResponse<List<ProvinceResponse>>> getAllProvince(){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<List<ProvinceResponse>>builder()
                        .data(provinceService.getAllProvince())
                        .build()
        );
    }
    @GetMapping("/detail/{provinceId}")
    public ResponseEntity<APIResponse<ProvinceDetailResponse>> getProvinceDetail(@PathVariable("provinceId") long provinceId){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<ProvinceDetailResponse>builder()
                        .data(provinceService.getProvinceDetail(provinceId))
                        .build()
        );
    }
}
