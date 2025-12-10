package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.province.request.ProvinceAddRequest;
import com.example.smart_travel_BE.dto.province.request.ProvinceUpdateRequest;
import com.example.smart_travel_BE.dto.province.response.ProvinceDetailResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.ProvinceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/province")
@RequiredArgsConstructor
@Slf4j
public class ProvinceController {
    private final ProvinceService provinceService;


    /**
     * Lấy danh sách tỉnh thành
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

    ///ADMIN
    // Sửa
    @PutMapping(value = "/{provinceId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<APIResponse<ProvinceResponse>> editProvince(
            @PathVariable long provinceId,
            @RequestPart("data") @Valid ProvinceUpdateRequest request,
                @RequestPart(value = "image", required = false) MultipartFile image) {

        ProvinceResponse response = provinceService.editProvince(request, image, provinceId);
        return ResponseEntity.ok(APIResponse.<ProvinceResponse>builder()
                .data(response)
                .build());
    }
    // Thêm
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<APIResponse<ProvinceResponse>> addProvince(
            @Valid @RequestPart("data") ProvinceAddRequest request,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        log.info("ADĐ");
        try{
            ProvinceResponse response = provinceService.addProvince(request, image);
            return ResponseEntity.status(HttpStatus.CREATED).body(
                    APIResponse.<ProvinceResponse>builder()
                            .data(response)
                            .build()
            );
        }catch (AppException e){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    APIResponse.<ProvinceResponse>builder()
                            .msg(e.getMessage())
                            .build()
            );
        }
    }

    // Xóa
    @DeleteMapping("/{provinceId}")
    public ResponseEntity<APIResponse<Void>> deleteProvince(@PathVariable("provinceId") long provinceId){
        log.info("DLETE", provinceId);
        try {
            provinceService.deleteProvince(provinceId);
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thành công")
                            .build()
            );
        }catch (AppException e){
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thất bại")
                            .build()
            );
        }
    }
}
