package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DestinationRepository extends JpaRepository<Destination, Long> {
    // Bạn có thể thêm custom query sau này nếu cần, ví dụ:
    // List<Destination> findByProvinceId(Long provinceId);
}
