package com.example.smart_travel_BE.dto.booking.request; // Gói DTO của bạn

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class BookingRequest {
    @NotNull(message = "Tour ID is required")
    private Long tourId;
    @NotNull(message = "Start date is required")
    @FutureOrPresent(message = "Start date must be in the present or future")
    private LocalDate startDate;

    @NotNull(message = "Number of people is required")
    @Min(value = 1, message = "Must book for at least 1 person")
    private int numberOfPeople;

    @NotNull(message = "Total price is required")
    private BigDecimal totalPrice;

    private String couponCode;
}
