package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.TourSchedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TourScheduleRepository extends JpaRepository<TourSchedule, Long> {
    List<TourSchedule> findByTourIdOrderByDayNumber(Long tourId);
    void deleteByTourId(Long tourId);
}
