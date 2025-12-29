package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.banner.request.BannerCreateRequest;
import com.example.smart_travel_BE.dto.banner.request.BannerUpdateRequest;
import com.example.smart_travel_BE.dto.banner.response.BannerResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.service.BannerService;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/banners")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class BannerController {
    BannerService bannerService;

    @PostMapping("/banner")
    public ResponseEntity<APIResponse<BannerResponse>> create(@RequestBody @Valid BannerCreateRequest request) {
        return ResponseEntity.ok().body(
                 APIResponse.<BannerResponse>builder()
                         .data(bannerService.createBanner(request))
                         .build()
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<APIResponse<BannerResponse>> update(@PathVariable Long id, @RequestBody @Valid BannerUpdateRequest request) {
        return ResponseEntity.ok().body(
                APIResponse.<BannerResponse>builder()
                        .data(bannerService.updateBanner(id, request))
                        .build()
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<APIResponse<Void>> delete(@PathVariable Long id) {
        try{
            bannerService.deleteBanner(id);
            return ResponseEntity.ok().body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thành công")
                            .build()
            );
        }catch (Exception e){
            return ResponseEntity.badRequest().body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thất bại")
                            .build()
            );
        }

    }

    @GetMapping
    public ResponseEntity<APIResponse<List<BannerResponse>>> getAll() {
        return ResponseEntity.ok().body(
                APIResponse.<List<BannerResponse>>builder()
                        .data(bannerService.getAllBanners())
                        .build()
        );
    }
}