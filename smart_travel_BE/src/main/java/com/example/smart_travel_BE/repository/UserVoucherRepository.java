package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.UserVoucher;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserVoucherRepository extends JpaRepository<UserVoucher, Long> {
    List<UserVoucher> findByUserId(Long userId);
    boolean existsByUserIdAndVoucherId(Long userId, Long voucherId);
}