package com.example.smart_travel_BE.controller;

import com.example.smart_travel_BE.dto.destination.request.DestinationCreateRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationImageUploadRequest;
import com.example.smart_travel_BE.dto.destination.request.DestinationUpdateRequest;
import com.example.smart_travel_BE.dto.destination.response.DestinationDetailResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationFeaturedResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationImageResponse;
import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.dto.user.response.APIResponse;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.service.DestinationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/v1/destination")
@RequiredArgsConstructor
@Slf4j
public class DestinationsController {
    private final DestinationService destinationService;

    /**
     * Lấy danh sách địa điểm
     */
    @GetMapping("/destination-all")
    public ResponseEntity<APIResponse<List<DestinationDetailResponse>>>getAllDestinations(){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<List<DestinationDetailResponse>>builder()
                        .data(destinationService.getAllDestinations())
                        .build()
        );
    }

    /**
     * Lấy danh sách địa điểm nổi bật
     */
    @GetMapping("/destination-featured")
    public ResponseEntity<APIResponse<List<DestinationDetailResponse>>>getAllDestinationsFeatured(){
        return ResponseEntity.status(HttpStatus.OK).body(
                 APIResponse.<List<DestinationDetailResponse>>builder()
                         .data(destinationService.getAllDestinationsFeatured())
                         .build()
        );
    }


    /**
     * Lấy danh sách địa điểm
     */
    @GetMapping("/destination-filter")
    public ResponseEntity<APIResponse<List<DestinationDetailResponse>>>filterDestinationsByCategory(@RequestParam String category){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<List<DestinationDetailResponse>>builder()
                        .data(destinationService.filterDestinationsByCategory(category))
                        .build()
        );
    }

    /**
     * xem chi tiết địa điểm
     */
    @GetMapping("/detail/{id}")
    public ResponseEntity<APIResponse<DestinationDetailResponse>>getDestinationDetail(@PathVariable("id") long id){
        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<DestinationDetailResponse>builder()
                        .data(destinationService.getDestinationDetail(id))
                        .build()
        );
    }


    /**
     * thêm địa điểm
     */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<APIResponse<DestinationDetailResponse>> create(
            @Valid @RequestPart("request") DestinationCreateRequest request,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {

        return ResponseEntity.status(HttpStatus.CREATED).body(
                APIResponse.<DestinationDetailResponse>builder()
                        .data(destinationService.createDestination(request, imageFiles))
                        .build()
        );
    }

    /**
     * cập nhật địa dđiểm
     */
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<APIResponse<DestinationDetailResponse>> update(
            @PathVariable Long id,
            @Valid @RequestPart("request") DestinationUpdateRequest request,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {

        return ResponseEntity.status(HttpStatus.OK).body(
                APIResponse.<DestinationDetailResponse>builder()
                        .data(destinationService.updateDestination(id, request, imageFiles))
                        .build()
        );
    }

    //Xóa địa điểm
    @DeleteMapping("/{id}")
    public ResponseEntity<APIResponse<Void>> delete(@PathVariable Long id) {

        try{
            destinationService.deleteDestination(id);
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thành công")
                            .build()
            );

        }catch (AppException e){
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Xóa thất bại")
                            .build()
            );
        }

    }
    //Khôi phục địa điểm
    @PutMapping("/restore/{id}")
    public ResponseEntity<APIResponse<Void>> restoreDestination(@PathVariable Long id) {

        try{
            destinationService.restoreDestination(id);
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Khôi phục thành công")
                            .build()
            );

        }catch (AppException e){
            return ResponseEntity.status(HttpStatus.OK).body(
                    APIResponse.<Void>builder()
                            .msg("Khôi phục thất bại")
                            .build()
            );
        }

    }

    //Thêm ảnh cho địa điểm
    @PostMapping(value = "/{id}/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<APIResponse<DestinationImageResponse>> uploadImage(
            @PathVariable Long id,
            @Valid @RequestPart("request") DestinationImageUploadRequest request, @RequestPart(value = "imageFiles", required = false)  MultipartFile file) {

        return ResponseEntity.ok(
                APIResponse.<DestinationImageResponse>builder()
                        .data(destinationService.uploadImageToDestination(id, request, file))
                        .build()
        );
    }

    //Xóa ảnh
    @DeleteMapping( "/{destinationId}/{imageId}/images")
    public ResponseEntity<APIResponse<Void>> deleteDestinationImage(
            @PathVariable Long destinationId,
            @PathVariable Long imageId) {

        try{
            destinationService.deleteDestinationImage(destinationId, imageId);
            return ResponseEntity.ok(
                    APIResponse.<Void>builder()
                            .msg("Xóa hình thành công")
                        .build()
        );
        }catch (AppException e){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    APIResponse.<Void>builder()
                            .msg("thất bại")
                            .build()
            );
        }

    }

}
