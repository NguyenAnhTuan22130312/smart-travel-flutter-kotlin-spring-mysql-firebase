package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.destination.response.DestinationResponse;
import com.example.smart_travel_BE.dto.province.request.ProvinceAddRequest;
import com.example.smart_travel_BE.dto.province.response.ProvinceDetailResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.DestinationImage;
import com.example.smart_travel_BE.entity.Province;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ProvinceMapper {

    @Mapping(target = "destinationCount", expression = "java(province.getDestinations() != null ? province.getDestinations().size() : 0)")
    ProvinceResponse toProvinceResponse(Province province);

    @Mapping(target = "destinations", source = "destinations")
    ProvinceDetailResponse toProvinceDetailResponse(Province province);

    Province toProvince(ProvinceAddRequest request);

    // Map từng Destination sang DTO
    @Mapping(target = "imageUrl",
            expression = "java(getImageUrl(destination.getImages()))")
    DestinationResponse toDestinationResponse(Destination destination);

    // Hàm lấy ảnh đầu tiên
    default String getImageUrl(List<DestinationImage> images) {
        if (images == null || images.isEmpty()) return null;
        return images.get(0).getImageUrl();
    }
}
