package com.example.smart_travel_BE.repository;
import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import com.example.smart_travel_BE.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TourRepository extends JpaRepository<Tour, Long>, JpaSpecificationExecutor<Tour> {
    List<Tour> findByDestinationId(Long destinationId);

    // Tìm tour theo tên (ví dụ: "Tour 3 ngày")
    List<Tour> findByNameContainingIgnoreCase(String name);

    // Tìm tour theo
    List<Tour> findByDestination(Destination destination);

    // Tìm theo Tên HOẶC Tên Địa điểm (kết hợp)
    List<Tour> findByNameContainingIgnoreCaseOrDestination_NameContainingIgnoreCase(String tourName, String destName);


}

