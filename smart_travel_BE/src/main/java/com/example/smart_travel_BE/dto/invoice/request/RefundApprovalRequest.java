package com.example.smart_travel_BE.dto.invoice.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RefundApprovalRequest {
    @NotNull(message = "Booking ID không được để trống")
    private Long bookingId;
}