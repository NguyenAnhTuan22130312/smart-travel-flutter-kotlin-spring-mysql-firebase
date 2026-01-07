package com.example.smart_travel_BE.dto.invoice.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CheckInRequest {
    @NotNull(message = "Booking ID không được để trống")
    private Long bookingId;

    @Min(value = 1, message = "Số phòng phải lớn hơn 0")
    private Integer numberOfRooms;  // Bắt buộc cho hotel, tour thì null hoặc bỏ qua
}