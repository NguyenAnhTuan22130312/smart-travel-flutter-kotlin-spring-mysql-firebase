// src/main/java/com/example/smart_travel_BE/dto/invoice/response/ActiveInvoiceResponse.java

package com.example.smart_travel_BE.dto.invoice.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActiveInvoiceResponse {

    private Long bookingId;          // Dùng cái này làm key chính để lấy chi tiết sau này
    // (Payment, Invoice, Booking đều join qua booking_id)
    private String invoiceNumber;    // Hiển thị cho người dùng: INV-20251201-00089
    private String itemName;         // Tên khách sạn + loại phòng HOẶC tên tour
    private LocalDate startDate;     // Ngày check-in / ngày khởi hành
    private LocalDate endDate;       // Ngày check-out / ngày kết thúc tour
    private Integer nights;          // Số đêm (hotel) hoặc số đêm tour (durationNights)
    private String status;           // Trạng thái đơn hàng
    private boolean isReviewed;      // Đã đánh giá chưa
}