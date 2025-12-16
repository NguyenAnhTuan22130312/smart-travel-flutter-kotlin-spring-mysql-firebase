package com.example.smart_travel_BE.dto.invoice.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RefundRequest {

    @NotNull(message = "Booking ID không được để trống")
    @Positive(message = "Booking ID phải là số dương")
    private Long bookingId;

    @NotBlank(message = "Lý do hoàn tiền không được để trống")
    private String reason;
}