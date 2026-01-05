
package com.example.smart_travel_BE.dto.invoice.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class AdminInvoiceDetailResponse {
    private Long bookingId;
    private String invoiceNumber;

    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Long hotelId;
    private Long tourId;

    private String serviceName;         // Tên hotel hoặc tour
    private String roomTypeName;        // Tên loại phòng (null nếu tour)

    private LocalDate startDate;
    private LocalDate endDate;
    private Integer numberOfPeople;
    private Integer numberOfRooms;      // ← thêm theo yêu cầu
    private String specialRequests;
    private String cancellationReason;  // ← thêm, hiện khi PENDING_REFUND

    private BigDecimal totalPrice;
    private BigDecimal discountAmount;
    private BigDecimal finalPrice;

    private String paymentStatus;

    private BigDecimal taxAmount;

    private String customerName;
    private String customerPhone;
    private String customerEmail;
}