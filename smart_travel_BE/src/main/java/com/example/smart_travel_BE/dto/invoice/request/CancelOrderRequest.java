package com.example.smart_travel_BE.dto.invoice.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CancelOrderRequest {
    @NotNull(message = "Booking ID không được để trống")
    private Long bookingId;

    @NotBlank(message = "Lý do hủy không được để trống")
    private String cancelMessage;  // lời nhắn lý do từ admin
}