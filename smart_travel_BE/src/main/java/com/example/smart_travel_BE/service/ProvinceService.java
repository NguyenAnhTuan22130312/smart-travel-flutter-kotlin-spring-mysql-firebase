package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.province.response.ProvinceIsPopularResponse;
import com.example.smart_travel_BE.entity.Province;
import com.example.smart_travel_BE.mapper.ProvinceMapper;
import com.example.smart_travel_BE.repository.ProvinceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProvinceService {
    private final ProvinceRepository provinceRepository;
    private final ProvinceMapper provinceMapper;

    /**
     * Lấy danh sách tỉnh thành phổ biến
     */
    public List<ProvinceIsPopularResponse> getAllProvinceIsPopular() {
        List<Province> provinces = provinceRepository.findByIsPopularTrue();

        return provinces.stream().map(provinceMapper::toProvinceIsPopularResponse)
                .collect(Collectors.toList());
    }
}
