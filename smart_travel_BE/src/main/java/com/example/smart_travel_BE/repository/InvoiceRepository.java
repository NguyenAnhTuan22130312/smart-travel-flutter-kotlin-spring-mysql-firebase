
package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Invoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    @Query("""
            SELECT i FROM Invoice i
            JOIN i.booking b
            WHERE b.user.id = :userId
              AND b.status IN ('COMPLETED', 'CONFIRMED')
            ORDER BY b.createdAt DESC
            """)
    Page<Invoice> findActiveInvoicesByUserId(Long userId, Pageable pageable);

    // Thêm 2 method mới vào interface InvoiceRepository.java

    /**
     * Lấy danh sách đơn hàng đã được HOÀN TIỀN (chỉ REFUNDED)
     */
    @Query("""
            SELECT i FROM Invoice i
            JOIN i.booking b
            WHERE b.user.id = :userId
              AND b.status = 'REFUNDED'
            ORDER BY b.createdAt DESC
            """)
    Page<Invoice> findRefundedInvoices(
            @Param("userId") Long userId,
            Pageable pageable);

    /**
     * Lấy danh sách đơn hàng đã kết thúc chuyến đi nhưng chưa đánh giá (có thể review)
     */
    @Query("""
        SELECT i FROM Invoice i
        JOIN i.booking b
        WHERE b.user.id = :userId
          AND b.status = 'COMPLETED'
          AND i.isReviewed = false
        ORDER BY b.createdAt DESC
        """)
    Page<Invoice> findReviewableInvoices(
            @Param("userId") Long userId,
            Pageable pageable);
}