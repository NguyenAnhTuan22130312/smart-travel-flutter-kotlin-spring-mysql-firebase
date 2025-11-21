package com.example.smart_travel_BE.dto.invoice.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActiveInvoiceResponse {
    private Long invoiceId;
    private String invoiceNumber;               // mã đơn hàng
    private String itemName;                    // tên tour hoặc khách sạn + loại phòng
    private LocalDate startDate;                // ngày bắt đầu (check-in hoặc ngày khởi hành tour)
    private LocalDate endDate;                  // ngày kết thúc
    private Integer nights;                     // số đêm = endDate - startDate (tour thì là durationDays - 1)
    private String status;                      // status của Booking
    private boolean isReviewed;                 // đã đánh giá chưa
}