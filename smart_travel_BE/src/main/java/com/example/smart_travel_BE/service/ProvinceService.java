package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.province.response.ProvinceDetailResponse;
import com.example.smart_travel_BE.dto.province.response.ProvinceResponse;
import com.example.smart_travel_BE.entity.Province;
import com.example.smart_travel_BE.exception.AppException;
import com.example.smart_travel_BE.exception.ErrorCode;
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
}
