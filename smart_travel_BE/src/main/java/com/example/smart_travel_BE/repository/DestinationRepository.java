package com.example.smart_travel_BE.repository;


import com.example.smart_travel_BE.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DestinationRepository extends JpaRepository<Destination, Long> {

    List<Destination> findByIsActiveTrue();
    List<Destination> findByIsFeaturedTrueAndIsActiveTrue();
    List<Destination> findByNameContainingIgnoreCase(String name);
    boolean existsByNameAndProvinceId(String name, Long provinceId);
    boolean existsByNameAndProvinceIdAndIdNot (String name, Long provinceId, Long id);
    @Query(value = "SELECT * FROM destinations WHERE category = :type ORDER BY RAND() LIMIT 5", nativeQuery = true)
    List<Destination> findSuggestDestinations(@Param("type") String type);
    
    // Query top destinations by view count
    List<Destination> findTop5ByIsActiveTrueOrderByViewCountDesc();
}
