package com.example.smart_travel_BE.repository;
import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.*;
import com.example.smart_travel_BE.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TourRepository extends JpaRepository<Tour, Long>, JpaSpecificationExecutor<Tour> {
    List<Tour> findByDestinationId(Long destinationId);

    Page<Tour> findByIsActive(boolean isActive, Pageable pageable);

    // Tìm tour theo tên (ví dụ: "Tour 3 ngày")
    List<Tour> findByNameContainingIgnoreCase(String name);

    // Tìm tour theo
    List<Tour> findByDestination(Destination destination);

    // Tìm theo Tên HOẶC Tên Địa điểm (kết hợp)
    List<Tour> findByNameContainingIgnoreCaseOrDestination_NameContainingIgnoreCase(String tourName, String destName);

    @Override
    @EntityGraph(attributePaths = {"images", "destination"})
    Page<Tour> findAll(Specification<Tour> spec, Pageable pageable);

    @EntityGraph(attributePaths = {"images", "destination", "schedules"})
    Optional<Tour> findWithDetailById(Long id);
}

