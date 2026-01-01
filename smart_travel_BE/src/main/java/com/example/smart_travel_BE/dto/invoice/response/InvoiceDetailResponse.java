// src/main/java/com/example/smart_travel_BE/dto/invoice/response/InvoiceDetailResponse.java

package com.example.smart_travel_BE.dto.invoice.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class InvoiceDetailResponse {
    private Long bookingId;
    private String invoiceNumber;
    private String bookingType;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Long hotelId;
    private Long tourId;

    private String serviceName;

    private String roomTypeName;
    private List<String> roomAmenities;

    private String thumbnailUrl;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer nights;
    private Integer numberOfPeople;
    private String specialRequests;

    private BigDecimal totalPrice;
    private BigDecimal discountAmount;
    private BigDecimal finalPrice;

    private String paymentStatus;

    private BigDecimal taxAmount;

    private String customerName;
    private String customerPhone;
    private String customerEmail;
}