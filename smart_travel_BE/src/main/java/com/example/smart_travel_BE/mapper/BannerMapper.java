package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.banner.request.BannerCreateRequest;
import com.example.smart_travel_BE.dto.banner.request.BannerUpdateRequest;
import com.example.smart_travel_BE.dto.banner.response.BannerResponse;
import com.example.smart_travel_BE.entity.Banner;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface BannerMapper {
    Banner toBanner(BannerCreateRequest request);

    BannerResponse toBannerResponse(Banner banner);

    void updateBanner(@MappingTarget Banner banner, BannerUpdateRequest request);
}