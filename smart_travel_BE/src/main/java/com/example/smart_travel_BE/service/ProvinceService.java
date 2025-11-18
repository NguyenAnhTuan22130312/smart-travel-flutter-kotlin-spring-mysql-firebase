package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.province.request.ProvinceAddRequest;
import com.example.smart_travel_BE.dto.province.request.ProvinceUpdateRequest;
import com.example.smart_travel_BE.dto.province.response.ProvinceDetailResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.entity.Province;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.ProvinceMapper;
import com.example.smart_travel_BE.repository.ProvinceRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProvinceService {
    private final ProvinceRepository provinceRepository;
    private final ProvinceMapper provinceMapper;
    private final CloudinaryService cloudinaryService;

    /**
     * Lấy danh sách tỉnh thành
     */
    public List<ProvinceResponse> getAllProvince() {
        List<Province> provinces = provinceRepository.findAll();

        return provinces.stream().map(provinceMapper::toProvinceResponse)
                .collect(Collectors.toList());
    }

    /**
     * Lấy thông tin chi tiết tỉnh thành
     */
    public ProvinceDetailResponse getProvinceDetail(long provinceId) {
        Province provinces = provinceRepository.findById(provinceId).orElseThrow(
                () -> new AppException(ErrorCode.PROVINCE_NOT_EXISTED)
        );
        return provinceMapper.toProvinceDetailResponse(provinces);
    }


    ///ADMIN
    //Sửa
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public ProvinceResponse editProvince(ProvinceUpdateRequest request, MultipartFile image, long provinceId) {
        Province province = provinceRepository.findById(provinceId)
                .orElseThrow(() -> new AppException(ErrorCode.PROVINCE_NOT_EXISTED));

        // Cập nhật text fields (chỉ nếu không null và không rỗng)
        if (request.getName() != null && !request.getName().isBlank()) {
            province.setName(request.getName().trim());
        }
        if (request.getCode() != null && !request.getCode().isBlank()) {
            province.setCode(request.getCode().trim());
        }
        if (request.getRegion() != null) {
            province.setRegion(request.getRegion().trim());
        }
        if (request.getDescription() != null) {
            province.setDescription(request.getDescription().trim());
        }
        if (request.getIsPopular() != null) {
            province.setIsPopular(request.getIsPopular());
        }

        // === Xử lý ảnh ===
        if (image != null && !image.isEmpty()) {
            try {
                // Xóa ảnh cũ
                if (province.getImageUrl() != null) {
                    cloudinaryService.deleteFile(province.getImageUrl());
                }
                // Upload mới
                String url = cloudinaryService.uploadFile(image, "provinces");
                province.setImageUrl(url);
            } catch (IOException e) {
                throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
            }
        }
        // Nếu không có file → giữ nguyên imageUrl cũ
        Province saved = provinceRepository.save(province);
        return provinceMapper.toProvinceResponse(saved);
    }

    //Thêm
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public ProvinceResponse addProvince(ProvinceAddRequest request, MultipartFile image) {
        // Kiểm tra trùng code
        if (provinceRepository.existsByCode(request.getCode())) {
            throw new AppException(ErrorCode.PROVINCE_CODE_EXISTED);
        }

        Province province = provinceMapper.toProvince(request);

        // === Xử lý ảnh ===
        if (image != null && !image.isEmpty()) {
            try {
                String imageUrl = cloudinaryService.uploadFile(image, "provinces");
                province.setImageUrl(imageUrl);
            } catch (IOException e) {
                throw new AppException(ErrorCode.IMAGE_UPLOAD_FAILED);
            }
        }
        Province saved = provinceRepository.save(province);
        return provinceMapper.toProvinceResponse(saved);
    }

    //Xóa
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deleteProvince(long provinceId) {
        Province province = provinceRepository.findById(provinceId)
                .orElseThrow(() -> new AppException(ErrorCode.PROVINCE_NOT_EXISTED));

        // XÓA ẢNH TRÊN CLOUDINARY
        if (province.getImageUrl() != null && !province.getImageUrl().isBlank()) {
            try {
                cloudinaryService.deleteFile(province.getImageUrl());
            } catch (Exception e) {
                log.warn("Failed to delete image from Cloudinary: {}", province.getImageUrl(), e);
            }
        }
       provinceRepository.delete(province);
    }



}
