package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.UserVoucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserVoucherRepository extends JpaRepository<UserVoucher, Long> {
    List<UserVoucher> findByUserId(Long userId);
    boolean existsByUserIdAndVoucherId(Long userId, Long voucherId);
    @Query("SELECT uv FROM UserVoucher uv JOIN uv.voucher v " +
            "WHERE uv.user.id = :userId AND v.code = :code AND uv.isUsed = false")
    Optional<UserVoucher> findValidVoucher(@Param("userId") Long userId, @Param("code") String code);
}