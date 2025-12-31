package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.TourImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TourImageRepository extends JpaRepository<TourImage, Long> {
    List<TourImage> findByTourIdOrderByDisplayOrder(Long tourId);
    void deleteByTourId(Long tourId);
    Optional<TourImage> findByIdAndTourId(Long id, Long tourId);
    @Modifying
    @Query("UPDATE TourImage i SET i.isPrimary = false WHERE i.tour.id = :tourId")
    void resetPrimary(@Param("tourId") Long tourId);
    boolean existsPrimaryByTourId(Long tourId);

    List<TourImage> findByTourIdOrderByDisplayOrderAsc(Long tourId);
}
