package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long>, JpaSpecificationExecutor<Hotel> {
    // JpaSpecificationExecutor cho phép bạn dùng HotelSpecification để lọc động (theo giá, sao, địa điểm...)
}
