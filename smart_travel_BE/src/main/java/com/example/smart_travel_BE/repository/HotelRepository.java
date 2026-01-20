package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Hotel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal; // <--- QUAN TRỌNG: Thêm import này
import java.util.List;

@Repository
public interface HotelRepository extends JpaRepository<Hotel, Long>, JpaSpecificationExecutor<Hotel> {

    @Query("SELECT h FROM Hotel h WHERE LOWER(h.name) LIKE LOWER(CONCAT('%', :name, '%')) AND h.isActive = true")
    List<Hotel> findByNameContainingIgnoreCase(@Param("name") String name);

    @Query("SELECT h FROM Hotel h WHERE h.destination = :destination AND h.isActive = true")
    List<Hotel> findByDestination(@Param("destination") Destination destination);

    @Query("SELECT h FROM Hotel h " +
            "WHERE (LOWER(h.name) LIKE LOWER(CONCAT('%', :hotelName, '%')) " +
            "OR LOWER(h.destination.name) LIKE LOWER(CONCAT('%', :destName, '%'))) " +
            "AND h.isActive = true")
    List<Hotel> findByNameContainingIgnoreCaseOrDestination_NameContainingIgnoreCase(@Param("hotelName") String hotelName, @Param("destName") String destName);

    @Query("SELECT h FROM Hotel h " +
            "WHERE (LOWER(h.name) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(h.destination.name) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
            "AND h.isActive = true")
    List<Hotel> searchByKeyword(@Param("keyword") String keyword);

    List<Hotel> findTop5ByOrderByPricePerNightAsc();

    // --- SỬA DÒNG DƯỚI ĐÂY ---
    // Cũ: List<Hotel> findByPricePerNightBetween(Double min, Double max);
    // Mới:
    List<Hotel> findByPricePerNightBetween(BigDecimal min, BigDecimal max);

    List<Hotel> findByDestinationOrderByPricePerNightAsc(Destination destination);
}