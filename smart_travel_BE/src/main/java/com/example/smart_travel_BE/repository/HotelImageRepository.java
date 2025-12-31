package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.HotelImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface HotelImageRepository extends JpaRepository<HotelImage, Long> {
    List<HotelImage> findByHotelIdOrderByDisplayOrderAsc(Long hotelId);
    @Modifying
    @Query("UPDATE HotelImage hi SET hi.isPrimary = false WHERE hi.hotel.id = :hotelId")
    void resetPrimaryStatus(@Param("hotelId") Long hotelId);
}