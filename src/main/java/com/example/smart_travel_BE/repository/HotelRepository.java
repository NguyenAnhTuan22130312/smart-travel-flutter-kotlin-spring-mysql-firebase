package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long>, JpaSpecificationExecutor<Hotel> {
    // JpaSpecificationExecutor cho phép bạn dùng HotelSpecification để lọc động (theo giá, sao, địa điểm...)
    // Tìm khách sạn theo tên
    List<Hotel> findByNameContainingIgnoreCase(String name);

    // Tìm khách sạn theo
    List<Hotel> findByDestination(Destination destination);

    // Tìm theo Tên HOẶC Tên Địa điểm (kết hợp)
    List<Hotel> findByNameContainingIgnoreCaseOrDestination_NameContainingIgnoreCase(String hotelName, String destName);
}