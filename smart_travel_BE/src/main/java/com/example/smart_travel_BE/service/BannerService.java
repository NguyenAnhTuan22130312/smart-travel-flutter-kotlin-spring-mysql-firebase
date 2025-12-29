package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.banner.request.BannerCreateRequest;
import com.example.smart_travel_BE.dto.banner.request.BannerUpdateRequest;
import com.example.smart_travel_BE.dto.banner.response.BannerResponse;
import com.example.smart_travel_BE.entity.Banner;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
import com.example.smart_travel_BE.mapper.BannerMapper;
import com.example.smart_travel_BE.repository.BannerRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class BannerService {
    BannerRepository bannerRepository;
    BannerMapper bannerMapper;

    @PreAuthorize("hasRole('ADMIN')")
    public BannerResponse createBanner(BannerCreateRequest request) {
        Banner banner = bannerMapper.toBanner(request);
        banner.setActive(true); // Mặc định kích hoạt khi tạo mới
        return bannerMapper.toBannerResponse(bannerRepository.save(banner));
    }

    @PreAuthorize("hasRole('ADMIN')")
    public BannerResponse updateBanner(Long id, BannerUpdateRequest request) {
        Banner banner = bannerRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.BANNER_NOT_EXISTED));

        bannerMapper.updateBanner(banner, request);
        return bannerMapper.toBannerResponse(bannerRepository.save(banner));
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteBanner(Long id) {
        if (!bannerRepository.existsById(id))
            throw new AppException(ErrorCode.BANNER_NOT_EXISTED);
        bannerRepository.deleteById(id);
    }

    public List<BannerResponse> getAllBanners() {
        return bannerRepository.findAll().stream()
                .map(bannerMapper::toBannerResponse)
                .toList();
    }
}