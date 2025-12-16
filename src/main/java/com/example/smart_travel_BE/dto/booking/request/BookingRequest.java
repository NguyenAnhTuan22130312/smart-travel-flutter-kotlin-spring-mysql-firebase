package com.example.smart_travel_BE.dto.booking.request; // Gói DTO của bạn

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class BookingRequest {

    // Loại đặt: "TOUR" hoặc "HOTEL"
    @NotNull(message = "Booking type is required")
    private String bookingType;

    // --- Dành cho Tour ---
    private Long tourId; // Có thể null nếu đặt Hotel

    // --- Dành cho Hotel ---
    private Long hotelId; // Có thể null nếu đặt Tour
    private Integer numberOfRooms;

    // --- Chung ---
    @NotNull(message = "Start date is required")
    @FutureOrPresent
    private LocalDate startDate;

    private LocalDate endDate; // Bắt buộc với Hotel, Tour thì tự tính

    @NotNull
    private int numberOfPeople;

    private String couponCode;

    // Lưu ý: Không truyền totalPrice từ FE lên để tránh hack giá.
    // Backend tự tính based on ID.
}
