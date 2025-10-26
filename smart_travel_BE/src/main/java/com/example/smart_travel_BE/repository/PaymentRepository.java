package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    // Spring Data JPA sẽ tự động cung cấp các hàm
    // như findById(), save(), findAll()...

    // Bạn có thể thêm các hàm tùy chỉnh ở đây nếu cần, ví dụ:
    // Optional<Payment> findByBookingId(Long bookingId);
}