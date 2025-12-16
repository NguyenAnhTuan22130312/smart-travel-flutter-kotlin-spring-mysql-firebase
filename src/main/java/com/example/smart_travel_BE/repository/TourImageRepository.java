package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.TourImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TourImageRepository extends JpaRepository<TourImage, Long> {
    List<TourImage> findByTourIdOrderByDisplayOrder(Long tourId);
}
