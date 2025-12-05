// src/main/java/com/example/smart_travel_BE/dto/invoice/response/InvoiceDetailResponse.java

package com.example.smart_travel_BE.dto.invoice.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class InvoiceDetailResponse {

    private Long bookingId;
    private String invoiceNumber;
    private String bookingType;
    private String status;
    private LocalDateTime createdAt;

    private String itemName;
    private String thumbnailUrl;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer nights;
    private Integer numberOfPeople;

    private BigDecimal totalPrice;
    private BigDecimal discountAmount;
    private BigDecimal finalPrice;

    private String paymentStatus;

    private BigDecimal taxAmount;
    private String itemDetailsJson;
    private LocalDate issueDate;

    private boolean isReviewed;
    private LocalDateTime cancelledAt;

    private String customerName;
    private String customerPhone;
    private String customerEmail;

    private String amenitiesSummary;
    private String specialRequests;
}