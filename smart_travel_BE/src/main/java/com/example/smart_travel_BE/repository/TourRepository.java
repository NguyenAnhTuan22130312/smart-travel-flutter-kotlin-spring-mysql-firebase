package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Destination;
import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.*;

import java.math.BigDecimal; // <--- QUAN TRỌNG: Thêm import này
import java.util.List;
import java.util.Optional;

public interface TourRepository extends JpaRepository<Tour, Long>, JpaSpecificationExecutor<Tour> {
    List<Tour> findByDestinationId(Long destinationId);

    Page<Tour> findByIsActive(boolean isActive, Pageable pageable);

    List<Tour> findByNameContainingIgnoreCase(String name);

    List<Tour> findByDestination(Destination destination);

    List<Tour> findByNameContainingIgnoreCaseOrDestination_NameContainingIgnoreCase(String tourName, String destName);

    List<Tour> findTop5ByOrderByPricePerPersonAsc();

    List<Tour> findByPricePerPersonLessThanEqual(BigDecimal maxPrice);

    @Override
    @EntityGraph(attributePaths = {"images", "destination"})
    Page<Tour> findAll(Specification<Tour> spec, Pageable pageable);

    @EntityGraph(attributePaths = {"destination"})
    Optional<Tour> findWithDetailById(Long id);
}