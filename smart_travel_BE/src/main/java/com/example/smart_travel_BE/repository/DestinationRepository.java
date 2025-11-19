package com.example.smart_travel_BE.repository;


import com.example.smart_travel_BE.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DestinationRepository extends JpaRepository<Destination, Long> {

    List<Destination> findByIsFeaturedTrue();
    List<Destination> findByNameContainingIgnoreCase(String name);
}