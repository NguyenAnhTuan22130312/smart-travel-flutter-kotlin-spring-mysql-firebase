package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.DestinationImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DestinationImageRepository extends JpaRepository<DestinationImage, Long> {
    List<DestinationImage> findByDestinationIdOrderByDisplayOrderAsc(Long destinationId);
    void deleteByDestinationId(Long destinationId);
    Optional<DestinationImage> findByDestinationIdAndIsPrimaryTrue(Long destinationId);
    Optional<DestinationImage> findByImageUrl(String imageUrl);
}