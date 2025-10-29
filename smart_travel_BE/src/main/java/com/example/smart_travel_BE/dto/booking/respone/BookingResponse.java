package com.example.smart_travel_BE.dto.booking.respone; // Gói DTO của bạn

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class BookingResponse {

    private String bookingId; // (String)
    private double amount; // (double)
    private String message;

    // Constructor để chuyển đổi từ Entity
    public BookingResponse(Long bookingId, BigDecimal finalPrice, String message) {
        this.bookingId = String.valueOf(bookingId);
        this.amount = finalPrice.doubleValue();
        this.message = message;
    }
}