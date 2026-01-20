// src/main/java/com/example/smart_travel_BE/repository/InvoiceRepository.java

package com.example.smart_travel_BE.repository;

import com.example.smart_travel_BE.entity.Booking;
import com.example.smart_travel_BE.entity.Hotel;
import com.example.smart_travel_BE.entity.Invoice;
import com.example.smart_travel_BE.entity.Tour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    Optional<Invoice> findByBooking_Id(Long bookingId);

    @Query("""
        SELECT b FROM Booking b
        LEFT JOIN FETCH b.invoice i
        LEFT JOIN FETCH b.payment p
        LEFT JOIN FETCH b.user u
        LEFT JOIN FETCH b.roomType rt
        WHERE b.id = :bookingId
        """)
    Optional<Booking> findFullBookingById(@Param("bookingId") Long bookingId);

    // 2. Lấy Hotel + thumbnail (dùng method getThumbnail())
    @Query("SELECT h FROM Hotel h LEFT JOIN FETCH h.images WHERE h.id = :hotelId")
    Optional<Hotel> findHotelWithImagesById(@Param("hotelId") Long hotelId);

    // 3. Lấy Tour + thumbnail
    @Query("SELECT t FROM Tour t LEFT JOIN FETCH t.images WHERE t.id = :tourId")
    Optional<Tour> findTourWithImagesById(@Param("tourId") Long tourId);

    // 2. Danh sách đơn ĐANG HOẠT ĐỘNG – giữ nguyên tên method cũ
    @Query("""
            SELECT b FROM Booking b
            LEFT JOIN FETCH b.invoice
            WHERE b.user.id = :userId
              AND b.status IN ('ACTIVE','CHECKED')
            ORDER BY b.createdAt DESC
            """)
    List<Booking> findActiveInvoicesByUserId(@Param("userId") Long userId);

    // 3. Đơn đã / đang hoàn tiền
    @Query("""
        SELECT b FROM Booking b
        LEFT JOIN FETCH b.invoice
        WHERE b.user.id = :userId
          AND b.status IN ('REFUNDED', 'PENDING_REFUND')
        ORDER BY b.createdAt DESC
        """)
    List<Booking> findRefundedInvoices(
            @Param("userId") Long userId
    );


    // 4. Đơn có thể ĐÁNH GIÁ – giữ nguyên tên method cũ + sửa isReviewed từ Booking
    @Query("""
        SELECT b FROM Booking b
        LEFT JOIN FETCH b.invoice i
        WHERE b.user.id = :userId
          AND b.status = 'COMPLETED'
          AND (i.isReviewed = false OR i.isReviewed IS NULL)
        ORDER BY b.endDate DESC, b.createdAt DESC
        """)
    List<Booking> findReviewableInvoices(@Param("userId") Long userId);

    // 5. SEARCH ĐƠN ĐANG HOẠT ĐỘNG – giữ nguyên tên method cũ
    @Query("""
            SELECT b FROM Booking b
            LEFT JOIN FETCH b.invoice
            LEFT JOIN Tour t ON b.tourId = t.id AND b.bookingType = 'TOUR'
            LEFT JOIN Hotel h ON b.hotelId = h.id AND b.bookingType = 'HOTEL'
            WHERE b.user.id = :userId
              AND b.status IN ('ACTIVE','CHECKED')
              AND (:keyword IS NULL OR :keyword = '' OR :keyword = 'null'
                   OR LOWER(t.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(h.name) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY b.createdAt DESC
            """)
    List<Booking> searchActiveInvoices(
            @Param("userId") Long userId,
            @Param("keyword") String keyword);

    // 6. SEARCH ĐƠN HOÀN TIỀN – giữ nguyên tên method cũ
    @Query("""
            SELECT b FROM Booking b
            LEFT JOIN FETCH b.invoice
            LEFT JOIN Tour t ON b.tourId = t.id AND b.bookingType = 'TOUR'
            LEFT JOIN Hotel h ON b.hotelId = h.id AND b.bookingType = 'HOTEL'
            WHERE b.user.id = :userId
              AND b.status = 'REFUNDED'
              AND (:keyword IS NULL OR :keyword = '' OR :keyword = 'null'
                   OR LOWER(t.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(h.name) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY b.createdAt DESC
            """)
    List<Booking> searchRefundedInvoices(
            @Param("userId") Long userId,
            @Param("keyword") String keyword);

    @Query("""
    SELECT b FROM Booking b
    LEFT JOIN FETCH b.invoice i
    LEFT JOIN FETCH b.payment p
    WHERE b.user.id = :userId
      AND (:typeFilter IS NULL OR :typeFilter = 'ALL' OR b.bookingType = :typeFilter)
      AND (:statusFilter IS NULL 
           OR :statusFilter = '' 
           OR b.status = :statusFilter)
    ORDER BY b.createdAt DESC
    """)
    List<Booking> findTransactionHistory(
            @Param("userId") Long userId,
            @Param("typeFilter") String typeFilter,
            @Param("statusFilter") String statusFilter
    );

    @Query("""
SELECT b FROM Booking b
LEFT JOIN FETCH b.invoice i
LEFT JOIN FETCH b.roomType rt
LEFT JOIN Hotel h ON b.hotelId = h.id
LEFT JOIN Tour t ON b.tourId = t.id
WHERE 1 = 1
  AND (:invoiceNumber IS NULL OR :invoiceNumber = '' 
       OR LOWER(i.invoiceNumber) LIKE LOWER(CONCAT('%', :invoiceNumber, '%')))
       
  AND (:status IS NULL OR :status = '' OR b.status = :status)
  AND (
    :role = 'ADMIN'
    OR (:role = 'ADMINHOTEL' AND h.owner.id = :currentUserId)
    OR (:role = 'ADMINTOUR' AND t.owner.id = :currentUserId)
  )
ORDER BY b.createdAt DESC
""")
    List<Booking> findAdminInvoices(
            @Param("currentUserId") Long currentUserId,
            @Param("role") String role,
            @Param("invoiceNumber") String invoiceNumber,
            @Param("status") String status);
}