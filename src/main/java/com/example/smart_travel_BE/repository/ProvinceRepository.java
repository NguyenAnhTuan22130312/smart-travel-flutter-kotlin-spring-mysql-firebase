package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Province;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProvinceRepository  extends JpaRepository<Province, Long> {
    List<Province> findByIsPopularTrue();
    boolean existsByCode(String code);
}
