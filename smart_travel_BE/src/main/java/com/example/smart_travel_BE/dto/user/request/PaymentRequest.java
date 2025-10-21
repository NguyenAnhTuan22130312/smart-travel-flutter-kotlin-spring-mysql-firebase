package com.example.smart_travel_BE.dto.user.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class PaymentRequest {

    @NotEmpty(message = "Booking ID không được để trống")
    private String bookingId;

    @NotNull(message = "Số tiền không được để trống")
    private BigDecimal amount;

    @NotEmpty(message = "Phương thức thanh toán không được để trống")
    private String paymentMethod; // "VNPAY", "MOMO", "CASH"
}