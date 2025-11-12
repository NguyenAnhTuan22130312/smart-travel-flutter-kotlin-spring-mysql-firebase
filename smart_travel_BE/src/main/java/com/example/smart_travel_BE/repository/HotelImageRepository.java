package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.HotelImage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HotelImageRepository extends JpaRepository<HotelImage, Long> {
    List<HotelImage> findByHotelIdOrderByDisplayOrderAsc(Long hotelId);
}