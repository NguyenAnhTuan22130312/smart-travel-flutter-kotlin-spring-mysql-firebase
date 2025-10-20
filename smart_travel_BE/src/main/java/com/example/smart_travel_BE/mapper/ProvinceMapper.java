package com.example.smart_travel_BE.mapper;

import com.example.smart_travel_BE.dto.province.response.ProvinceIsPopularResponse;
import com.example.smart_travel_BE.entity.Province;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProvinceMapper {

    @Mapping(target = "destinationCount", expression = "java(province.getDestinations() != null ? province.getDestinations().size() : 0)")
    ProvinceIsPopularResponse toProvinceIsPopularResponse(Province province);

}
