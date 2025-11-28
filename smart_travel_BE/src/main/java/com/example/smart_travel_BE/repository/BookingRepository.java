package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {
    Optional<Booking> findFirstByUser(User user);
    
    void deleteByUser(User user);
}